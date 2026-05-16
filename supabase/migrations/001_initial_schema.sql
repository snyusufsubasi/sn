-- ============================================================
-- ARACIYOK — Initial Database Migration
-- ============================================================
-- Calistirma: Supabase SQL Editor > bu dosyayi yapistir > RUN
-- veya: supabase db push (local dev)
-- ============================================================

-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUM TYPES
-- ============================================================
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('shipper', 'carrier');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE job_status AS ENUM ('open', 'offer_accepted', 'in_progress', 'completed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE offer_status AS ENUM ('pending', 'accepted', 'rejected', 'withdrawn', 'expired');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE cargo_type AS ENUM ('ev_esyasi', 'parca_esya', 'paletli_urun', 'insaat_malzemesi', 'makine', 'mobilya', 'gida_disi', 'diger');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE urgency_level AS ENUM ('normal', 'urgent', 'very_urgent');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE report_status AS ENUM ('open', 'investigating', 'resolved', 'dismissed');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================
-- 1. profiles (PUBLIC)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role       user_role NOT NULL,
  full_name  TEXT NOT NULL,
  city       TEXT NOT NULL,
  district   TEXT NOT NULL,
  avatar_url TEXT,
  is_active  BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles public select"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Profiles insert by owner"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Profiles update by owner"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================================
-- 2. profile_private_info (PRIVATE)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profile_private_info (
  user_id    UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  phone      TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.profile_private_info ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Phone select self and accepted match"
  ON public.profile_private_info FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.offers o
      JOIN public.job_posts j ON j.id = o.job_post_id
      WHERE o.carrier_id = auth.uid()
        AND j.shipper_id = profile_private_info.user_id
        AND o.status = 'accepted'
        AND j.status IN ('offer_accepted','in_progress','completed')
    )
    OR EXISTS (
      SELECT 1 FROM public.offers o
      JOIN public.job_posts j ON j.id = o.job_post_id
      WHERE j.shipper_id = auth.uid()
        AND o.carrier_id = profile_private_info.user_id
        AND o.status = 'accepted'
        AND j.status IN ('offer_accepted','in_progress','completed')
    )
  );

