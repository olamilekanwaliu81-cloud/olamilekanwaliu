-- ============================================================
-- Olamilekanwaliu CMS — DATABASE SCHEMA  (run ONCE in Supabase SQL Editor)
-- Public can READ everything. Only the logged-in admin can WRITE.
-- ============================================================

-- ---------- TABLES ----------
create table if not exists portfolio (
  id uuid primary key default gen_random_uuid(),
  title text not null, genre text, category text,
  image_url text, pdf_url text,
  sort_order int default 0, published boolean default true,
  created_at timestamptz default now()
);
create table if not exists services (
  id uuid primary key default gen_random_uuid(),
  num text, icon text, title text not null, description text,
  sort_order int default 0, published boolean default true,
  created_at timestamptz default now()
);
create table if not exists faqs (
  id uuid primary key default gen_random_uuid(),
  question text not null, answer text,
  sort_order int default 0, published boolean default true,
  created_at timestamptz default now()
);
create table if not exists testimonials (
  id uuid primary key default gen_random_uuid(),
  name text not null, location text, quote text, rating int default 5, badge text,
  review_date text,
  sort_order int default 0, published boolean default true,
  created_at timestamptz default now()
);
create table if not exists authors (
  id uuid primary key default gen_random_uuid(),
  name text not null, country text, bio text, image_url text,
  book_url text, contact_url text,
  sort_order int default 0, published boolean default true,
  created_at timestamptz default now()
);
create table if not exists team (
  id uuid primary key default gen_random_uuid(),
  name text not null, role text, bio text, image_url text,
  is_open boolean default false,
  sort_order int default 0, published boolean default true,
  created_at timestamptz default now()
);
create table if not exists popups (
  id uuid primary key default gen_random_uuid(),
  username text not null, flag text, initial text, action text,
  mins int default 60, badge text,
  sort_order int default 0, published boolean default true,
  created_at timestamptz default now()
);

-- ---------- ROW LEVEL SECURITY ----------
-- Enable RLS, allow public SELECT, restrict writes to authenticated users.
do $$
declare t text;
begin
  foreach t in array array['portfolio','services','faqs','testimonials','authors','team','popups']
  loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists "public read %1$s" on %1$I;', t);
    execute format('create policy "public read %1$s" on %1$I for select using (true);', t);
    execute format('drop policy if exists "admin write %1$s" on %1$I;', t);
    execute format('create policy "admin write %1$s" on %1$I for all to authenticated using (true) with check (true);', t);
  end loop;
end $$;

-- ---------- STORAGE BUCKET (images) ----------
insert into storage.buckets (id, name, public)
values ('cms-images','cms-images', true)
on conflict (id) do nothing;

drop policy if exists "public read cms-images" on storage.objects;
create policy "public read cms-images" on storage.objects
  for select using (bucket_id = 'cms-images');

drop policy if exists "admin write cms-images" on storage.objects;
create policy "admin write cms-images" on storage.objects
  for all to authenticated using (bucket_id = 'cms-images') with check (bucket_id = 'cms-images');
