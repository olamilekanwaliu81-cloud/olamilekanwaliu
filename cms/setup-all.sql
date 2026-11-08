-- ============================================================
-- Olamilekanwaliu CMS, DATABASE SCHEMA  (run ONCE in Supabase SQL Editor)
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


-- ============================================================
-- Olamilekanwaliu CMS, SEED existing content (run ONCE after schema.sql)
-- Idempotent: each block only inserts if that table is still EMPTY.
-- ============================================================

do $$
begin
  if not exists (select 1 from portfolio) then
    insert into portfolio (title, genre, category, image_url, pdf_url, sort_order) values
      ('Judge Not', 'Christian Nonfiction', 'faith', 'images/portfolio/judge-not.jpg', 'samples/judge-not-case-study.pdf', 0),
      ('Soul Sneakers: Passport to Play', 'Children''s Book', 'children', 'images/portfolio/soul-sneakers.jpg', 'samples/soul-sneakers-case-study.pdf', 1),
      ('Moving to Spain With Children', 'Relocation Guide', 'nonfiction', 'images/portfolio/moving-to-spain.jpg', 'samples/moving-to-spain-case-study.pdf', 2),
      ('Own Your Sh!t Workbook', 'Therapy Workbook', 'workbook', 'images/portfolio/own-your-shit-workbook.jpg', 'samples/own-your-shit-workbook-case-study.pdf', 3),
      ('My Seven Covenants', 'Illustrated Faith Book', 'faith', 'images/portfolio/my-seven-covenants.jpg', 'samples/my-seven-covenants-case-study.pdf', 4),
      ('Therapy Changed My Suicidal Thoughts to Self-Love!', 'Memoir', 'nonfiction', 'images/portfolio/therapy-changed.jpg', 'samples/therapy-changed-case-study.pdf', 5),
      ('From Anxious to Confident', 'Self-Help Workbook', 'workbook', 'images/portfolio/from-anxious-to-confident.jpg', 'samples/from-anxious-to-confident-case-study.pdf', 6),
      ('From Flagged to Restored', 'Nonfiction / KDP', 'nonfiction', 'images/portfolio/from-flagged-to-restored.jpg', 'samples/from-flagged-to-restored-case-study.pdf', 7),
      ('Gig Search Hacks Workbook', 'Workbook', 'workbook', 'images/portfolio/gig-search-hacks.jpg', 'samples/gig-search-hacks-case-study.pdf', 8),
      ('Come Forth', 'Epic Fantasy Fiction', 'fiction', 'images/portfolio/come-forth.jpg', 'samples/come-forth-case-study.pdf', 9),
      ('Foundations', 'Christian Living', 'faith', 'images/portfolio/foundations.jpg', 'samples/foundations-case-study.pdf', 10),
      ('Gotta Get It Out', 'Poetry', 'fiction', 'images/portfolio/gotta-get-it-out.jpg', 'samples/gotta-get-it-out-case-study.pdf', 11),
      ('Senior Living Made SIMPLE Workbook', 'Guided Workbook', 'workbook', 'images/portfolio/senior-living-made-simple.jpg', 'samples/senior-living-made-simple-case-study.pdf', 12),
      ('Stronger at the Core', 'Leadership Training', 'nonfiction', 'images/portfolio/stronger-at-the-core.jpg', 'samples/stronger-at-the-core-case-study.pdf', 13),
      ('The Relationship Detox', 'Healing Workbook', 'workbook', 'images/portfolio/the-relationship-detox.jpg', 'samples/the-relationship-detox-case-study.pdf', 14),
      ('Gen B: Generation Blessed', 'Memoir-Style Story', 'nonfiction', 'images/portfolio/gen-b-generation-blessed.jpg', 'samples/gen-b-generation-blessed-case-study.pdf', 15);
  end if;
end $$;

