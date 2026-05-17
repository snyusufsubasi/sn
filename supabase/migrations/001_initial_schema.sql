-- ARACIYOK Faz 2: Temel Şema
-- Bu migration sıfırdan kurulum içindir. Mevcut bir DB'de çalıştırılmadan
-- önce eski tablolar drop edilmeli veya bu dosya skip edilmeli.

-- Extensions
create extension if not exists "uuid-ossp";
create extension if not exists postgis;

-- =========================================================================
-- ENUMs
-- =========================================================================

create type user_role as enum ('shipper', 'carrier');
create type user_type as enum ('individual', 'company');

create type job_status as enum (
  'open',
  'offer_accepted',
  'pickup_approval',
  'loaded',
  'on_road',
  'delivery_approval',
  'completed',
  'cancelled'
);

create type offer_status as enum (
  'pending',
  'accepted',
  'rejected',
  'withdrawn',
  'expired'
);

create type payment_status as enum (
  'pending',
  'held',
  'released',
  'refunded',
  'disputed'
);

create type notification_type as enum (
  'new_offer',
  'offer_accepted',
  'offer_rejected',
  'job_status_changed',
  'new_message',
  'review_received',
  'payment_received',
  'dispute_opened',
  'system'
);

-- =========================================================================
-- profiles — public profile (görünür alanlar)
-- =========================================================================

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role user_role not null,
  user_type user_type not null default 'individual',
  full_name text not null,
  city text not null,
  district text not null,
  company_name text,
  tax_number text,
  avatar_url text,
  rating_avg numeric(3, 2) not null default 0,
  completed_jobs_count integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_company_fields check (
    (user_type = 'company' and company_name is not null and tax_number is not null)
    or
    (user_type = 'individual' and tax_number is null)
  )
);

create index idx_profiles_role on profiles(role);
create index idx_profiles_city on profiles(city);

-- =========================================================================
-- profile_private_info — telefon ve hassas veri, sadece sahip görür
-- =========================================================================

create table profile_private_info (
  user_id uuid primary key references profiles(id) on delete cascade,
  phone text not null,
  identity_number text,
  identity_verified boolean not null default false,
  updated_at timestamptz not null default now()
);

-- =========================================================================
-- carrier_profiles — nakliyeci ek bilgileri
-- =========================================================================

create table carrier_profiles (
  user_id uuid primary key references profiles(id) on delete cascade,
  vehicle_type text not null,
  capacity_tons numeric(5, 2) not null,
  trailer_type text not null,
  plate text not null,
  service_regions text[] not null default '{}',
  documents_uploaded boolean not null default false,
  is_verified boolean not null default false,
  updated_at timestamptz not null default now()
);

create index idx_carrier_plate on carrier_profiles(plate);

-- =========================================================================
-- carrier_documents — sürücü belgesi, ruhsat, sigorta belgeleri
-- =========================================================================

create table carrier_documents (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  document_type text not null, -- 'license', 'vehicle_registration', 'insurance', 'k_belgesi'
  storage_path text not null,
  verified boolean not null default false,
  verified_at timestamptz,
  verified_by uuid references profiles(id),
  uploaded_at timestamptz not null default now()
);

create index idx_carrier_documents_user on carrier_documents(user_id);

-- =========================================================================
-- job_posts — yük ilanları
-- =========================================================================

create table job_posts (
  id uuid primary key default uuid_generate_v4(),
  shipper_id uuid not null references profiles(id) on delete restrict,

  -- İçerik
  title text not null,
  description text,
  cargo_type text not null,
  weight_tons numeric(6, 2) not null,
  volume_m3 numeric(6, 2),

  -- Lokasyon (genel — public görünür)
  origin_city text not null,
  origin_district text not null,
  destination_city text not null,
  destination_district text not null,

  -- Detay adresler (sadece teklif kabul edildikten sonra görünür)
  origin_address text,
  destination_address text,
  origin_lat numeric(10, 7),
  origin_lng numeric(10, 7),
  destination_lat numeric(10, 7),
  destination_lng numeric(10, 7),

  -- Tarihler ve fiyat
  pickup_date date not null,
  delivery_date date,
  preferred_trailer_type text,
  budget_min numeric(10, 2),
  budget_max numeric(10, 2),

  -- Akış
  status job_status not null default 'open',
  accepted_offer_id uuid, -- sonra unique foreign key olarak bağlanır

  -- Çift taraflı onay flag'leri
  pickup_confirmed_by_carrier boolean not null default false,
  pickup_confirmed_by_shipper boolean not null default false,
  delivery_confirmed_by_carrier boolean not null default false,
  delivery_confirmed_by_shipper boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  cancelled_at timestamptz,
  cancelled_reason text,
  cancelled_by uuid references profiles(id)
);

