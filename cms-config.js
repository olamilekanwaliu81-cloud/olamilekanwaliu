/* ============================================================
   Olamilekanwaliu CMS — SHARED CONFIG (one place to paste keys)
   Used by BOTH the public site and the admin dashboard.
   Both values below are SAFE to ship publicly (anon key is limited
   by row-level security). NEVER paste the service_role secret key.
   ============================================================ */
window.CMS_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT-ref.supabase.co",   // <-- paste your Project URL
  SUPABASE_ANON_KEY: "YOUR-PUBLIC-ANON-KEY",              // <-- paste your anon/public key
  IMAGE_BUCKET: "cms-images"
};
