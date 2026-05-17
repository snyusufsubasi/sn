-- ARACIYOK Faz 12 (push): device_tokens tablosu
-- Bu migration idempotent olacak şekilde yazılmıştır.

create extension if not exists pgcrypto;

-- Tablo yoksa oluştur.
create table if not exists device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null,
  platform text not null,
  device_info text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 001'den gelen eski şema ile uyumluluk düzeltmeleri.
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'device_tokens'
      and column_name = 'fcm_token'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'device_tokens'
      and column_name = 'token'
  ) then
    execute 'alter table device_tokens rename column fcm_token to token';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'device_tokens'
      and column_name = 'last_active_at'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'device_tokens'
      and column_name = 'updated_at'
  ) then
    execute 'alter table device_tokens rename column last_active_at to updated_at';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'device_tokens'
      and column_name = 'device_info'
  ) then
    execute 'alter table device_tokens add column device_info text';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'device_tokens'
      and column_name = 'is_active'
  ) then
    execute 'alter table device_tokens add column is_active boolean not null default true';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'device_tokens'
      and column_name = 'updated_at'
  ) then
    execute 'alter table device_tokens add column updated_at timestamptz not null default now()';
  end if;

  -- Eski constraint isimlerini güvenli şekilde kaldır/oluştur.
  if exists (
    select 1 from pg_constraint
    where conname = 'uq_device_token'
  ) then
    execute 'alter table device_tokens drop constraint uq_device_token';
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'device_tokens_user_token_key'
  ) then
    execute 'alter table device_tokens add constraint device_tokens_user_token_key unique (user_id, token)';
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'device_tokens_platform_check'
  ) then
    alter table device_tokens
      add constraint device_tokens_platform_check
      check (platform in ('ios', 'android', 'web'));
  end if;
end $$;

create index if not exists idx_device_tokens_user_active
  on device_tokens(user_id)
  where is_active = true;

alter table device_tokens enable row level security;

drop policy if exists "device_tokens: owner only" on device_tokens;
drop policy if exists "device_tokens: owner select" on device_tokens;
drop policy if exists "device_tokens: owner insert" on device_tokens;
drop policy if exists "device_tokens: owner update" on device_tokens;
drop policy if exists "device_tokens: owner delete" on device_tokens;
drop policy if exists "device_tokens: service role full" on device_tokens;

create policy "device_tokens: owner select"
  on device_tokens for select
  to authenticated
  using (user_id = auth.uid());

create policy "device_tokens: owner insert"
  on device_tokens for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "device_tokens: owner update"
  on device_tokens for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "device_tokens: owner delete"
  on device_tokens for delete
  to authenticated
  using (user_id = auth.uid());

create policy "device_tokens: service role full"
  on device_tokens for all
  to service_role
  using (true)
  with check (true);
