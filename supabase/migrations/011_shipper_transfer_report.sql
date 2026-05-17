-- Yükveren "ödemeyi yaptım" bildirimi (işi kapatmaz, audit)

alter table payments
  add column if not exists shipper_reported_transfer_at timestamptz;

create or replace function report_shipper_transfer(p_job_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job job_posts%rowtype;
  v_payment payments%rowtype;
begin
  select * into v_job from job_posts where id = p_job_id;
  if not found then
    raise exception 'Ilan bulunamadi';
  end if;

  if v_job.shipper_id <> auth.uid() then
    raise exception 'Bu islemi sadece yukveren yapabilir';
  end if;

  if v_job.status <> 'awaiting_payment' then
    raise exception 'Ilan odeme asamasinda degil';
  end if;

  select * into v_payment from payments where job_post_id = p_job_id;
  if not found then
    raise exception 'Odeme kaydi bulunamadi';
  end if;

  update payments
    set shipper_reported_transfer_at = now()
    where id = v_payment.id;

  insert into payment_events (payment_id, event_type, notes)
    values (v_payment.id, 'captured', 'Yukveren havale yaptigini bildirdi');

  insert into notifications (user_id, type, title, body, data)
    values (
      (select carrier_id from payments where id = v_payment.id),
      'payment_pending',
      'Odeme bildirimi',
      'Yukveren odemeyi yaptigini bildirdi. Lutfen kontrol edip onayla.',
      jsonb_build_object('job_post_id', p_job_id)
    );
end;
$$;

revoke all on function report_shipper_transfer(uuid) from public;
grant execute on function report_shipper_transfer(uuid) to authenticated;
