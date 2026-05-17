-- ARACIYOK: IBAN, awaiting_payment, havale onay akışı (sıfır komisyon)

-- job_status: teslim sonrası ödeme bekleniyor
alter type job_status add value if not exists 'awaiting_payment' after 'delivery_approval';

-- payment_status: havale bekliyor / nakliyeci onayladı
alter type payment_status add value if not exists 'awaiting_transfer';
alter type payment_status add value if not exists 'carrier_confirmed';

alter type notification_type add value if not exists 'payment_pending';
alter type notification_type add value if not exists 'payment_confirmed';

-- Nakliyeci IBAN (ödeme ekranında gösterilir)
alter table carrier_profiles
  add column if not exists iban text;

alter table carrier_profiles
  add constraint chk_carrier_iban_format check (
    iban is null
    or (length(replace(iban, ' ', '')) between 24 and 34)
  );

-- Varsayılan komisyon oranı sıfır
alter table payments alter column commission_rate set default 0;

-- =========================================================================
-- accept_offer: ödeme kaydı (komisyon 0)
-- =========================================================================

create or replace function accept_offer(p_offer_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_offer offers%rowtype;
  v_job job_posts%rowtype;
  v_caller uuid := auth.uid();
  v_amount numeric(10, 2);
begin
  select * into v_offer from offers where id = p_offer_id;
  if not found then
    raise exception 'Teklif bulunamadi';
  end if;

  select * into v_job from job_posts where id = v_offer.job_post_id;
  if v_job.shipper_id <> v_caller then
    raise exception 'Bu islemi sadece ilan sahibi yapabilir';
  end if;

  if v_job.status <> 'open' then
    raise exception 'Ilan zaten kapatilmis durumda';
  end if;

  if v_offer.status <> 'pending' then
    raise exception 'Teklif zaten kabul/red edilmis';
  end if;

  update offers
    set status = 'rejected'
    where job_post_id = v_offer.job_post_id
      and id <> p_offer_id
      and status = 'pending';

  update offers set status = 'accepted' where id = p_offer_id;

  update job_posts
    set status = 'offer_accepted',
        accepted_offer_id = p_offer_id
    where id = v_offer.job_post_id;

  insert into message_threads (job_post_id, shipper_id, carrier_id)
    values (v_offer.job_post_id, v_job.shipper_id, v_offer.carrier_id)
    on conflict (job_post_id) do nothing;

  v_amount := v_offer.amount;

  insert into payments (
    job_post_id,
    offer_id,
    shipper_id,
    carrier_id,
    amount,
    commission_rate,
    commission_amount,
    carrier_payout,
    status,
    provider
  )
  values (
    v_offer.job_post_id,
    p_offer_id,
    v_job.shipper_id,
    v_offer.carrier_id,
    v_amount,
    0,
    0,
    v_amount,
    'pending',
    'bank_transfer'
  )
  on conflict (job_post_id) do nothing;

  insert into notifications (user_id, type, title, body, data)
    values (
      v_offer.carrier_id,
      'offer_accepted',
      'Teklifin kabul edildi',
      'Yukleyici teklifini onayladi.',
      jsonb_build_object('job_post_id', v_offer.job_post_id, 'offer_id', p_offer_id)
    );
end;
$$;

-- =========================================================================
-- confirm_delivery: çift onay → awaiting_payment (completed değil)
-- =========================================================================

create or replace function confirm_delivery(p_job_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job job_posts%rowtype;
  v_accepted_offer offers%rowtype;
  v_caller uuid := auth.uid();
  v_is_shipper boolean;
  v_is_carrier boolean;
  v_both boolean;
begin
  select * into v_job from job_posts where id = p_job_id;
  if not found then
    raise exception 'Ilan bulunamadi';
  end if;

  if v_job.status not in ('on_road', 'delivery_approval') then
    raise exception 'Ilan teslim asamasinda degil';
  end if;

  select * into v_accepted_offer from offers where id = v_job.accepted_offer_id;

  v_is_shipper := (v_job.shipper_id = v_caller);
  v_is_carrier := (v_accepted_offer.carrier_id = v_caller);

  if not (v_is_shipper or v_is_carrier) then
    raise exception 'Bu islemi sadece taraflar yapabilir';
  end if;

  if v_job.status = 'on_road' then
    update job_posts set status = 'delivery_approval' where id = p_job_id;
  end if;

  if v_is_shipper then
    update job_posts set delivery_confirmed_by_shipper = true where id = p_job_id;
  end if;
  if v_is_carrier then
    update job_posts set delivery_confirmed_by_carrier = true where id = p_job_id;
  end if;

  select delivery_confirmed_by_shipper and delivery_confirmed_by_carrier
    into v_both
    from job_posts where id = p_job_id;

  if v_both then
    update job_posts
      set status = 'awaiting_payment'
      where id = p_job_id;

    update payments
      set status = 'awaiting_transfer'
      where job_post_id = p_job_id;

    insert into notifications (user_id, type, title, body, data)
      values
        (
          v_job.shipper_id,
          'payment_pending',
          'Odeme bekleniyor',
          'Nakliyecinin IBAN bilgisine havale yapabilirsin.',
          jsonb_build_object('job_post_id', p_job_id)
        ),
        (
          v_accepted_offer.carrier_id,
          'payment_pending',
          'Odeme bekleniyor',
          'Yukveren odemeyi yaptiginda onayla.',
          jsonb_build_object('job_post_id', p_job_id)
        );
  elsif not v_both then
    insert into notifications (user_id, type, title, body, data)
      values (
        case when v_is_shipper then v_accepted_offer.carrier_id
             else v_job.shipper_id end,
        'job_status_changed',
        'Teslim onayi bekleniyor',
        'Karsi taraf teslimati onayladi, sen de onayla.',
        jsonb_build_object('job_post_id', p_job_id)
      );
  end if;
end;
$$;

-- =========================================================================
-- confirm_carrier_payment — Nakliyeci ödeme aldı → iş tamamlandı
-- =========================================================================

create or replace function confirm_carrier_payment(p_job_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job job_posts%rowtype;
  v_accepted_offer offers%rowtype;
  v_payment payments%rowtype;
  v_caller uuid := auth.uid();
begin
  select * into v_job from job_posts where id = p_job_id;
  if not found then
    raise exception 'Ilan bulunamadi';
  end if;

  if v_job.status <> 'awaiting_payment' then
    raise exception 'Ilan odeme asamasinda degil';
  end if;

  select * into v_accepted_offer from offers where id = v_job.accepted_offer_id;
  if v_accepted_offer.carrier_id <> v_caller then
    raise exception 'Bu islemi sadece nakliyeci yapabilir';
  end if;

  select * into v_payment from payments where job_post_id = p_job_id;
  if not found then
    raise exception 'Odeme kaydi bulunamadi';
  end if;

  if v_payment.status = 'carrier_confirmed' then
    return;
  end if;

  update payments
    set status = 'carrier_confirmed',
        released_at = now()
    where id = v_payment.id;

  update job_posts
    set status = 'completed'
    where id = p_job_id;

  update profiles
    set completed_jobs_count = completed_jobs_count + 1
    where id in (v_job.shipper_id, v_accepted_offer.carrier_id);

  insert into notifications (user_id, type, title, body, data)
    values
      (
        v_job.shipper_id,
        'payment_confirmed',
        'Odeme onaylandi',
        'Nakliyeci odemeyi aldigini onayladi. Is tamamlandi.',
        jsonb_build_object('job_post_id', p_job_id)
      ),
      (
        v_accepted_offer.carrier_id,
        'job_status_changed',
        'Is tamamlandi',
        'Tasima basariyla tamamlandi.',
        jsonb_build_object('job_post_id', p_job_id)
      );
end;
$$;

revoke all on function confirm_carrier_payment(uuid) from public;
grant execute on function confirm_carrier_payment(uuid) to authenticated;
