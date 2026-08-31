-- ═══════════════════════════════════════════════════════════════════════════════
-- DisasterLink — Supabase Schema Setup Script
-- ═══════════════════════════════════════════════════════════════════════════════
-- Run this SQL in the Supabase SQL Editor (Dashboard → SQL Editor → New Query)
-- before using the app. This creates all tables, functions, triggers, and RLS.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ── Step 0: Enable PostGIS extension ─────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS postgis;

-- ── Step 1: Volunteer Profiles ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS volunteer_profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT NOT NULL,
  phone       TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE volunteer_profiles ENABLE ROW LEVEL SECURITY;

-- Volunteers can read their own profile
CREATE POLICY "volunteer_read_own" ON volunteer_profiles
  FOR SELECT USING (auth.uid() = id);

-- Volunteers can insert their own profile (on signup)
CREATE POLICY "volunteer_insert_own" ON volunteer_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Volunteers can update their own profile
CREATE POLICY "volunteer_update_own" ON volunteer_profiles
  FOR UPDATE USING (auth.uid() = id);

-- ── Step 2: Markers Table ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS markers (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type        TEXT NOT NULL CHECK (type IN ('food','shelter','danger','medical','grocery')),
  location    GEOGRAPHY(POINT, 4326) NOT NULL,
  title       TEXT NOT NULL,
  description TEXT,
  created_by  UUID REFERENCES volunteer_profiles(id),
  created_at  TIMESTAMPTZ DEFAULT now(),
  is_active   BOOLEAN DEFAULT true
);

CREATE INDEX IF NOT EXISTS markers_location_idx ON markers USING GIST(location);
CREATE INDEX IF NOT EXISTS markers_type_idx ON markers(type);

ALTER TABLE markers ENABLE ROW LEVEL SECURITY;

-- Public can read all markers
CREATE POLICY "markers_public_read" ON markers
  FOR SELECT USING (true);

-- Only verified volunteers can insert markers
CREATE POLICY "markers_volunteer_insert" ON markers
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM volunteer_profiles
      WHERE id = auth.uid() AND is_verified = true
    )
  );

-- Only the creator can update their own markers
CREATE POLICY "markers_creator_update" ON markers
  FOR UPDATE USING (auth.uid() = created_by);

-- ── Step 3: Help Requests (PUBLIC — safe, coarse data only) ──────────────────
CREATE TABLE IF NOT EXISTS help_requests (
  id                 UUID PRIMARY KEY,
  help_type          TEXT NOT NULL CHECK (help_type IN ('food','medical','rescue','shelter','other')),
  location_coarse    GEOGRAPHY(POINT, 4326),
  status             TEXT DEFAULT 'pending' CHECK (status IN ('pending','accepted','resolved')),
  accepted_by        UUID REFERENCES volunteer_profiles(id),
  request_token      UUID NOT NULL,
  device_fingerprint TEXT,
  created_at         TIMESTAMPTZ DEFAULT now(),
  synced_at          TIMESTAMPTZ
);

ALTER TABLE help_requests ENABLE ROW LEVEL SECURITY;

-- Safe to expose: no sensitive columns in this table
CREATE POLICY "help_requests_public_read" ON help_requests
  FOR SELECT USING (true);

-- All inserts go through submit_help_request() function
CREATE POLICY "help_requests_no_direct_insert" ON help_requests
  FOR INSERT WITH CHECK (false);

-- Accept: only verified volunteers, only pending requests
CREATE POLICY "help_requests_volunteer_accept" ON help_requests
  FOR UPDATE USING (
    auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM volunteer_profiles
      WHERE id = auth.uid() AND is_verified = true
    )
  )
  WITH CHECK (status = 'pending');

-- ── Step 4: Help Request Private (sensitive data — NO public access) ─────────
CREATE TABLE IF NOT EXISTS help_request_private (
  request_id     UUID PRIMARY KEY REFERENCES help_requests(id) ON DELETE CASCADE,
  requester_name TEXT NOT NULL,
  location       GEOGRAPHY(POINT, 4326) NOT NULL,
  description    TEXT
);

CREATE INDEX IF NOT EXISTS hrp_location_idx ON help_request_private USING GIST(location);

ALTER TABLE help_request_private ENABLE ROW LEVEL SECURITY;

-- Deny all direct access — only SECURITY DEFINER functions can read
CREATE POLICY "private_deny_all" ON help_request_private
  FOR ALL USING (false);