do $$
begin
  if not exists (select 1 from services) then
    insert into services (num, icon, title, description, sort_order) values
      ('Service 01', '✍', 'Ghostwriting and Book Editing', 'Turn your idea into a polished, publish-ready manuscript. From ghostwriting your story to professional editing, structure, clarity, flow, grammar, and consistency, I refine every chapter so your book reads like it was written by a pro.', 0),
      ('Service 02', '📐', 'Book Formatting and Design', 'Convert your manuscript into a professional, publish-ready book. Proper typography, layout, chapter design, and cover guidance that meets Amazon KDP and major distributor standards.', 1),
      ('Service 03', '🚀', 'Amazon KDP Publishing Support', 'Help you upload and publish without rejection or confusion. Category selection, metadata optimization, pricing strategy, and full account setup so your book is live and discoverable.', 2),
      ('Service 04', '💡', 'Book Sales Page and Positioning', 'A compelling sales page that explains your book clearly so readers understand and buy it. Persuasive description, keywords, and positioning that converts visitors into buyers.', 3),
      ('Service 05', '📈', 'Book & Ebook Platform-Based Campaign', 'Promote your book right where readers are buying, on the self-publishing platforms themselves. I set up and manage in-platform ad campaigns like Amazon KDP Ads, Lulu Marketplace Ads, and IngramSpark Ads, putting your book and ebook in front of ready-to-buy audiences to boost visibility, reviews, and sales.', 4),
      ('Service 06', '📣', 'Social Media Ads Campaign', 'Create and manage targeted ad campaigns to promote your book, increase visibility, and attract the right readers online. From audience targeting to ad copy and creative, every campaign is built to convert browsers into buyers.', 5);
  end if;
end $$;

do $$
begin
  if not exists (select 1 from faqs) then
    insert into faqs (question, answer, sort_order) values
      ('How long does each package take?', 'It depends on scope. Formatting and cover projects typically take 3–7 days. Full ghostwriting and publishing packages run 3–8 weeks. You''ll get a clear, realistic timeline during your free discovery call before any commitment.', 0),
      ('What do you need from me to get started?', 'Just your manuscript or idea, any notes or references you have, and a short brief on your goals and audience. If you''re starting from scratch, we''ll map it out together on the discovery call.', 1),
      ('Do I own full rights to the finished book?', 'Yes, 100%. You are the sole author and copyright owner of every manuscript, cover, and file I deliver. I never claim credit or reuse your work anywhere.', 2),
      ('Will my name be the only author listed?', 'Absolutely. Ghostwriting is fully confidential, your name is the only one on the book. I remain completely behind the scenes.', 3),
      ('What if I''m not happy with a draft?', 'Every package includes revisions so we refine the work until it matches your vision. If we haven''t started work yet, you''re entitled to a full refund. Nobody gets left with something they don''t love.', 4),
      ('What file formats do I receive?', 'You get the formats you need to publish and share: editable Word (.docx), print-ready PDF, and ePub for eBooks, all delivered ready for Amazon KDP and IngramSpark.', 5),
      ('Do you help if KDP or IngramSpark rejects my file?', 'Yes. If a platform rejects a file I formatted, I fix it and re-submit at no extra cost. You''re never left troubleshooting uploads on your own.', 6),
      ('Can I pick up a partially finished manuscript?', 'Definitely. Whether you have three chapters or a rough outline, I can step in mid-project, match your voice, and carry it through to a finished, published book.', 7),
      ('Do you sign an NDA and keep my story confidential?', 'Yes. Your story stays private, and I''m happy to sign an NDA before we begin so your ideas are protected in writing from day one.', 8),
      ('What currencies and payment methods do you accept?', 'All currencies are accepted. Prices are shown in USD, but you can pay the equivalent amount in your local currency (NGN, GBP, EUR, CAD and more) through Fiverr''s secure checkout or by direct arrangement.', 9),
      ('Can I see samples before I commit?', 'Of course. Browse the portfolio section above for real book covers, interior layouts, and KDP projects, and I''m happy to share more relevant samples on your discovery call.', 10),
      ('Is the discovery call free, and am I obligated to anything?', 'The discovery call is completely free with zero obligation. It''s simply a chance to talk through your book, get honest advice, and see if we''re a good fit.', 11);
  end if;
end $$;

do $$
begin
  if not exists (select 1 from testimonials) then
    insert into testimonials (name, location, quote, rating, badge, review_date, sort_order) values
      ('Arianatom', '🇺🇸 United States', '"Wow, I''m so impressed with Olamilekan''s book formatting style. My career success book now looks like a professionally published book. The table of contents page design with great style, the headings and spacing all flawless as expected. Delivery as discussed and communication was great."', 6, 'Repeat Client', '2024-08-10', 0),
      ('Cherewood', '🇺🇸 United States', '"Olamilekanwaliu created an exceptional demo book for me, very quickly! It was exactly as I had envisioned, and will definitely choose him for the finished product. He was cheerful about making changes, and exceptionally responsive. His knowledge and skills in book design and creation are state-of-the-art. I highly recommend him."', 6, 'Repeat Client', '2024-10-22', 1),
      ('Marshall5012', '🇺🇸 United States', '"olamilekanwaliu is terrific. He has helped us achieve an accomplishment that we couldn''t do on our own. He is very helpful and thorough. We are very lucky to have him guide us through this publishing process. We certainly will recommend him to our friends."', 6, 'Verified Client', '2025-01-15', 2),
      ('Avelor_jin', '🇺🇸 United States', '"This saved me a lot of time. I had already completed the formatting but needed someone familiar with Amazon KDP to upload everything correctly. The process was quick and professional. Olamilekan did awesomely. Highly recommended!"', 6, 'Repeat Client', '2025-03-08', 3),
      ('cklein456', '🇺🇸 United States', '"Great experience. Very easy to work with. Extremely responsive and I would definitely work with him again."', 6, 'Verified Client', '2025-06-01', 4);
  end if;
