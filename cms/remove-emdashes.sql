-- ============================================================
-- Remove em dashes (—) from all CMS content, replace with ", "
-- Keeps en dashes (–) in ranges like "3–7 days". Safe to re-run.
-- Run ONCE in Supabase SQL Editor.
-- ============================================================
update services set
  title=regexp_replace(title,'\s*—\s*',', ','g'),
  description=regexp_replace(description,'\s*—\s*',', ','g');

update faqs set
  question=regexp_replace(question,'\s*—\s*',', ','g'),
  answer=regexp_replace(answer,'\s*—\s*',', ','g');

update testimonials set
  quote=regexp_replace(quote,'\s*—\s*',', ','g'),
  name=regexp_replace(name,'\s*—\s*',', ','g'),
  location=regexp_replace(location,'\s*—\s*',', ','g'),
  badge=regexp_replace(coalesce(badge,''),'\s*—\s*',', ','g');

update authors set
  name=regexp_replace(name,'\s*—\s*',', ','g'),
  country=regexp_replace(country,'\s*—\s*',', ','g'),
  bio=regexp_replace(bio,'\s*—\s*',', ','g');

update team set
  name=regexp_replace(name,'\s*—\s*',', ','g'),
  role=regexp_replace(role,'\s*—\s*',', ','g'),
  bio=regexp_replace(bio,'\s*—\s*',', ','g');

update portfolio set
  title=regexp_replace(title,'\s*—\s*',', ','g'),
  genre=regexp_replace(genre,'\s*—\s*',', ','g');

update popups set
  action=regexp_replace(action,'\s*—\s*',', ','g'),
  badge=regexp_replace(coalesce(badge,''),'\s*—\s*',', ','g');
