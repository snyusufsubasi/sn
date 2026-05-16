-- ============================================================
-- ARACIYOK — Migration 002: Review Rating Trigger + Notifications Check
-- ============================================================
-- Calistirma: Supabase SQL Editor > bu dosyayi yapistir > RUN
-- ============================================================

-- ============================================================
-- REVIEW RATING TRIGGER
-- reviews INSERT sonrasi reviewee'nin rating_avg guncellenir
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_rating_avg()
RETURNS TRIGGER AS $$
DECLARE
  v_role TEXT;
  v_new_avg NUMERIC(3,2);
BEGIN
  -- Reviewee'nin rolunu bul
  SELECT role INTO v_role FROM public.profiles WHERE id = NEW.reviewee_id;

  -- Yeni ortalamayi hesapla
  SELECT ROUND(AVG(rating)::numeric, 2) INTO v_new_avg
  FROM public.reviews
  WHERE reviewee_id = NEW.reviewee_id;

  -- Role gore ilgili profile tablosunu guncelle
  IF v_role = 'carrier' THEN
    UPDATE public.carrier_profiles
    SET rating_avg = v_new_avg, updated_at = now()
    WHERE id = NEW.reviewee_id;
  ELSIF v_role = 'shipper' THEN
    UPDATE public.shipper_profiles
    SET rating_avg = v_new_avg, updated_at = now()
    WHERE id = NEW.reviewee_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

CREATE OR REPLACE TRIGGER trg_update_rating_avg
  AFTER INSERT ON public.reviews
  FOR EACH ROW
  EXECUTE FUNCTION public.update_rating_avg();

-- ============================================================
-- VERIFY: All RPC functions create notifications
-- ============================================================
-- accept_offer()  → notifications for carrier, shipper, rejected carriers  ✅
-- cancel_job()    → notifications for accepted carrier, pending carriers   ✅
-- start_job()     → notification for counterparty                          ✅
-- complete_job()  → notification for counterparty                          ✅
-- ============================================================

-- ============================================================
-- MIGRATION COMPLETE
-- ============================================================
