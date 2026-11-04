# What to deploy vs. keep local

## DEPLOY to GitHub (these power the live site + dashboard)
- index.html, privacy.html, and all service pages (*.html)
- cms-config.js            (with YOUR keys pasted — anon key is safe to publish)
- assets/cms-public.js
- admin/login.html, admin/dashboard.html, admin/app.js, admin/vendor/supabase.js
- images/, samples/, logo/, self publishing logo/, about/, authors/, team/
- robots.txt, sitemap.xml, llms.txt

## DO NOT deploy (keep local only)
- cms/schema.sql        (run once in Supabase, not needed on the site)
- cms/seed.sql          (run once in Supabase)
- cms/SETUP-GUIDE.md, cms/CHEATSHEET.md, cms/DEPLOY-LIST.md
- case studies/         (your raw source files; the site uses images/portfolio + samples)
- index.html.bak, marshall mockup.jpg (old leftovers)

## Security notes
- Only the anon/public key is in cms-config.js — that's intended and safe.
- NEVER put the Supabase service_role secret key anywhere in the website.
- /admin/ pages are noindex + blocked in robots.txt.