CREATE POLICY "Phone insert by owner"
  ON public.profile_private_info FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Phone update by owner"
  ON public.profile_private_info FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 3. shipper_profiles (PUBLIC)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.shipper_profiles (
  id                   UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  company_name         TEXT,
  user_type            TEXT DEFAULT 'individual' CHECK (user_type IN ('individual','company')),
  rating_avg           NUMERIC(3,2) DEFAULT 0,
  completed_jobs_count INT DEFAULT 0,
  created_at           TIMESTAMPTZ DEFAULT now(),
  updated_at           TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.shipper_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Shipper profiles public select"
  ON public.shipper_profiles FOR SELECT
  USING (true);

CREATE POLICY "Shipper profiles insert by owner"
  ON public.shipper_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Shipper profiles update by owner"
  ON public.shipper_profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================================
-- 4. carrier_profiles (PUBLIC)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.carrier_profiles (
  id                   UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  company_name         TEXT,
  vehicle_type         TEXT NOT NULL,
  capacity_text        TEXT,
  service_areas        TEXT[] DEFAULT '{}',
  job_type_preferences TEXT[] DEFAULT '{}',
  vehicle_photo_url    TEXT,
  is_verified          BOOLEAN DEFAULT false,
  rating_avg           NUMERIC(3,2) DEFAULT 0,
  completed_jobs_count INT DEFAULT 0,
  created_at           TIMESTAMPTZ DEFAULT now(),
  updated_at           TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.carrier_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Carrier profiles public select"
  ON public.carrier_profiles FOR SELECT
  USING (true);

CREATE POLICY "Carrier profiles insert by owner"
  ON public.carrier_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Carrier profiles update by owner"
  ON public.carrier_profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================================
-- 5. carrier_private_info (PRIVATE)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.carrier_private_info (
  carrier_id   UUID PRIMARY KEY REFERENCES public.carrier_profiles(id) ON DELETE CASCADE,
  plate_number TEXT NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.carrier_private_info ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Plate select self and accepted match"
  ON public.carrier_private_info FOR SELECT
  USING (
    auth.uid() = carrier_id
    OR EXISTS (
      SELECT 1 FROM public.offers o
      JOIN public.job_posts j ON j.id = o.job_post_id
      WHERE j.shipper_id = auth.uid()
        AND o.carrier_id = carrier_private_info.carrier_id
        AND o.status = 'accepted'
        AND j.status IN ('offer_accepted','in_progress','completed')
    )
  );

CREATE POLICY "Plate insert by owner"
  ON public.carrier_private_info FOR INSERT
  WITH CHECK (auth.uid() = carrier_id);

CREATE POLICY "Plate update by owner"
  ON public.carrier_private_info FOR UPDATE
  USING (auth.uid() = carrier_id)
  WITH CHECK (auth.uid() = carrier_id);

-- ============================================================
-- 6. job_posts (PUBLIC)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.job_posts (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipper_id         UUID NOT NULL REFERENCES public.profiles(id),
  cargo_type         cargo_type NOT NULL,
  cargo_description  TEXT,
  pickup_city        TEXT NOT NULL,
  pickup_district    TEXT NOT NULL,
  delivery_city      TEXT NOT NULL,
  delivery_district  TEXT NOT NULL,
  pickup_date        DATE NOT NULL,
  pickup_time_window TEXT,
  is_date_flexible   BOOLEAN DEFAULT false,
  urgency_level      urgency_level DEFAULT 'normal',
  extra_notes        TEXT,
  status             job_status DEFAULT 'open',
  accepted_offer_id  UUID,
  cancelled_reason   TEXT,
  created_at         TIMESTAMPTZ DEFAULT now(),
  updated_at         TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.job_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Job posts public select"
  ON public.job_posts FOR SELECT
  USING (true);

CREATE POLICY "Job posts insert by shipper"
  ON public.job_posts FOR INSERT
  WITH CHECK (
    auth.uid() = shipper_id
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'shipper'
    )
  );

CREATE POLICY "Job posts update by owner"
  ON public.job_posts FOR UPDATE
  USING (auth.uid() = shipper_id)
  WITH CHECK (auth.uid() = shipper_id);

CREATE POLICY "Job posts delete by owner"
  ON public.job_posts FOR DELETE
  USING (auth.uid() = shipper_id);

-- ============================================================
-- 7. job_private_info (PRIVATE)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.job_private_info (
  job_post_id      UUID PRIMARY KEY REFERENCES public.job_posts(id) ON DELETE CASCADE,
  pickup_address   TEXT,
  delivery_address TEXT,
  created_at       TIMESTAMPTZ DEFAULT now(),
  updated_at       TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.job_private_info ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Address select owner and accepted carrier"
  ON public.job_private_info FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_private_info.job_post_id
        AND j.shipper_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.job_posts j
      JOIN public.offers o ON o.job_post_id = j.id
      WHERE j.id = job_private_info.job_post_id
        AND o.carrier_id = auth.uid()
        AND o.status = 'accepted'
        AND j.status IN ('offer_accepted','in_progress','completed')
    )
  );

CREATE POLICY "Address insert by job owner"
  ON public.job_private_info FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_post_id AND j.shipper_id = auth.uid()
    )
  );

CREATE POLICY "Address update by job owner"
  ON public.job_private_info FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_post_id AND j.shipper_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_post_id AND j.shipper_id = auth.uid()
    )
  );

-- ============================================================
-- 8. job_photos
-- ============================================================
CREATE TABLE IF NOT EXISTS public.job_photos (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_post_id  UUID NOT NULL REFERENCES public.job_posts(id) ON DELETE CASCADE,
  photo_url    TEXT NOT NULL,
  storage_path TEXT,
  created_at   TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.job_photos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Job photos public select"
  ON public.job_photos FOR SELECT
  USING (true);

CREATE POLICY "Job photos insert by job owner"
  ON public.job_photos FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_post_id AND j.shipper_id = auth.uid()
    )
  );

CREATE POLICY "Job photos delete by job owner"
  ON public.job_photos FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_post_id AND j.shipper_id = auth.uid()
    )
  );

-- ============================================================
-- 9. offers
-- ============================================================
CREATE TABLE IF NOT EXISTS public.offers (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_post_id  UUID NOT NULL REFERENCES public.job_posts(id),
  carrier_id   UUID NOT NULL REFERENCES public.profiles(id),
  amount       NUMERIC(12,2) NOT NULL,
  currency     TEXT DEFAULT 'TRY',
  note         TEXT,
  available_at TEXT,
  status       offer_status DEFAULT 'pending',
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT chk_offers_amount_positive CHECK (amount > 0)
);

ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;

