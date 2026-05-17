-- ARACIYOK Faz 2: RLS Politikaları
-- Bu dosya 001_initial_schema.sql sonrasında çalıştırılır.

-- =========================================================================
-- profiles
-- =========================================================================

alter table profiles enable row level security;

-- Herkes (giriş yapmış kullanıcılar) tüm public profilleri okuyabilir
create policy "public profiles readable by authenticated"
  on profiles for select
  to authenticated
  using (true);

-- Sadece sahip kendi profilini günceller
create policy "users update own profile"
  on profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Sahip kendi profilini oluşturur (auth.uid ile id eşleşmeli)
create policy "users insert own profile"
  on profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- =========================================================================
-- profile_private_info — sadece sahip görür
-- =========================================================================

alter table profile_private_info enable row level security;

create policy "private info: owner only"
  on profile_private_info for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- =========================================================================
-- carrier_profiles
-- =========================================================================

alter table carrier_profiles enable row level security;

-- Herkes nakliyeci profilini okuyabilir (plaka dahil değil, public bilgi)
create policy "carrier profile readable by authenticated"
  on carrier_profiles for select
  to authenticated
  using (true);

create policy "carrier updates own"
  on carrier_profiles for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- =========================================================================
-- carrier_documents — sadece sahip ve admin görür
-- =========================================================================

alter table carrier_documents enable row level security;

create policy "carrier docs: owner only read"
  on carrier_documents for select
  to authenticated
  using (auth.uid() = user_id);

create policy "carrier docs: owner only write"
  on carrier_documents for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "carrier docs: owner only update"
  on carrier_documents for update
  to authenticated
  using (auth.uid() = user_id);

-- =========================================================================
-- job_posts
-- =========================================================================

alter table job_posts enable row level security;

-- Açık ilanlar herkes tarafından görülebilir; kapalı olanlar sadece taraflar.
-- Detaylar (origin_address, destination_address, lat/lng) için bunlar normal
-- okumayla geliyor ama UI'da teklif kabul edilene kadar gizlenir.
-- Daha sağlam çözüm view + maskeleme; MVP için UI maskelemesi yeterli.
create policy "jobs readable by authenticated"
  on job_posts for select
  to authenticated
  using (
    status = 'open'
    or shipper_id = auth.uid()
    or exists (
      select 1 from offers
      where offers.job_post_id = job_posts.id
        and offers.carrier_id = auth.uid()
    )
  );

create policy "shipper creates own job"
  on job_posts for insert
  to authenticated
  with check (
    shipper_id = auth.uid()
    and exists (
      select 1 from profiles
      where id = auth.uid() and role = 'shipper'
    )
  );

create policy "shipper updates own job"
  on job_posts for update
  to authenticated
  using (shipper_id = auth.uid())
  with check (shipper_id = auth.uid());

-- =========================================================================
-- offers
-- =========================================================================

alter table offers enable row level security;

-- Yükveren kendi ilanına gelen teklifleri görür, nakliyeci kendi tekliflerini görür
create policy "offers visible to parties"
  on offers for select
  to authenticated
  using (
    carrier_id = auth.uid()
    or exists (
      select 1 from job_posts jp
      where jp.id = offers.job_post_id
        and jp.shipper_id = auth.uid()
    )
  );

-- Sadece nakliyeci teklif verir
create policy "carrier creates own offer"
  on offers for insert
  to authenticated
  with check (
    carrier_id = auth.uid()
    and exists (
      select 1 from profiles
      where id = auth.uid() and role = 'carrier'
    )
  );

-- Nakliyeci kendi teklifini günceller (withdraw için), yükveren statüsünü değiştirir
create policy "offer parties update"
  on offers for update
  to authenticated
  using (
    carrier_id = auth.uid()
    or exists (
      select 1 from job_posts jp
      where jp.id = offers.job_post_id
        and jp.shipper_id = auth.uid()
    )
  );

-- =========================================================================
-- message_threads + messages
-- =========================================================================

alter table message_threads enable row level security;

create policy "threads: parties only"
  on message_threads for select
  to authenticated
  using (shipper_id = auth.uid() or carrier_id = auth.uid());

-- Insert RPC ile yapılır (accept_offer içinde)

alter table messages enable row level security;

create policy "messages: parties only read"
  on messages for select
  to authenticated
  using (
    exists (
      select 1 from message_threads mt
      where mt.id = messages.thread_id
        and (mt.shipper_id = auth.uid() or mt.carrier_id = auth.uid())
    )
  );

create policy "messages: parties only write"
  on messages for insert
  to authenticated
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from message_threads mt
      where mt.id = messages.thread_id
        and (mt.shipper_id = auth.uid() or mt.carrier_id = auth.uid())
    )
  );

create policy "messages: own update read flag"
  on messages for update
  to authenticated
  using (
    exists (
      select 1 from message_threads mt
      where mt.id = messages.thread_id
        and (mt.shipper_id = auth.uid() or mt.carrier_id = auth.uid())
    )
  );

-- =========================================================================
-- reviews
-- =========================================================================

alter table reviews enable row level security;

create policy "reviews readable by authenticated"
  on reviews for select
  to authenticated
  using (true);

create policy "reviews: only completed job parties create"
  on reviews for insert
  to authenticated
  with check (
    reviewer_id = auth.uid()
    and exists (
      select 1 from job_posts jp
      where jp.id = reviews.job_post_id
        and jp.status = 'completed'
        and (jp.shipper_id = auth.uid() or exists (
          select 1 from offers o
          where o.job_post_id = jp.id
            and o.carrier_id = auth.uid()
            and o.status = 'accepted'
        ))
    )
  );

-- =========================================================================
-- notifications
-- =========================================================================

alter table notifications enable row level security;

create policy "notifications: owner only"
  on notifications for select
  to authenticated
  using (user_id = auth.uid());

create policy "notifications: owner can mark read"
  on notifications for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Insert RPC ile yapılır (server-side trigger veya edge function)

-- =========================================================================
-- device_tokens
-- =========================================================================

alter table device_tokens enable row level security;

create policy "device_tokens: owner only"
  on device_tokens for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
