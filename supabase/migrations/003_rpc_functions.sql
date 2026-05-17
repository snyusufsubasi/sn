-- ARACIYOK Faz 2: RPC Fonksiyonları
-- Çift taraflı onay akışı, teklif kabul, iptal vb.

-- =========================================================================
-- accept_offer — Yükveren teklifi kabul eder
-- =========================================================================
-- - Teklifi 'accepted' yapar, diğer pending teklifleri 'rejected' yapar
-- - job_posts.status'u 'offer_accepted' yapar
-- - job_posts.accepted_offer_id'yi set eder
-- - message_thread oluşturur (mesajlaşma açılır)
-- - İlgili taraflara bildirim oluşturur

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

  -- Diger pending teklifleri reddet
  update offers
    set status = 'rejected'
    where job_post_id = v_offer.job_post_id
      and id <> p_offer_id
      and status = 'pending';

  -- Bu teklifi kabul et
  update offers set status = 'accepted' where id = p_offer_id;

  -- Ilani güncelle
  update job_posts
    set status = 'offer_accepted',
        accepted_offer_id = p_offer_id
    where id = v_offer.job_post_id;

  -- Mesajlasma thread'i olustur
  insert into message_threads (job_post_id, shipper_id, carrier_id)
    values (v_offer.job_post_id, v_job.shipper_id, v_offer.carrier_id)
    on conflict (job_post_id) do nothing;

  -- Bildirimler
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

revoke all on function accept_offer(uuid) from public;
grant execute on function accept_offer(uuid) to authenticated;

-- =========================================================================
-- reject_offer — Yükveren tek bir teklifi reddeder
-- =========================================================================