-- Partial unique: ayni ilana ayni nakliyeciden sadece 1 aktif (pending/accepted) teklif
-- Withdrawn/rejected/expired sonrasi ayni ilana tekrar teklif verilebilir
CREATE UNIQUE INDEX IF NOT EXISTS idx_offers_active_unique
  ON public.offers(job_post_id, carrier_id)
  WHERE status IN ('pending', 'accepted');

CREATE POLICY "Offers select involved"
  ON public.offers FOR SELECT
  USING (
    carrier_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = offers.job_post_id AND j.shipper_id = auth.uid()
    )
  );

CREATE POLICY "Offers insert strict"
  ON public.offers FOR INSERT
  WITH CHECK (
    auth.uid() = carrier_id
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'carrier'
    )
    AND EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_post_id
        AND j.status = 'open'
        AND j.shipper_id != auth.uid()
    )
    AND NOT EXISTS (
      SELECT 1 FROM public.offers o
      WHERE o.job_post_id = job_post_id
        AND o.carrier_id = auth.uid()
        AND o.status IN ('pending','accepted')
    )
  );

CREATE POLICY "Offers update own pending only"
  ON public.offers FOR UPDATE
  USING (
    auth.uid() = carrier_id
    AND status = 'pending'
  )
  WITH CHECK (
    auth.uid() = carrier_id
    AND status IN ('pending','withdrawn')
  );

-- ============================================================
-- 10. job_status_history (INSERT blocked from API)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.job_status_history (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_post_id UUID NOT NULL REFERENCES public.job_posts(id) ON DELETE CASCADE,
  status      TEXT NOT NULL,
  changed_by  UUID REFERENCES auth.users(id),
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.job_status_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "History select involved"
  ON public.job_status_history FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_status_history.job_post_id
        AND (j.shipper_id = auth.uid()
          OR EXISTS (
            SELECT 1 FROM public.offers o
            WHERE o.job_post_id = j.id
              AND o.carrier_id = auth.uid()
              AND o.status = 'accepted'
          ))
    )
  );

-- Direct insert from API is blocked
CREATE POLICY "History insert blocked"
  ON public.job_status_history FOR INSERT
  WITH CHECK (false);

-- ============================================================
-- 11. reviews
-- ============================================================
CREATE TABLE IF NOT EXISTS public.reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_post_id UUID NOT NULL REFERENCES public.job_posts(id),
  reviewer_id UUID NOT NULL REFERENCES public.profiles(id),
  reviewee_id UUID NOT NULL REFERENCES public.profiles(id),
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE(job_post_id, reviewer_id, reviewee_id)
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reviews public select"
  ON public.reviews FOR SELECT
  USING (true);

CREATE POLICY "Reviews insert strict"
  ON public.reviews FOR INSERT
  WITH CHECK (
    auth.uid() = reviewer_id
    AND EXISTS (
      SELECT 1 FROM public.job_posts j
      WHERE j.id = job_post_id AND j.status = 'completed'
    )
    AND (
      (reviewer_id = (SELECT j2.shipper_id FROM public.job_posts j2 WHERE j2.id = job_post_id)
       AND reviewee_id = (SELECT o.carrier_id FROM public.offers o
                          WHERE o.job_post_id = job_post_id AND o.status = 'accepted' LIMIT 1))
      OR
      (reviewer_id = (SELECT o2.carrier_id FROM public.offers o2
                      WHERE o2.job_post_id = job_post_id AND o2.status = 'accepted' LIMIT 1)
       AND reviewee_id = (SELECT j3.shipper_id FROM public.job_posts j3 WHERE j3.id = job_post_id))
    )
  );

-- ============================================================
-- 12. notifications (INSERT blocked from API)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  type            TEXT NOT NULL,
  related_job_id  UUID,
  related_offer_id UUID,
  is_read         BOOLEAN DEFAULT false,
  created_at      TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Notifications select by owner"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Notifications update by owner"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Direct insert from API is blocked
CREATE POLICY "Notifications insert blocked"
  ON public.notifications FOR INSERT
  WITH CHECK (false);

