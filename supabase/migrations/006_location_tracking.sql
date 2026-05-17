-- ARACIYOK Faz 9: Konum Takibi
-- Aktif taşıma sırasında nakliyecinin konum ping'leri

create table location_pings (
  id bigserial primary key,
  job_post_id uuid not null references job_posts(id) on delete cascade,
  carrier_id uuid not null references profiles(id) on delete cascade,
  lat numeric(10, 7) not null,
  lng numeric(10, 7) not null,
  accuracy_m numeric(6, 2),
  speed_kmh numeric(5, 2),
  heading_deg numeric(5, 2),
  recorded_at timestamptz not null default now()
);

-- Yalnızca aktif taşıma'da pingleme yapılması beklendiği için index iş bazlı
create index idx_location_pings_job_time on location_pings(job_post_id, recorded_at desc);
create index idx_location_pings_carrier on location_pings(carrier_id, recorded_at desc);

-- Eski ping'ler 30 gün sonra silinebilir (cron job ile, retention policy)

alter table location_pings enable row level security;

-- Nakliyeci kendi ping'ini yazar
create policy "location: carrier writes own"
  on location_pings for insert
  to authenticated
  with check (
    carrier_id = auth.uid()
    and exists (
      select 1 from job_posts jp
      join offers o on o.id = jp.accepted_offer_id
      where jp.id = location_pings.job_post_id
        and o.carrier_id = auth.uid()
        and jp.status in ('loaded', 'on_road', 'delivery_approval')
    )
  );

-- Yükveren ve nakliyeci ping'leri okur (sadece kendi job'larına ait)
create policy "location: parties read"
  on location_pings for select
  to authenticated
  using (
    exists (
      select 1 from job_posts jp
      where jp.id = location_pings.job_post_id
        and (
          jp.shipper_id = auth.uid()
          or exists (
            select 1 from offers o
            where o.id = jp.accepted_offer_id and o.carrier_id = auth.uid()
          )
        )
    )
  );
