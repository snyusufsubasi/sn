-- ARACIYOK Faz 2: Storage Bucket'ları
-- Supabase Studio'da elle de oluşturulabilir, ama burada kayıtlı tutuyoruz.

-- Avatar bucket (public)
insert into storage.buckets (id, name, public)
  values ('avatars', 'avatars', true)
  on conflict do nothing;

-- Carrier dokümanları (private)
insert into storage.buckets (id, name, public)
  values ('carrier_documents', 'carrier_documents', false)
  on conflict do nothing;

-- İlan fotoğrafları (public)
insert into storage.buckets (id, name, public)
  values ('job_photos', 'job_photos', true)
  on conflict do nothing;

-- Teslimat kanıt fotoğrafları (private)
insert into storage.buckets (id, name, public)
  values ('proofs', 'proofs', false)
  on conflict do nothing;

-- =========================================================================
-- Avatars: sahip yazar, herkes okur
-- =========================================================================

create policy "avatars: public read"
  on storage.objects for select
  to public
  using (bucket_id = 'avatars');

create policy "avatars: owner upload"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars: owner update"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars: owner delete"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- =========================================================================
-- Carrier documents: sahip yazar, sadece sahip okur
-- =========================================================================

create policy "carrier docs: owner read"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'carrier_documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "carrier docs: owner upload"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'carrier_documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- =========================================================================
-- Job photos: sahip yazar, herkes okur (sadece kendi ilan klasörüne)
-- Path: {user_id}/{job_post_id}/{uuid}.jpg
-- =========================================================================

create policy "job photos: public read"
  on storage.objects for select
  to public
  using (bucket_id = 'job_photos');

create policy "job photos: owner upload"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'job_photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- =========================================================================
-- Proofs (delivery proof): sahip yazar, sadece ilgili taraflar okur
-- =========================================================================

create policy "proofs: parties only read"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'proofs'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or exists (
        select 1 from job_posts jp
        join offers o on o.job_post_id = jp.id and o.status = 'accepted'
        where (jp.shipper_id::text = (storage.foldername(name))[1]
               or o.carrier_id::text = (storage.foldername(name))[1])
          and (jp.shipper_id = auth.uid() or o.carrier_id = auth.uid())
      )
    )
  );

create policy "proofs: owner upload"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