end $$;

do $$
begin
  if not exists (select 1 from authors) then
    insert into authors (name, country, bio, image_url, book_url, contact_url, sort_order) values
      ('Rima Danielle Jomaa', '🇺🇸 United States', 'Author of a life-changing self-help book, now live and selling on Amazon after we brought her manuscript from draft to published reality.', 'authors/author1.jpg', '#', '#', 0),
      ('Chere Curtis Wood', '🇺🇸 United States', 'A first-time author in the Christian book space, Chere brought her faith-driven message to life and into print, guided from manuscript to a beautifully published book ready for readers.', 'images/pic-4a254a2561.jpg', '#', 'https://www.linkedin.com/in/chere-curtis-wood-a8308438b/', 1),
      ('Obembe Akinlolu', '🇳🇬 Nigeria', 'Nigerian entrepreneur, network marketer, and CEO of (FHG) Eagles Team and Truevitalhealthcare. Best-selling author of "Discover Why Your Team Isn''t Growing: How Smart Leaders Stop Wasting Effort," alongside his published work "Overcoming Osteoporosis."', 'images/pic-a077f2ef7b.jpg', 'https://selar.com/m/ObembeAkinloluwa', 'https://ng.linkedin.com/in/obembeakinloluwa', 2);
  end if;
end $$;

do $$
begin
  if not exists (select 1 from team) then
    insert into team (name, role, bio, image_url, is_open, sort_order) values
      ('Khodijah', 'Book Formatting Expert', 'Specialises in professional book interior formatting and layout, optimised for Amazon KDP and print publishing standards.', 'team/khodijah.jpg', false, 0),
      ('Teller', 'Sales Page & Conversion', 'Crafts persuasive sales pages and conversion-focused copy that help authors connect with readers and increase visibility and sales online.', 'team/teller.jpg', false, 1),
      ('Qudus', 'Book Campaign Strategist & Media Ads', 'Develops targeted ad strategies that help authors reach the right audience and drive traffic, leads, and book sales across digital platforms.', 'team/qudus.jpg', false, 2),
      ('Growing Team', 'Open to Talent', 'We''re expanding. Talented writers, designers, and marketers passionate about books are welcome to reach out.', '', true, 3);
  end if;
end $$;