create or replace function reject_offer(p_offer_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_offer offers%rowtype;
  v_job job_posts%rowtype;
begin
  select * into v_offer from offers where id = p_offer_id;
  if not found then
    raise exception 'Teklif bulunamadi';
  end if;

  select * into v_job from job_posts where id = v_offer.job_post_id;
  if v_job.shipper_id <> auth.uid() then
    raise exception 'Bu islemi sadece ilan sahibi yapabilir';
  end if;

  if v_offer.status <> 'pending' then
    raise exception 'Teklif zaten islenmis';
  end if;

  update offers set status = 'rejected' where id = p_offer_id;

  insert into notifications (user_id, type, title, body, data)
    values (
      v_offer.carrier_id,
      'offer_rejected',
      'Teklifin reddedildi',
      'Yukleyici teklifini reddetti.',
      jsonb_build_object('job_post_id', v_offer.job_post_id, 'offer_id', p_offer_id)
    );
end;
$$;

revoke all on function reject_offer(uuid) from public;
grant execute on function reject_offer(uuid) to authenticated;

-- =========================================================================
-- confirm_pickup — Çift taraflı yük alma onayı
-- =========================================================================
-- Hem nakliyeci hem yükveren onayladığında status = 'loaded' yapılır.

create or replace function confirm_pickup(p_job_id uuid)
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
begin
  select * into v_job from job_posts where id = p_job_id;
  if not found then
    raise exception 'Ilan bulunamadi';
  end if;

  if v_job.status not in ('offer_accepted', 'pickup_approval') then
    raise exception 'Ilan yuk alma asamasinda degil';
  end if;

  select * into v_accepted_offer from offers where id = v_job.accepted_offer_id;

  v_is_shipper := (v_job.shipper_id = v_caller);
  v_is_carrier := (v_accepted_offer.carrier_id = v_caller);

  if not (v_is_shipper or v_is_carrier) then
    raise exception 'Bu islemi sadece taraflar yapabilir';
  end if;

  -- İlk onayda status'u 'pickup_approval' yap (henüz tam onay yok)
  if v_job.status = 'offer_accepted' then
    update job_posts set status = 'pickup_approval' where id = p_job_id;
  end if;

  if v_is_shipper then
    update job_posts set pickup_confirmed_by_shipper = true where id = p_job_id;
  end if;
  if v_is_carrier then
    update job_posts set pickup_confirmed_by_carrier = true where id = p_job_id;
  end if;

  -- Her iki taraf da onayladıysa loaded'a geç
  update job_posts
    set status = 'loaded'
    where id = p_job_id
      and pickup_confirmed_by_shipper = true
      and pickup_confirmed_by_carrier = true;

  -- Karşı tarafa bildirim (henüz tam onay yoksa)
  if not (select pickup_confirmed_by_shipper and pickup_confirmed_by_carrier
          from job_posts where id = p_job_id) then
    insert into notifications (user_id, type, title, body, data)
      values (
        case when v_is_shipper then v_accepted_offer.carrier_id
             else v_job.shipper_id end,
        'job_status_changed',
        'Yuk alma onayi bekleniyor',
        'Karsi taraf yuk almayi onayladi, sen de onayla.',
        jsonb_build_object('job_post_id', p_job_id)
      );
  end if;
end;
$$;

revoke all on function confirm_pickup(uuid) from public;
grant execute on function confirm_pickup(uuid) to authenticated;

-- =========================================================================
-- start_road — Nakliyeci yola çıktığını bildirir
-- =========================================================================

create or replace function start_road(p_job_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job job_posts%rowtype;
  v_accepted_offer offers%rowtype;
begin
  select * into v_job from job_posts where id = p_job_id;
  if not found then
    raise exception 'Ilan bulunamadi';
  end if;

  select * into v_accepted_offer from offers where id = v_job.accepted_offer_id;
  if v_accepted_offer.carrier_id <> auth.uid() then
    raise exception 'Bu islemi sadece nakliyeci yapabilir';
  end if;

  if v_job.status <> 'loaded' then
    raise exception 'Yuk henuz alinmamis';
  end if;

  update job_posts set status = 'on_road' where id = p_job_id;

  insert into notifications (user_id, type, title, body, data)
    values (
      v_job.shipper_id,
      'job_status_changed',
      'Yuk yolda',
      'Nakliyeci yola cikti.',
      jsonb_build_object('job_post_id', p_job_id)
    );
end;
$$;

revoke all on function start_road(uuid) from public;
grant execute on function start_road(uuid) to authenticated;

-- =========================================================================
-- confirm_delivery — Çift taraflı teslimat onayı
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

  -- Çift onay → completed
  update job_posts
    set status = 'completed'
    where id = p_job_id
      and delivery_confirmed_by_shipper = true
      and delivery_confirmed_by_carrier = true;

  -- Tamamlandıysa istatistikleri güncelle
  if (select status from job_posts where id = p_job_id) = 'completed' then
    update profiles
      set completed_jobs_count = completed_jobs_count + 1
      where id in (v_job.shipper_id, v_accepted_offer.carrier_id);

    insert into notifications (user_id, type, title, body, data)
      values
        (v_job.shipper_id, 'job_status_changed', 'Teslimat tamamlandi',
         'Tasima isi basariyla tamamlandi.',
         jsonb_build_object('job_post_id', p_job_id)),
        (v_accepted_offer.carrier_id, 'job_status_changed', 'Teslimat tamamlandi',
         'Tasima isi basariyla tamamlandi.',
         jsonb_build_object('job_post_id', p_job_id));
  end if;
end;
$$;

revoke all on function confirm_delivery(uuid) from public;
grant execute on function confirm_delivery(uuid) to authenticated;

-- =========================================================================
-- cancel_job — İlan iptal
-- =========================================================================

create or replace function cancel_job(p_job_id uuid, p_reason text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job job_posts%rowtype;
begin
  select * into v_job from job_posts where id = p_job_id;
  if not found then raise exception 'Ilan bulunamadi'; end if;

  if v_job.shipper_id <> auth.uid() then
    raise exception 'Bu islemi sadece ilan sahibi yapabilir';
  end if;

  if v_job.status in ('completed', 'cancelled') then
    raise exception 'Ilan zaten kapali';
  end if;

  update job_posts
    set status = 'cancelled',
        cancelled_at = now(),
        cancelled_reason = p_reason,
        cancelled_by = auth.uid()
    where id = p_job_id;

  update offers
    set status = 'expired'
    where job_post_id = p_job_id and status in ('pending');
end;
$$;

revoke all on function cancel_job(uuid, text) from public;
grant execute on function cancel_job(uuid, text) to authenticated;

-- =========================================================================
-- Rating average trigger — review eklenince profiles.rating_avg güncelle
-- =========================================================================

create or replace function tg_update_rating_avg()
returns trigger
language plpgsql
as $$
begin
  update profiles
    set rating_avg = coalesce((
      select avg(rating)::numeric(3,2)
      from reviews
      where reviewee_id = new.reviewee_id
    ), 0)
    where id = new.reviewee_id;
  return new;
end;
$$;

create trigger trg_reviews_update_rating
  after insert on reviews
  for each row execute function tg_update_rating_avg();
