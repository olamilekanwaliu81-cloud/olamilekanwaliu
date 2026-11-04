-- ============================================================
-- CMS fix: grant table privileges so public can READ and the
-- logged-in admin can WRITE. (Row Level Security still applies.)
-- Run ONCE in Supabase SQL Editor.
-- ============================================================
grant usage on schema public to anon, authenticated;

-- public (not logged in) can read
grant select on
  portfolio, services, faqs, testimonials, authors, team, popups
  to anon;

-- logged-in admin can read + write
grant select, insert, update, delete on
  portfolio, services, faqs, testimonials, authors, team, popups
  to authenticated;