do $$
begin
  if not exists (select 1 from popups) then
    insert into popups (username, flag, initial, action, mins, badge, sort_order) values
      ('Michael', '🇺🇸', 'M', 'started their Amazon KDP Ads project', 1, 'Top Client', 0),
      ('cklein456', '🇺🇸', 'C', 'started their book publishing project', 150, 'Top Client', 1),
      ('marshall5012', '🇺🇸', 'M', 'started their book promotion project', 603, '', 2),
      ('arianatom451', '🇺🇸', 'A', 'started their book cover design project', 1358, '', 3),
      ('avelor_jin', '🇺🇸', 'A', 'started their book formatting project', 2415, 'Repeated', 4),
      ('mayafrancis2', '🇬🇧', 'M', 'started their book formatting project', 3774, '', 5),
      ('fredmartinez81', '🇺🇸', 'F', 'started their book cover design project', 5435, '', 6),
      ('ChereWood', '🇺🇸', 'C', 'started their book design project', 7398, 'Top Client', 7),
      ('seraphy_west', '🇺🇸', 'S', 'started their book promotion project', 9663, '', 8),
      ('anthony_camach', '🇺🇸', 'A', 'started their book layout project', 12230, '', 9),
      ('hollarmi', '🇺🇸', 'H', 'started their book formatting project', 15099, '', 10),
      ('timmagsby', '🇺🇸', 'T', 'started their sales page project', 18269, '', 11),
      ('tamiah312', '🇺🇸', 'T', 'started their book editing project', 21742, '', 12),
      ('kionnejohnson', '🇺🇸', 'K', 'started their book cover design project', 25517, '', 13),
      ('frederik150', '🇺🇸', 'F', 'started their book publishing project', 29594, '', 14),
      ('ryanaw638', '🇺🇸', 'R', 'started their sales page project', 33972, '', 15),
      ('desiree_bethea', '🇺🇸', 'D', 'started their book promotion project', 38653, '', 16),
      ('jack_lian', '🇺🇸', 'J', 'started their book layout project', 43636, '', 17),
      ('aliciahoolan', '🇦🇺', 'A', 'started their book formatting project', 48921, '', 18),
      ('oluwoleadeba708', '🇨🇦', 'O', 'started their book editing project', 54507, '', 19),
      ('reccejesse', '🇺🇸', 'R', 'started their book cover design project', 60396, 'Repeated', 20),
      ('delcanherbert', '🇳🇴', 'D', 'started their book cover design project', 66587, '', 21),
      ('astridkolkman', '🇩🇪', 'A', 'started their book publishing project', 73079, '', 22),
      ('anitasgrl2_b4', '🇺🇸', 'A', 'started their sales page project', 79874, '', 23),
      ('alessandro3245', '🇮🇲', 'A', 'started their book promotion project', 86970, '', 24),
      ('henry_431', '🇺🇸', 'H', 'started their book layout project', 94369, '', 25),
      ('edvega74', '🇺🇸', 'E', 'started their book formatting project', 102069, '', 26),
      ('red_pig16', '🇺🇸', 'R', 'started their book editing project', 110072, '', 27),
      ('leoblue_b4', '🇺🇸', 'L', 'started their book cover design project', 118377, '', 28),
      ('emilia753', '🇩🇪', 'E', 'started their book cover design project', 126983, 'Repeated', 29),
      ('steve_mcrae', '🇺🇸', 'S', 'started their book publishing project', 135891, '', 30),
      ('jakethebest1', '🇺🇸', 'J', 'started their sales page project', 145102, '', 31),
      ('stefanklaus460', '🇩🇪', 'S', 'started their book promotion project', 154614, '', 32),
      ('sugarvineart', '🇺🇸', 'S', 'started their book layout project', 164429, '', 33),
      ('macrhod', '🇺🇸', 'M', 'started their book formatting project', 174545, '', 34),
      ('stefanwieser', '🇳🇱', 'S', 'started their book editing project', 184964, '', 35),
      ('nicholas232', '🇺🇸', 'N', 'started their book cover design project', 195684, '', 36),
      ('feli_eiffel', '🇩🇪', 'F', 'started their book publishing project', 206706, '', 37),
      ('angela952', '🇺🇸', 'A', 'started their book promotion project', 218031, 'Repeated', 38),
      ('charlie_jack9', '🇬🇧', 'C', 'started their sales page project', 229657, '', 39),
      ('lexischambers15', '🇺🇸', 'L', 'started their book promotion project', 241585, 'Repeated', 40),
      ('joshott0609', '🇺🇸', 'J', 'started their book layout project', 253816, '', 41),
      ('woodchucks22', '🇺🇸', 'W', 'started their book formatting project', 266348, '', 42),
      ('jeanetterobin', '🇺🇸', 'J', 'started their book editing project', 279182, '', 43),
      ('chengfei09', '🇨🇳', 'C', 'started their book cover design project', 292318, '', 44),
      ('valeriehende178', '🇺🇸', 'V', 'started their book publishing project', 305756, '', 45),
      ('tonyhuggins', '🇺🇸', 'T', 'started their sales page project', 319497, '', 46),
      ('danielchris126', '🇺🇸', 'D', 'started their book promotion project', 333539, '', 47),
      ('mariavan935', '🇳🇱', 'M', 'started their book layout project', 347883, '', 48),
      ('franbardallo', '🇬🇧', 'F', 'started their book formatting project', 362529, '', 49),
      ('besstveit', '🇺🇸', 'B', 'started their book editing project', 377477, '', 50),
      ('kadencerex', '🇺🇸', 'K', 'started their book cover design project', 392727, '', 51),
      ('nicolassmith487', '🇺🇸', 'N', 'started their sales page project', 408279, 'Top Client', 52),
      ('torreymontgomer', '🇺🇸', 'T', 'started their book publishing project', 424133, '', 53),
      ('leonleonz', '🇩🇪', 'L', 'started their sales page project', 440290, '', 54),
      ('m_annie92', '🇺🇸', 'M', 'started their book promotion project', 456748, '', 55),
      ('James5298', '🇬🇧', 'J', 'started their book layout project', 473508, '', 56),
      ('joshwins35', '🇺🇸', 'J', 'started their book formatting project', 490570, '', 57),
      ('felipealvare190', '🇺🇸', 'F', 'started their book editing project', 507934, '', 58),
      ('sherwinwells', '🇳🇬', 'S', 'started their book publishing project', 525600, '', 59);
  end if;
end $$;
