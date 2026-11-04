# Olamilekanwaliu CMS — One-Time Setup Guide (≈15 minutes)

You only do this ONCE. After it's done, you manage all content from the dashboard —
no code, no redeploy.

## 1. Create a free Supabase project
1. Go to https://supabase.com → sign up (free).
2. Click **New project**. Give it a name (e.g. "olamilekanwaliu"), set a database
   password (save it somewhere), pick the closest region, create it. Wait ~2 min.

## 2. Create the tables
1. In Supabase, left menu → **SQL Editor** → **New query**.
2. Open the file **cms/schema.sql**, copy ALL of it, paste, click **Run**.
   (You should see "Success".)

## 3. Import your existing content  ← do NOT skip
1. SQL Editor → **New query**.
2. Open **cms/seed.sql**, copy ALL, paste, **Run**.
   This loads your 16 portfolio projects, authors, testimonials, team, services,
   FAQ and popups. (Safe to re-run — it won't duplicate.)

## 4. Create your admin login
1. Left menu → **Authentication** → **Users** → **Add user** → **Create new user**.
2. Enter YOUR email + a password. Tick "Auto Confirm User". Create.
   (This is the only account that can edit content.)

## 5. Turn OFF public sign-ups (so no one else can register)
1. **Authentication** → **Providers** (or **Sign In / Providers**) → **Email**.
2. Turn **"Allow new users to sign up"** OFF. Save.

## 6. Paste your keys into the site
1. Left menu → **Project Settings** → **API**.
2. Copy **Project URL** and the **anon / public** key (NOT service_role).
3. Open **cms-config.js** (in the website folder) and paste them in:
   SUPABASE_URL  = your Project URL
   SUPABASE_ANON_KEY = your anon public key
   (Both are safe to publish.)

## 7. (Only if you use the "email me a sign-in link" button)
Supabase → **Authentication → URL Configuration**:
- Site URL: `https://seller.olamilekanwaliu.com`
- Redirect URLs: add `https://seller.olamilekanwaliu.com/admin/dashboard.html`

## 8. Deploy
Upload the website files to GitHub as usual (see cms/DEPLOY-LIST.md for what to
include). Your admin dashboard will be live at:
  https://seller.olamilekanwaliu.com/admin/login.html

## Done ✓
Log in, and you'll see all your current content already there. Edit away — changes
appear on the live site automatically (no redeploy needed for content).
