/* Olamilekanwaliu CMS — public renderer.
   Renders live content over the existing hard-coded markup.
   SAFE FALLBACK: if not configured, fetch fails, or a table is empty,
   the original hard-coded content is left untouched. */
(function(){
  var cfg=window.CMS_CONFIG||{};
  if(!cfg.SUPABASE_URL || cfg.SUPABASE_URL.indexOf('YOUR-PROJECT')>-1) return; // not set up yet -> keep hard-coded
  var REST=cfg.SUPABASE_URL.replace(/\/+$/,'')+'/rest/v1/';
  function get(t){
    return fetch(REST+t+'?select=*&published=eq.true&order=sort_order.asc,created_at.asc',
      {headers:{apikey:cfg.SUPABASE_ANON_KEY}}).then(function(r){return r.ok?r.json():[];}).catch(function(){return [];});
  }
  function esc(s){return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
  function stars(n){n=Math.max(0,Math.min(5,parseInt(n||5,10)));var o='';for(var i=0;i<n;i++)o+='<span class="testi-star">★</span>';return o;}

  // ---------- PORTFOLIO (homepage + service pages) ----------
  get('portfolio').then(function(rows){
    if(!rows.length) return;
    document.querySelectorAll('.cs-grid').forEach(function(grid){
      var badge='Case Study'; var b0=grid.querySelector('.cs-badge'); if(b0) badge=b0.textContent;
      grid.innerHTML=rows.map(function(r){
        return '<a class="cs-card" data-cat="'+esc(r.category)+'" href="'+esc(r.pdf_url)+'" target="_blank" rel="noopener" aria-label="View '+esc(r.title)+' case study (PDF)">'
          +'<div class="cs-img"><span class="cs-badge">'+esc(badge)+'</span><img src="'+esc(r.image_url)+'" alt="'+esc(r.title)+' — '+esc(r.genre)+'" loading="lazy" decoding="async"></div>'
          +'<div class="cs-bar"><span class="cs-meta"><span class="cs-genre">'+esc(r.genre)+'</span><span class="cs-title">'+esc(r.title)+'</span></span><span class="cs-view">View PDF →</span></div></a>';
      }).join('');
    });
    initFilters();
  });
  function initFilters(){
    var btns=document.querySelectorAll('.pf-filter');
    btns.forEach(function(b){
      b.onclick=function(){
        btns.forEach(function(x){x.classList.remove('active');}); b.classList.add('active');
        var f=b.dataset.filter;
        document.querySelectorAll('.cs-card').forEach(function(c){
          c.classList.toggle('hidden', f!=='all' && c.dataset.cat!==f);
        });
      };
    });
  }

  // ---------- FEATURED AUTHORS (homepage) ----------
  get('authors').then(function(rows){
    if(!rows.length) return;
    var grid=document.querySelector('.authors-grid'); if(!grid) return;
    grid.innerHTML=rows.map(function(r){
      var init=(r.name||'?').trim().charAt(0).toUpperCase();
      var photo = r.image_url
        ? '<img src="'+esc(r.image_url)+'" alt="'+esc(r.name)+'" onerror="this.style.display=\'none\';this.nextElementSibling.style.display=\'block\'" /><span class="author-initial" style="display:none">'+esc(init)+'</span>'
        : '<span class="author-initial" style="display:block">'+esc(init)+'</span>';
      var book = r.book_url ? '<a class="author-btn author-btn-book" href="'+esc(r.book_url)+'" target="_blank" rel="noopener">📖 View Their Book</a>' : '';
      var contact = r.contact_url ? '<a class="author-btn author-btn-contact" href="'+esc(r.contact_url)+'" target="_blank" rel="noopener">✉ Contact Author</a>' : '';
      return '<div class="author-card"><div class="author-photo">'+photo+'</div>'
        +'<p class="author-name">'+esc(r.name)+'</p><p class="author-country">'+esc(r.country)+'</p>'
        +'<p class="author-bio">'+esc(r.bio)+'</p><div class="author-btns">'+book+contact+'</div></div>';
    }).join('');
  });

  // ---------- TESTIMONIALS (homepage) ----------
  get('testimonials').then(function(rows){
    if(!rows.length) return;
    var grid=document.querySelector('.testimonials-grid'); if(!grid) return;
    grid.innerHTML=rows.map(function(r){
      var init=(r.name||'?').trim().charAt(0).toUpperCase();
      var badge=r.badge?'<span class="testi-badge">'+esc(r.badge)+'</span>':'';
      return '<div class="testi-card"'+(r.review_date?' data-date="'+esc(r.review_date)+'"':'')+'>'
        +'<div class="testi-stars">'+stars(r.rating)+'</div>'
        +'<p class="testi-text">'+esc(r.quote)+'</p>'
        +'<div class="testi-footer"><div class="testi-avatar" style="background:#C8862A;">'+esc(init)+'</div>'
        +'<div><div class="testi-name">'+esc(r.name)+'</div><div class="testi-location">'+esc(r.location)+'</div></div>'+badge+'</div></div>';
    }).join('');
  });

  // ---------- TEAM (homepage) ----------
  get('team').then(function(rows){
    if(!rows.length) return;
    var sample=document.querySelector('.team-member-card'); if(!sample) return;
    var grid=sample.parentNode;
    grid.innerHTML=rows.map(function(r){
      var init=(r.name||'?').trim().charAt(0).toUpperCase();
      var avatar = r.is_open ? '<div class="team-member-avatar"><span class="avatar-fallback">+</span></div>'
        : '<div class="team-member-avatar">'+(r.image_url?'<img src="'+esc(r.image_url)+'" alt="'+esc(r.name)+'" onerror="this.style.display=\'none\';this.nextElementSibling.style.display=\'flex\'" />':'')+'<span class="avatar-fallback"'+(r.image_url?'':' style="display:flex"')+'>'+esc(init)+'</span></div>';
      return '<div class="team-member-card'+(r.is_open?' open':'')+'">'+avatar
        +'<p class="team-member-name">'+esc(r.name)+'</p><p class="team-member-role">'+esc(r.role)+'</p>'
        +'<p class="team-member-bio">'+esc(r.bio)+'</p></div>';
    }).join('');
  });

  // ---------- SERVICES (homepage) ----------
  get('services').then(function(rows){
    if(!rows.length) return;
    var grid=document.querySelector('.services-grid'); if(!grid) return;
    grid.innerHTML=rows.map(function(r,i){
      return '<div class="service-card'+(i===1?' featured':'')+'">'
        +'<div class="service-num">'+esc(r.num)+'</div><span class="service-icon">'+esc(r.icon)+'</span>'
        +'<h3 class="service-title">'+esc(r.title)+'</h3><p class="service-desc">'+esc(r.description)+'</p></div>';
    }).join('');
  });

  // ---------- FAQ (homepage) ----------
  get('faqs').then(function(rows){
    if(!rows.length) return;
    var sample=document.querySelector('.faq-item'); if(!sample) return;
    var wrap=sample.parentNode;
    wrap.innerHTML=rows.map(function(r){
      return '<div class="faq-item"><div class="faq-q">'+esc(r.question)+'<span class="faq-icon">+</span></div>'
        +'<div class="faq-a"><p>'+esc(r.answer)+'</p></div></div>';
    }).join('');
    // re-bind accordion
    wrap.querySelectorAll('.faq-q').forEach(function(q){
      q.addEventListener('click',function(){
        var it=q.parentElement, open=it.classList.contains('open');
        wrap.querySelectorAll('.faq-item.open').forEach(function(o){o.classList.remove('open');});
        if(!open) it.classList.add('open');
      });
    });
  });

  // ---------- SOCIAL-PROOF POPUPS (read live; popup script picks these up each cycle) ----------
  get('popups').then(function(rows){
    if(!rows.length) return;
    window.CMS_POPUPS=rows.map(function(r){
      return {user:r.username, flag:r.flag, initial:r.initial, action:r.action, mins:r.mins, badge:r.badge};
    });
  });
})();
