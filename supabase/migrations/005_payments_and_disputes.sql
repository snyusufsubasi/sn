-- ARACIYOK Faz 10: Ödeme & Escrow Şeması
-- Bu dosya Faz 10'da aktif kullanılacak, ama temel şemayı baştan kuruyoruz.

create type payment_event_type as enum (
  'created',
  'authorized',
  'captured',
  'held',
  'released',
  'refunded',
  'failed',
  'disputed'
);

-- =========================================================================
-- payments — ana ödeme kaydı (her job için tek payment)
-- =========================================================================

create table payments (
  id uuid primary key default uuid_generate_v4(),
  job_post_id uuid not null unique references job_posts(id) on delete restrict,
  offer_id uuid not null references offers(id) on delete restrict,
  shipper_id uuid not null references profiles(id) on delete restrict,
  carrier_id uuid not null references profiles(id) on delete restrict,

  amount numeric(10, 2) not null,
  commission_rate numeric(5, 4) not null default 0.0500, -- %5 default
  commission_amount numeric(10, 2) not null,
  carrier_payout numeric(10, 2) not null, -- amount - commission

  currency text not null default 'TRY',
  status payment_status not null default 'pending',

  provider text not null default 'iyzico',
  provider_payment_id text,
  provider_meta jsonb,

  created_at timestamptz not null default now(),
  authorized_at timestamptz,
  held_at timestamptz,
  released_at timestamptz,
  refunded_at timestamptz
);

create index idx_payments_status on payments(status);
create index idx_payments_shipper on payments(shipper_id);
create index idx_payments_carrier on payments(carrier_id);

-- =========================================================================
-- payment_events — audit log
-- =========================================================================

create table payment_events (
  id uuid primary key default uuid_generate_v4(),
  payment_id uuid not null references payments(id) on delete cascade,
  event_type payment_event_type not null,
  amount numeric(10, 2),
  provider_meta jsonb,
  notes text,
  created_at timestamptz not null default now()
);

create index idx_payment_events_payment on payment_events(payment_id, created_at);

-- =========================================================================
-- iyzico_callbacks — 3DS callback log
-- =========================================================================

create table iyzico_callbacks (
  id uuid primary key default uuid_generate_v4(),
  payment_id uuid references payments(id) on delete set null,
  token text not null,
  conversation_id text,
  status text,
  raw_payload jsonb not null,
  processed boolean not null default false,
  received_at timestamptz not null default now()
);

create index idx_iyzico_callbacks_token on iyzico_callbacks(token);

-- =========================================================================
-- disputes — anlaşmazlık (Faz 11 admin paneli)
-- =========================================================================

create table disputes (
  id uuid primary key default uuid_generate_v4(),
  job_post_id uuid not null references job_posts(id) on delete restrict,
  payment_id uuid references payments(id) on delete set null,
  opened_by uuid not null references profiles(id) on delete restrict,
  reason text not null,
  description text,
  evidence_urls text[] default '{}',
  status text not null default 'open', -- 'open' | 'resolved' | 'rejected'
  resolution text,
  resolved_by uuid references profiles(id),
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);

create index idx_disputes_status on disputes(status);
create index idx_disputes_job on disputes(job_post_id);

-- =========================================================================
-- admin_roles — admin paneli erişimi
-- =========================================================================

create table admin_roles (
  user_id uuid primary key references profiles(id) on delete cascade,
  role text not null default 'support', -- 'support' | 'admin' | 'finance'
  granted_at timestamptz not null default now(),
  granted_by uuid references profiles(id)
);

-- =========================================================================
-- RLS
-- =========================================================================

alter table payments enable row level security;
alter table payment_events enable row level security;
alter table iyzico_callbacks enable row level security;
alter table disputes enable row level security;
alter table admin_roles enable row level security;

create policy "payments: parties only"
  on payments for select
  to authenticated
  using (shipper_id = auth.uid() or carrier_id = auth.uid()
         or exists (select 1 from admin_roles where user_id = auth.uid()));

create policy "payment_events: via payment parties"
  on payment_events for select
  to authenticated
  using (
    exists (
      select 1 from payments p
      where p.id = payment_events.payment_id
        and (p.shipper_id = auth.uid() or p.carrier_id = auth.uid())
    )
    or exists (select 1 from admin_roles where user_id = auth.uid())
  );

-- iyzico_callbacks: sadece service_role yazar/okur (admin hariç)
create policy "iyzico_callbacks: admin only"
  on iyzico_callbacks for select
  to authenticated
  using (exists (select 1 from admin_roles where user_id = auth.uid()));

create policy "disputes: parties + admin"
  on disputes for select
  to authenticated
  using (
    opened_by = auth.uid()
    or exists (
      select 1 from job_posts jp
      where jp.id = disputes.job_post_id
        and (jp.shipper_id = auth.uid()
             or exists (
               select 1 from offers o
               where o.job_post_id = jp.id
                 and o.carrier_id = auth.uid()
                 and o.status = 'accepted'
             ))
    )
    or exists (select 1 from admin_roles where user_id = auth.uid())
  );

create policy "admin_roles: self read"
  on admin_roles for select
  to authenticated
  using (user_id = auth.uid());

-- =========================================================================
-- RPC: release_payment (Faz 10'da Edge Function ile çağrılır)
-- =========================================================================

create or replace function release_payment(p_job_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_payment payments%rowtype;
  v_job job_posts%rowtype;
  v_caller uuid := auth.uid();
  v_is_admin boolean := false;
begin
  select * into v_payment from payments where job_post_id = p_job_id;
  if not found then raise exception 'Odeme bulunamadi'; end if;

  if v_caller is null then
    raise exception 'Kimlik dogrulamasi gerekli';
  end if;

  select exists(
    select 1 from admin_roles where user_id = v_caller
  ) into v_is_admin;

  if not v_is_admin
     and v_payment.shipper_id <> v_caller
     and v_payment.carrier_id <> v_caller then
    raise exception 'Bu odemeyi serbest birakma yetkiniz yok';
  end if;

  select * into v_job from job_posts where id = p_job_id;
  if v_job.status <> 'completed' then
    raise exception 'Is tamamlanmadan odeme aktarilamaz';
  end if;

  if v_payment.status = 'released' then
    return;
  end if;

  if v_payment.status <> 'held' then
    raise exception 'Odeme escrow durumunda degil';
  end if;

  update payments
    set status = 'released',
        released_at = now()
    where id = v_payment.id;

  insert into payment_events (payment_id, event_type, amount, notes)
    values (v_payment.id, 'released', v_payment.carrier_payout,
            'Cift tarafli teslim onayindan sonra otomatik tetiklendi');

  insert into notifications (user_id, type, title, body, data)
    values (
      v_payment.carrier_id,
      'payment_received',
      'Odemen aktarildi',
      'Tasima ucretin hesabina aktarildi.',
      jsonb_build_object('payment_id', v_payment.id, 'amount', v_payment.carrier_payout)
    );
end;
$$;

revoke all on function release_payment(uuid) from public;
grant execute on function release_payment(uuid) to authenticated;
