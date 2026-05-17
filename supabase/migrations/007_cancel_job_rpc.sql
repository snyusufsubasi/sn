-- ARACIYOK Faz 4: cancel_job RPC ek migration
-- Yükveren açık ilanı iptal eder. İlgili tüm pending teklifler de iptal edilir.

create or replace function cancel_job(p_job_id uuid, p_reason text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job job_posts%rowtype;
  v_caller uuid := auth.uid();
begin
  select * into v_job from job_posts where id = p_job_id;
  if not found then
    raise exception 'Ilan bulunamadi';
  end if;
  if v_job.shipper_id <> v_caller then
    raise exception 'Bu islemi sadece ilan sahibi yapabilir';
  end if;
  if v_job.status not in ('open') then
    raise exception 'Sadece acik ilan iptal edilebilir (su anki durum: %)', v_job.status;
  end if;

  -- Açık ilanın tüm pending tekliflerini withdraw'a çek
  update offers
    set status = 'withdrawn'
    where job_post_id = p_job_id
      and status = 'pending';

  -- İlanı iptal et
  update job_posts
    set status = 'cancelled',
        cancelled_at = now(),
        cancelled_reason = p_reason
    where id = p_job_id;
end;
$$;

revoke all on function cancel_job(uuid, text) from public;
grant execute on function cancel_job(uuid, text) to authenticated;
