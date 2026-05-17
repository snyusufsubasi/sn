-- Thread listesi için tek sorgu (N+1 önleme)

create or replace view message_threads_summary as
select
  mt.id,
  mt.job_post_id,
  mt.shipper_id,
  mt.carrier_id,
  mt.created_at,
  (
    select m.body
    from messages m
    where m.thread_id = mt.id
    order by m.created_at desc
    limit 1
  ) as last_message_body,
  (
    select m.created_at
    from messages m
    where m.thread_id = mt.id
    order by m.created_at desc
    limit 1
  ) as last_message_at,
  (
    select count(*)::int
    from messages m
    where m.thread_id = mt.id
      and m.is_read = false
      and m.sender_id <> auth.uid()
  ) as unread_count
from message_threads mt;

grant select on message_threads_summary to authenticated;