-- ── Step 5: BT Sync Log ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bt_sync_log (
  payload_hash TEXT PRIMARY KEY,
  device_id    TEXT,
  synced_at    TIMESTAMPTZ DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECURITY DEFINER FUNCTIONS
-- These are the ONLY access paths to help_request_private data
-- ═══════════════════════════════════════════════════════════════════════════════

-- ── Function: Submit Help Request (atomic dual-table insert) ─────────────────
CREATE OR REPLACE FUNCTION submit_help_request(
  p_id                 UUID,
  p_help_type          TEXT,
  p_lat                FLOAT,
  p_lng                FLOAT,
  p_requester_name     TEXT,
  p_description        TEXT,
  p_request_token      UUID,
  p_device_fingerprint TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_point  GEOGRAPHY := ST_MakePoint(p_lng, p_lat)::geography;
  v_coarse GEOGRAPHY := ST_MakePoint(
    ROUND(p_lng::numeric, 2), ROUND(p_lat::numeric, 2)
  )::geography;
BEGIN
  -- Rate-limit: 1 active request per device
  IF EXISTS (
    SELECT 1 FROM help_requests
    WHERE device_fingerprint = p_device_fingerprint
      AND status IN ('pending','accepted')
  ) THEN
    RAISE EXCEPTION 'RATE_LIMIT: Device already has an active help request';
  END IF;

  -- Atomic dual-table insert
  INSERT INTO help_requests(id, help_type, location_coarse, status, request_token, device_fingerprint)
  VALUES (p_id, p_help_type, v_coarse, 'pending', p_request_token, p_device_fingerprint);

  INSERT INTO help_request_private(request_id, requester_name, location, description)
  VALUES (p_id, p_requester_name, v_point, p_description);
END;
$$;

-- ── Function: Get Pending Requests for Verified Volunteer ────────────────────
-- This is the ONLY data path for help_requests_screen.dart
-- DELIBERATE DECISION: requester_name IS shown at pending stage
CREATE OR REPLACE FUNCTION get_pending_requests_for_volunteer(
  v_lat      FLOAT,
  v_lng      FLOAT,
  v_radius_m INT DEFAULT 5000
)
RETURNS TABLE(
  id             UUID,
  requester_name TEXT,
  help_type      TEXT,
  status         TEXT,
  dist_meters    FLOAT,
  created_at     TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Server-side volunteer verification
  IF NOT EXISTS (
    SELECT 1 FROM volunteer_profiles
    WHERE id = auth.uid() AND is_verified = true
  ) THEN
    RAISE EXCEPTION 'AUTH_ERROR: Not an authorized volunteer';
  END IF;

  RETURN QUERY
  SELECT
    hr.id,
    hp.requester_name,
    hr.help_type,
    hr.status,
    ST_Distance(hp.location, ST_MakePoint(v_lng, v_lat)::geography)::FLOAT AS dist_meters,
    hr.created_at
  FROM help_requests hr
  JOIN help_request_private hp ON hp.request_id = hr.id
  WHERE hr.status = 'pending'
    AND ST_DWithin(hp.location, ST_MakePoint(v_lng, v_lat)::geography, v_radius_m)
  ORDER BY dist_meters;
END;
$$;

-- ── Function: Get Accepted Request Details (for accepting volunteer only) ────
CREATE OR REPLACE FUNCTION get_accepted_request(p_request_id UUID)
RETURNS TABLE(
  id             UUID,
  requester_name TEXT,
  help_type      TEXT,
  status         TEXT,
  location       GEOGRAPHY,
  description    TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM help_requests
    WHERE id = p_request_id AND accepted_by = auth.uid()
  ) THEN
    RAISE EXCEPTION 'AUTH_ERROR: Not the accepting volunteer for this request';
  END IF;

  RETURN QUERY
  SELECT hr.id, hp.requester_name, hr.help_type, hr.status, hp.location, hp.description
  FROM help_requests hr
  JOIN help_request_private hp ON hp.request_id = hr.id
  WHERE hr.id = p_request_id;
END;
$$;

-- ── Function: Get My Request (seeker, via token, no login) ───────────────────
CREATE OR REPLACE FUNCTION get_my_request(p_token UUID)
RETURNS TABLE(
  id             UUID,
  requester_name TEXT,
  help_type      TEXT,
  status         TEXT,
  accepted_by    UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT hr.id, hp.requester_name, hr.help_type, hr.status, hr.accepted_by
  FROM help_requests hr
  JOIN help_request_private hp ON hp.request_id = hr.id
  WHERE hr.request_token = p_token
  LIMIT 1;
END;
$$;

-- ── Trigger: Enforce device rate-limit on help_requests ──────────────────────
CREATE OR REPLACE FUNCTION check_device_rate_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM help_requests
    WHERE device_fingerprint = NEW.device_fingerprint
      AND status IN ('pending', 'accepted')
      AND id != NEW.id
  ) THEN
    RAISE EXCEPTION 'RATE_LIMIT: Device already has an active help request';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS device_rate_limit_trigger ON help_requests;
CREATE TRIGGER device_rate_limit_trigger
  BEFORE INSERT ON help_requests
  FOR EACH ROW
  EXECUTE FUNCTION check_device_rate_limit();

-- ═══════════════════════════════════════════════════════════════════════════════
-- REALTIME SUBSCRIPTIONS
-- Enable realtime on tables that need live updates
-- ═══════════════════════════════════════════════════════════════════════════════
ALTER PUBLICATION supabase_realtime ADD TABLE help_requests;
ALTER PUBLICATION supabase_realtime ADD TABLE markers;

-- ═══════════════════════════════════════════════════════════════════════════════
-- DONE! Your Supabase backend is ready.
-- 
-- Next steps:
-- 1. Go to Supabase Dashboard → Authentication → Settings
-- 2. Enable Email provider (should be enabled by default)
-- 3. Copy your Project URL and anon key from Settings → API
-- 4. Paste them in lib/main.dart
-- ═══════════════════════════════════════════════════════════════════════════════