-- ============================================================
-- 13. reports
-- ============================================================
CREATE TABLE IF NOT EXISTS public.reports (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id      UUID NOT NULL REFERENCES public.profiles(id),
  reported_user_id UUID,
  job_post_id      UUID,
  reason           TEXT NOT NULL,
  description      TEXT,
  status           report_status DEFAULT 'open',
  created_at       TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reports select by reporter"
  ON public.reports FOR SELECT
  USING (auth.uid() = reporter_id);

CREATE POLICY "Reports insert by reporter"
  ON public.reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);

-- ============================================================
-- 14. support_tickets
-- ============================================================
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id),
  category    TEXT NOT NULL,
  subject     TEXT NOT NULL,
  description TEXT,
  status      TEXT DEFAULT 'open',
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tickets select by owner"
  ON public.support_tickets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Tickets insert by owner"
  ON public.support_tickets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- FOREIGN KEY: job_posts.accepted_offer_id -> offers.id
-- ============================================================
DO $$ BEGIN
  ALTER TABLE public.job_posts
    ADD CONSTRAINT fk_job_posts_accepted_offer
    FOREIGN KEY (accepted_offer_id) REFERENCES public.offers(id)
    ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================
-- TRIGGER: Prevent direct status/accepted_offer_id changes
-- Only RPC functions (which set app.rpc_action) can change these
-- ============================================================
CREATE OR REPLACE FUNCTION public.prevent_direct_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF current_setting('app.rpc_action', true) IS NULL THEN
    IF NEW.status IS DISTINCT FROM OLD.status
       OR NEW.accepted_offer_id IS DISTINCT FROM OLD.accepted_offer_id THEN
      RAISE EXCEPTION 'Bu alanlari dogrudan degistiremezsiniz. Lutfen ilgili islem dugmesini kullanin.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_prevent_direct_status_change
  BEFORE UPDATE ON public.job_posts
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_direct_status_change();

-- ============================================================
-- RPC FUNCTION: accept_offer(p_offer_id)
-- ============================================================
CREATE OR REPLACE FUNCTION public.accept_offer(p_offer_id UUID)
RETURNS void AS $$
DECLARE
  v_job_post_id      UUID;
  v_job_shipper_id   UUID;
  v_job_status       job_status;
  v_offer_status     offer_status;
  v_offer_carrier_id UUID;
  v_offer_amount     NUMERIC;
BEGIN
  SELECT o.job_post_id, o.status, o.carrier_id, o.amount,
         j.shipper_id, j.status
  INTO v_job_post_id, v_offer_status, v_offer_carrier_id, v_offer_amount,
       v_job_shipper_id, v_job_status
  FROM public.offers o
  JOIN public.job_posts j ON j.id = o.job_post_id
  WHERE o.id = p_offer_id;

  IF v_job_post_id IS NULL THEN
    RAISE EXCEPTION 'Teklif bulunamadi.';
  END IF;

  IF v_job_shipper_id != auth.uid() THEN
    RAISE EXCEPTION 'Bu islemi yalnizca ilan sahibi yapabilir.';
  END IF;

  IF v_job_status != 'open' THEN
    RAISE EXCEPTION 'Bu ilan artik acik degil. Mevcut durum: %', v_job_status;
  END IF;

  IF v_offer_status != 'pending' THEN
    RAISE EXCEPTION 'Bu teklif artik beklemede degil. Mevcut durum: %', v_offer_status;
  END IF;

  -- Signal the trigger to allow status change
  PERFORM set_config('app.rpc_action', 'accept_offer', true);

  -- Atomik islem
  UPDATE public.job_posts
  SET status = 'offer_accepted',
      accepted_offer_id = p_offer_id,
      updated_at = now()
  WHERE id = v_job_post_id;

  UPDATE public.offers
  SET status = 'accepted', updated_at = now()
  WHERE id = p_offer_id;

  UPDATE public.offers
  SET status = 'rejected', updated_at = now()
  WHERE job_post_id = v_job_post_id
    AND id != p_offer_id
    AND status = 'pending';

  -- Status history
  INSERT INTO public.job_status_history (job_post_id, status, changed_by)
  VALUES (v_job_post_id, 'offer_accepted', auth.uid());

  -- Notification: accepted carrier
  INSERT INTO public.notifications (user_id, title, body, type, related_job_id, related_offer_id)
  VALUES (
    v_offer_carrier_id,
    'Teklifiniz Kabul Edildi',
    'Ilan sahibi teklifinizi kabul etti. Iletisim bilgilerini gorebilirsiniz.',
    'offer_accepted',
    v_job_post_id,
    p_offer_id
  );

  -- Notification: rejected carriers
  INSERT INTO public.notifications (user_id, title, body, type, related_job_id)
  SELECT o.carrier_id,
         'Ilan Kapandi',
         'Teklif verdiginiz bir ilan baska bir nakliyeciye verildi.',
         'offer_rejected',
         v_job_post_id
  FROM public.offers o
  WHERE o.job_post_id = v_job_post_id
    AND o.status = 'rejected'
    AND o.carrier_id != v_offer_carrier_id;

  -- Notification: shipper
  INSERT INTO public.notifications (user_id, title, body, type, related_job_id)
  VALUES (
    v_job_shipper_id,
    'Nakliyeci Secildi',
    'Nakliyeci seciminiz tamamlandi. Iletisim bilgilerini gorebilirsiniz.',
    'offer_accepted',
    v_job_post_id
  );

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