create index idx_job_posts_shipper on job_posts(shipper_id);
create index idx_job_posts_status on job_posts(status);
create index idx_job_posts_origin on job_posts(origin_city, origin_district);
create index idx_job_posts_destination on job_posts(destination_city, destination_district);
create index idx_job_posts_pickup_date on job_posts(pickup_date);

-- =========================================================================
-- offers — teklifler
-- =========================================================================

create table offers (
  id uuid primary key default uuid_generate_v4(),
  job_post_id uuid not null references job_posts(id) on delete cascade,
  carrier_id uuid not null references profiles(id) on delete restrict,
  price numeric(10, 2) not null,
  message text,
  status offer_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  expires_at timestamptz,

  constraint uq_offer_per_carrier unique (job_post_id, carrier_id)
);

create index idx_offers_job on offers(job_post_id);
create index idx_offers_carrier on offers(carrier_id);
create index idx_offers_status on offers(status);

-- Her ilan için tek bir 'accepted' teklif olabilir
create unique index uq_one_accepted_offer_per_job
  on offers(job_post_id)
  where status = 'accepted';

alter table job_posts
  add constraint fk_accepted_offer
  foreign key (accepted_offer_id)
  references offers(id) on delete set null;

-- =========================================================================
-- message_threads ve messages
-- =========================================================================

create table message_threads (
  id uuid primary key default uuid_generate_v4(),
  job_post_id uuid not null unique references job_posts(id) on delete cascade,
  shipper_id uuid not null references profiles(id) on delete restrict,
  carrier_id uuid not null references profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  last_message_at timestamptz
);

create index idx_threads_shipper on message_threads(shipper_id);
create index idx_threads_carrier on message_threads(carrier_id);

create table messages (
  id uuid primary key default uuid_generate_v4(),
  thread_id uuid not null references message_threads(id) on delete cascade,
  sender_id uuid not null references profiles(id) on delete restrict,
  body text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index idx_messages_thread on messages(thread_id, created_at desc);

-- =========================================================================
-- reviews — değerlendirmeler (Faz 8)
-- =========================================================================

create table reviews (
  id uuid primary key default uuid_generate_v4(),
  job_post_id uuid not null references job_posts(id) on delete cascade,
  reviewer_id uuid not null references profiles(id) on delete restrict,
  reviewee_id uuid not null references profiles(id) on delete restrict,
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),

  constraint uq_one_review_per_job_per_user unique (job_post_id, reviewer_id)
);

create index idx_reviews_reviewee on reviews(reviewee_id);

-- =========================================================================
-- notifications — bildirimler
-- =========================================================================

create table notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  type notification_type not null,
  title text not null,
  body text,
  data jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index idx_notifications_user on notifications(user_id, is_read, created_at desc);

-- =========================================================================
-- device_tokens — push notification için (Faz 7)
-- =========================================================================

create table device_tokens (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  fcm_token text not null,
  platform text not null,
  device_id text,
  created_at timestamptz not null default now(),
  last_active_at timestamptz not null default now(),

  constraint uq_device_token unique (user_id, fcm_token)
);

create index idx_device_tokens_user on device_tokens(user_id);

-- =========================================================================
-- updated_at trigger fonksiyonu
-- =========================================================================

create or replace function tg_set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_profiles_updated_at before update on profiles
  for each row execute function tg_set_updated_at();
create trigger trg_job_posts_updated_at before update on job_posts
  for each row execute function tg_set_updated_at();
create trigger trg_offers_updated_at before update on offers
  for each row execute function tg_set_updated_at();