REVOKE ALL ON FUNCTION public.accept_offer(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.accept_offer(UUID) TO authenticated;

-- ============================================================
-- RPC FUNCTION: cancel_job(p_job_post_id, p_reason)
-- ============================================================
CREATE OR REPLACE FUNCTION public.cancel_job(p_job_post_id UUID, p_reason TEXT DEFAULT NULL)
RETURNS void AS $$
DECLARE
  v_job_shipper_id UUID;
  v_job_status     job_status;
  v_accepted_carrier_id UUID;
BEGIN
  SELECT j.shipper_id, j.status, o.carrier_id
  INTO v_job_shipper_id, v_job_status, v_accepted_carrier_id
  FROM public.job_posts j
  LEFT JOIN public.offers o ON o.id = j.accepted_offer_id
  WHERE j.id = p_job_post_id;

  IF v_job_shipper_id IS NULL THEN
    RAISE EXCEPTION 'Ilan bulunamadi.';
  END IF;

  IF v_job_shipper_id != auth.uid() THEN
    RAISE EXCEPTION 'Bu islemi yalnizca ilan sahibi yapabilir.';
  END IF;

  IF v_job_status NOT IN ('open', 'offer_accepted') THEN
    RAISE EXCEPTION 'Bu ilan iptal edilemez. Mevcut durum: %', v_job_status;
  END IF;

  PERFORM set_config('app.rpc_action', 'cancel_job', true);

  UPDATE public.job_posts
  SET status = 'cancelled',
      cancelled_reason = p_reason,
      updated_at = now()
  WHERE id = p_job_post_id;

  -- Reject all pending offers
  UPDATE public.offers
  SET status = 'rejected', updated_at = now()
  WHERE job_post_id = p_job_post_id AND status = 'pending';

  -- Reject accepted offer if exists
  IF v_accepted_carrier_id IS NOT NULL THEN
    UPDATE public.offers
    SET status = 'rejected', updated_at = now()
    WHERE id = (SELECT accepted_offer_id FROM public.job_posts WHERE id = p_job_post_id);
  END IF;

  INSERT INTO public.job_status_history (job_post_id, status, changed_by, note)
  VALUES (p_job_post_id, 'cancelled', auth.uid(), p_reason);

  -- Notification to accepted carrier
  IF v_accepted_carrier_id IS NOT NULL THEN
    INSERT INTO public.notifications (user_id, title, body, type, related_job_id)
    VALUES (
      v_accepted_carrier_id,
      'Ilan Iptal Edildi',
      'Kabul edilmis bir ilan iptal edildi.',
      'job_cancelled',
      p_job_post_id
    );
  END IF;

  -- Notification to pending carriers
  INSERT INTO public.notifications (user_id, title, body, type, related_job_id)
  SELECT o.carrier_id,
         'Ilan Iptal Edildi',
         'Teklif verdiginiz bir ilan iptal edildi.',
         'job_cancelled',
         p_job_post_id
  FROM public.offers o
  WHERE o.job_post_id = p_job_post_id
    AND o.status = 'rejected'
    AND o.carrier_id IS DISTINCT FROM v_accepted_carrier_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

REVOKE ALL ON FUNCTION public.cancel_job(UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cancel_job(UUID, TEXT) TO authenticated;

-- ============================================================
-- RPC FUNCTION: start_job(p_job_post_id)
-- ============================================================
CREATE OR REPLACE FUNCTION public.start_job(p_job_post_id UUID)
RETURNS void AS $$
DECLARE
  v_job_shipper_id UUID;
  v_job_status     job_status;
  v_accepted_carrier_id UUID;
  v_notify_user_id UUID;
BEGIN
  SELECT j.shipper_id, j.status, o.carrier_id
  INTO v_job_shipper_id, v_job_status, v_accepted_carrier_id
  FROM public.job_posts j
  LEFT JOIN public.offers o ON o.id = j.accepted_offer_id
  WHERE j.id = p_job_post_id;

  IF v_job_shipper_id IS NULL THEN
    RAISE EXCEPTION 'Ilan bulunamadi.';
  END IF;

  IF auth.uid() != v_job_shipper_id AND auth.uid() != v_accepted_carrier_id THEN
    RAISE EXCEPTION 'Bu islemi yalnizca ilan sahibi veya kabul edilen nakliyeci yapabilir.';
  END IF;

  IF v_job_status != 'offer_accepted' THEN
    RAISE EXCEPTION 'Tasimaya baslamak icin ilan durumu "Nakliyeci Secildi" olmalidir. Mevcut: %', v_job_status;
  END IF;

  PERFORM set_config('app.rpc_action', 'start_job', true);

  UPDATE public.job_posts
  SET status = 'in_progress', updated_at = now()
  WHERE id = p_job_post_id;

  INSERT INTO public.job_status_history (job_post_id, status, changed_by)
  VALUES (p_job_post_id, 'in_progress', auth.uid());

  -- Bildirim karsi tarafa
  IF auth.uid() = v_job_shipper_id THEN
    v_notify_user_id := v_accepted_carrier_id;
  ELSE
    v_notify_user_id := v_job_shipper_id;
  END IF;

  INSERT INTO public.notifications (user_id, title, body, type, related_job_id)
  VALUES (
    v_notify_user_id,
    'Tasima Basladi',
    'Tasima sureci baslatildi.',
    'status_change',
    p_job_post_id
  );

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

REVOKE ALL ON FUNCTION public.start_job(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.start_job(UUID) TO authenticated;

-- ============================================================
-- RPC FUNCTION: complete_job(p_job_post_id)
-- ============================================================
CREATE OR REPLACE FUNCTION public.complete_job(p_job_post_id UUID)
RETURNS void AS $$
DECLARE
  v_job_shipper_id UUID;
  v_job_status     job_status;
  v_accepted_carrier_id UUID;
  v_notify_user_id UUID;
BEGIN
  SELECT j.shipper_id, j.status, o.carrier_id
  INTO v_job_shipper_id, v_job_status, v_accepted_carrier_id
  FROM public.job_posts j
  LEFT JOIN public.offers o ON o.id = j.accepted_offer_id
  WHERE j.id = p_job_post_id;

  IF v_job_shipper_id IS NULL THEN
    RAISE EXCEPTION 'Ilan bulunamadi.';
  END IF;

  IF auth.uid() != v_job_shipper_id AND auth.uid() != v_accepted_carrier_id THEN
    RAISE EXCEPTION 'Bu islemi yalnizca ilan sahibi veya kabul edilen nakliyeci yapabilir.';
  END IF;

  IF v_job_status != 'in_progress' THEN
    RAISE EXCEPTION 'Tamamlamak icin ilan durumu "Tasima Devam Ediyor" olmalidir. Mevcut: %', v_job_status;
  END IF;

  PERFORM set_config('app.rpc_action', 'complete_job', true);

  UPDATE public.job_posts
  SET status = 'completed', updated_at = now()
  WHERE id = p_job_post_id;

  -- Completed job counts
  UPDATE public.shipper_profiles
  SET completed_jobs_count = completed_jobs_count + 1, updated_at = now()
  WHERE id = v_job_shipper_id;

  UPDATE public.carrier_profiles
  SET completed_jobs_count = completed_jobs_count + 1, updated_at = now()
  WHERE id = v_accepted_carrier_id;

  INSERT INTO public.job_status_history (job_post_id, status, changed_by)
  VALUES (p_job_post_id, 'completed', auth.uid());

  -- Bildirim karsi tarafa
  IF auth.uid() = v_job_shipper_id THEN
    v_notify_user_id := v_accepted_carrier_id;
  ELSE
    v_notify_user_id := v_job_shipper_id;
  END IF;

  INSERT INTO public.notifications (user_id, title, body, type, related_job_id)
  VALUES (
    v_notify_user_id,
    'Is Tamamlandi',
    'Is tamamlandi olarak isaretlendi. Simdi degerlendirme yapabilirsiniz.',
    'status_change',
    p_job_post_id
  );

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

REVOKE ALL ON FUNCTION public.complete_job(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.complete_job(UUID) TO authenticated;

-- ============================================================
-- CONSTRAINT SUMMARY (defense-in-depth)
-- ============================================================
-- PK constraints (all auto-UNIQUE):
--   profiles.id, profile_private_info.user_id
--   shipper_profiles.id, carrier_profiles.id
--   carrier_private_info.carrier_id, job_private_info.job_post_id
--   job_posts.id, job_photos.id, offers.id
--   job_status_history.id, reviews.id
--   notifications.id, reports.id, support_tickets.id
--
-- CHECK constraints:
--   chk_offers_amount_positive: offers.amount > 0
--   reviews.rating BETWEEN 1 AND 5
--   shipper_profiles.user_type IN ('individual','company')
--
-- UNIQUE indexes:
--   idx_offers_active_unique: UNIQUE(job_post_id, carrier_id) WHERE status IN ('pending','accepted')
--   reviews: UNIQUE(job_post_id, reviewer_id, reviewee_id)
--
-- TRIGGER:
--   trg_prevent_direct_status_change: blocks direct status/accepted_offer_id API updates
--   Allowed only via RPC functions that set app.rpc_action
--
-- RPC function compatibility with constraints:
--   accept_offer: rejects other offers (status→rejected), rows leave partial unique index → valid
--   cancel_job: rejects pending/accepted offers (status→rejected) → valid
--   start_job / complete_job: only change job_posts.status → valid
--   Re-bid after withdrawal: withdrawn status not in partial unique index → valid
--
-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_job_posts_status ON public.job_posts(status);
CREATE INDEX IF NOT EXISTS idx_job_posts_shipper ON public.job_posts(shipper_id);
CREATE INDEX IF NOT EXISTS idx_job_posts_cities ON public.job_posts(pickup_city, delivery_city);
CREATE INDEX IF NOT EXISTS idx_job_posts_accepted_offer ON public.job_posts(accepted_offer_id) WHERE accepted_offer_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_offers_job ON public.offers(job_post_id);
CREATE INDEX IF NOT EXISTS idx_offers_carrier ON public.offers(carrier_id);
CREATE INDEX IF NOT EXISTS idx_offers_status ON public.offers(status);
CREATE INDEX IF NOT EXISTS idx_offers_job_carrier ON public.offers(job_post_id, carrier_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read) WHERE NOT is_read;
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee ON public.reviews(reviewee_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON public.reports(reporter_id);

-- ============================================================
-- STORAGE: job-photos bucket and policies
-- ============================================================
-- Bucket is created via Supabase Dashboard or Management API
-- (SQL CREATE BUCKET is not available in Supabase PostgreSQL).
-- After creating the bucket, run these policies in SQL Editor:
--
-- Bucket: job-photos
-- Public: YES
-- Allowed MIME types: image/jpeg, image/png, image/webp
-- File size limit: 5 MB
--
-- Path convention used by Flutter client:
--   {user_id}/{job_post_id}/{uuid}.jpg
-- Example:
--   abc123-def-ghi/xyz789-uvw/550e8400-e29b.jpg
--   (storage.foldername(name))[1] = user_id
--   (storage.foldername(name))[2] = job_post_id
--
-- ========== RUN THESE IN SQL EDITOR AFTER BUCKET CREATION ==========

-- POLICY 1: Herkes okuyabilir
CREATE POLICY "Photos public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'job-photos');

-- POLICY 2: Sadece kendi user_id klasorune, sadece kendi ilanina
CREATE POLICY "Photos upload own folder and own job"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'job-photos'
    AND auth.role() = 'authenticated'
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND EXISTS (
      SELECT 1 FROM public.job_posts jp
      WHERE jp.id::text = (storage.foldername(name))[2]
        AND jp.shipper_id = auth.uid()
    )
  );

-- POLICY 3: Sadece kendi klasorundekini silebilir
CREATE POLICY "Photos delete own"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'job-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- POLICY 4: Sadece kendi klasorundekini guncelleyebilir
CREATE POLICY "Photos update own"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'job-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================================
-- MIGRATION COMPLETE
-- ============================================================
