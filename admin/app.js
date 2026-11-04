/* Olamilekanwaliu CMS — dashboard logic */
(function(){
  var cfg=window.CMS_CONFIG||{};
  if(!cfg.SUPABASE_URL || cfg.SUPABASE_URL.indexOf('YOUR-PROJECT')>-1){
    document.getElementById('list').innerHTML='<div class="empty">Setup needed: paste your Supabase URL and anon key into <b>cms-config.js</b>.</div>';
    return;
  }
  var sb=supabase.createClient(cfg.SUPABASE_URL,cfg.SUPABASE_ANON_KEY);

  // ---- collection definitions ----
  var SELECT_CATS=['faith','workbook','nonfiction','fiction','children'];
  var COLLECTIONS={
    portfolio:{label:'Portfolio',desc:'Case studies shown on the homepage and service pages.',title:'title',sub:'genre',img:'image_url',
      fields:[{k:'title',t:'text',req:1,label:'Title'},{k:'genre',t:'text',label:'Genre tag'},
        {k:'category',t:'select',opts:SELECT_CATS,label:'Filter category'},
        {k:'image_url',t:'image',label:'Cover image'},{k:'pdf_url',t:'file',label:'Case study PDF'},
        {k:'published',t:'bool',label:'Published'}]},
    services:{label:'Services',desc:'The service cards on the homepage.',title:'title',sub:'num',img:null,
      fields:[{k:'num',t:'text',label:'Label (e.g. Service 01)'},{k:'icon',t:'text',label:'Icon (emoji)'},
        {k:'title',t:'text',req:1,label:'Title'},{k:'description',t:'textarea',label:'Description'},
        {k:'published',t:'bool',label:'Published'}]},
    faqs:{label:'FAQ',desc:'Frequently asked questions on the homepage.',title:'question',sub:'answer',img:null,
      fields:[{k:'question',t:'text',req:1,label:'Question'},{k:'answer',t:'textarea',label:'Answer'},
        {k:'published',t:'bool',label:'Published'}]},
    testimonials:{label:'Testimonials',desc:'Client stories on the homepage.',title:'name',sub:'quote',img:null,
      fields:[{k:'name',t:'text',req:1,label:'Client name'},{k:'location',t:'text',label:'Location (e.g. 🇺🇸 United States)'},
        {k:'quote',t:'textarea',label:'Quote'},{k:'rating',t:'number',label:'Rating (1-5)'},
        {k:'badge',t:'text',label:'Badge (e.g. Repeat Client)'},{k:'published',t:'bool',label:'Published'}]},
    authors:{label:'Featured Authors',desc:'Authors featured on the homepage.',title:'name',sub:'country',img:'image_url',
      fields:[{k:'name',t:'text',req:1,label:'Name'},{k:'country',t:'text',label:'Country (e.g. 🇺🇸 United States)'},
        {k:'bio',t:'textarea',label:'Bio'},{k:'image_url',t:'image',label:'Photo'},
        {k:'book_url',t:'text',label:'Book link (URL)'},{k:'contact_url',t:'text',label:'Contact link (URL)'},
        {k:'published',t:'bool',label:'Published'}]},
    team:{label:'Team',desc:'Team members on the homepage.',title:'name',sub:'role',img:'image_url',
      fields:[{k:'name',t:'text',req:1,label:'Name'},{k:'role',t:'text',label:'Role'},
        {k:'bio',t:'textarea',label:'Bio'},{k:'image_url',t:'image',label:'Photo'},
        {k:'is_open',t:'bool',label:'“Open role” card (dashed, no photo)'},{k:'published',t:'bool',label:'Published'}]},
    popups:{label:'Social Proof',desc:'The “just started their project” popups.',title:'username',sub:'action',img:null,
      fields:[{k:'username',t:'text',req:1,label:'Username'},{k:'flag',t:'text',label:'Flag emoji'},
        {k:'initial',t:'text',label:'Avatar initial'},{k:'action',t:'text',label:'Action text'},
        {k:'mins',t:'number',label:'Minutes ago (e.g. 120)'},{k:'badge',t:'text',label:'Badge (Top Client / Repeated)'},
        {k:'published',t:'bool',label:'Published'}]}
  };
  var ORDER=['portfolio','authors','testimonials','team','services','faqs','popups'];

  var current='portfolio', rows=[], editing=null;
  var el=function(id){return document.getElementById(id);};

  function toast(msg,isErr){var t=el('toast');t.textContent=msg;t.className='toast show'+(isErr?' err':'');setTimeout(function(){t.className='toast';},2600);}

  // ---- auth guard ----
  sb.auth.getSession().then(function(r){
    if(!r.data.session){ location.replace('login.html'); return; }
    initNav(); load('portfolio');
  });
  el('logout').addEventListener('click',async function(){ await sb.auth.signOut(); location.replace('login.html'); });

  // ---- sidebar ----
  function initNav(){
    var nav=el('nav'); nav.innerHTML='';
    ORDER.forEach(function(key){
      var b=document.createElement('button'); b.dataset.key=key;
      b.innerHTML='<span class="label">'+COLLECTIONS[key].label+'</span><span class="count" id="cnt-'+key+'">·</span>';
      b.addEventListener('click',function(){load(key);});
      nav.appendChild(b);
      refreshCount(key);
    });
  }
  async function refreshCount(key){
    var r=await sb.from(key).select('id',{count:'exact',head:true});
    var c=el('cnt-'+key); if(c) c.textContent=(r.count!=null?r.count:'·');
  }

  // ---- list ----
  async function load(key){
    current=key;
    document.querySelectorAll('.nav button').forEach(function(b){b.classList.toggle('active',b.dataset.key===key);});
    var col=COLLECTIONS[key];
    el('colTitle').textContent=col.label; el('colDesc').textContent=col.desc;
    el('list').innerHTML='<div class="loading">Loading…</div>';
    var r=await sb.from(key).select('*').order('sort_order',{ascending:true}).order('created_at',{ascending:true});
    if(r.error){ el('list').innerHTML='<div class="empty">Error: '+r.error.message+'</div>'; return; }
    rows=r.data||[]; renderList();
  }
  function renderList(){
    var col=COLLECTIONS[current];
    if(!rows.length){ el('list').innerHTML='<div class="empty">No items yet. Click “Add new”.</div>'; return; }
    var html='';
    rows.forEach(function(row,idx){
      var title=(row[col.title]||'(untitled)');
      var sub=(col.sub&&row[col.sub])?String(row[col.sub]).slice(0,90):'';
      var thumb= col.img&&row[col.img] ? '<img class="thumb" src="'+esc(resolveImg(row[col.img]))+'" alt="">'
                 : '<div class="thumb">'+esc((title[0]||'•').toUpperCase())+'</div>';
      var tag=row.category?'<span class="row-tag">'+esc(row.category)+'</span>':'';
      html+='<div class="row'+(row.published===false?' hidden-row':'')+'">'
        +'<div class="ord"><button data-up="'+idx+'">▲</button><button data-down="'+idx+'">▼</button></div>'
        +thumb
        +'<div class="row-main"><div class="row-title">'+esc(title)+(row.published===false?' — <i>hidden</i>':'')+'</div>'
        +'<div class="row-sub">'+esc(sub)+'</div>'+tag+'</div>'
        +'<div class="row-actions"><button class="btn btn-ghost btn-sm" data-edit="'+idx+'">Edit</button>'
        +'<button class="btn btn-danger btn-sm" data-del="'+idx+'">Delete</button></div></div>';
    });
    el('list').innerHTML=html;
    el('list').querySelectorAll('[data-edit]').forEach(function(b){b.onclick=function(){openEditor(rows[+b.dataset.edit]);};});
    el('list').querySelectorAll('[data-del]').forEach(function(b){b.onclick=function(){del(rows[+b.dataset.del]);};});
    el('list').querySelectorAll('[data-up]').forEach(function(b){b.onclick=function(){move(+b.dataset.up,-1);};});
    el('list').querySelectorAll('[data-down]').forEach(function(b){b.onclick=function(){move(+b.dataset.down,1);};});
  }
  function resolveImg(u){ if(!u) return ''; return /^https?:|^data:/.test(u)?u:'../'+u; }

  // ---- reorder ----
  async function move(idx,dir){
    var j=idx+dir; if(j<0||j>=rows.length) return;
    var a=rows[idx], b=rows[j];
    var ao=a.sort_order, bo=b.sort_order;
    if(ao===bo){ ao=idx; bo=j; }
    await sb.from(current).update({sort_order:bo}).eq('id',a.id);
    await sb.from(current).update({sort_order:ao}).eq('id',b.id);
    load(current);
  }

  // ---- editor ----
  function openEditor(row){
    editing=row||{}; var isNew=!row;
    var col=COLLECTIONS[current];
    el('drawerTitle').textContent=(isNew?'Add ':'Edit ')+col.label.replace(/s$/,'');
    var f=el('form'); f.innerHTML='';
    col.fields.forEach(function(fd){
      var val=editing[fd.k]; if(val==null) val= fd.t==='bool'?true:'';
      var g=document.createElement('div'); g.className='fg';
      if(fd.t==='bool'){
        g.innerHTML='<div class="toggle"><input type="checkbox" id="f_'+fd.k+'" '+(val?'checked':'')+'><label for="f_'+fd.k+'" style="margin:0">'+fd.label+'</label></div>';
      } else if(fd.t==='textarea'){
        g.innerHTML='<label>'+fd.label+'</label><textarea id="f_'+fd.k+'">'+esc(val)+'</textarea>';
      } else if(fd.t==='select'){
        g.innerHTML='<label>'+fd.label+'</label><select id="f_'+fd.k+'">'+fd.opts.map(function(o){return '<option '+(o===val?'selected':'')+'>'+o+'</option>';}).join('')+'</select>';
      } else if(fd.t==='number'){
        g.innerHTML='<label>'+fd.label+'</label><input type="number" id="f_'+fd.k+'" value="'+esc(val)+'">';
      } else if(fd.t==='image'||fd.t==='file'){
        var acc=fd.t==='image'?'image/*':'application/pdf,image/*';
        g.innerHTML='<label>'+fd.label+'</label><input type="text" id="f_'+fd.k+'" value="'+esc(val)+'" placeholder="URL or upload below">'
          +'<div class="uprow"><input type="file" id="up_'+fd.k+'" accept="'+acc+'"><span id="ups_'+fd.k+'" style="font-size:12px;color:var(--muted)"></span></div>'
          +(fd.t==='image'?'<img class="imgprev" id="pv_'+fd.k+'" '+(val?'src="'+esc(resolveImg(val))+'" style="display:block"':'')+'>':'');
      } else {
        g.innerHTML='<label>'+fd.label+(fd.req?' *':'')+'</label><input type="text" id="f_'+fd.k+'" value="'+esc(val)+'">';
      }
      f.appendChild(g);
      if(fd.t==='image'||fd.t==='file'){ wireUpload(fd); }
    });
    openDrawer(true);
  }
  function wireUpload(fd){
    var up=el('up_'+fd.k); if(!up) return;
    up.addEventListener('change',async function(){
      var file=up.files[0]; if(!file) return;
      var stat=el('ups_'+fd.k); stat.textContent='Uploading…';
      var path=current+'/'+Date.now()+'_'+file.name.replace(/[^a-z0-9._-]/gi,'_');
      var r=await sb.storage.from(cfg.IMAGE_BUCKET).upload(path,file,{upsert:true});
      if(r.error){ stat.textContent='Upload failed: '+r.error.message; return; }
      var pub=sb.storage.from(cfg.IMAGE_BUCKET).getPublicUrl(path).data.publicUrl;
      el('f_'+fd.k).value=pub; stat.textContent='Uploaded ✓';
      var pv=el('pv_'+fd.k); if(pv){ pv.src=pub; pv.style.display='block'; }
    });
  }
  function openDrawer(open){ el('drawer').classList.toggle('open',open); el('overlay').classList.toggle('open',open); }
  el('overlay').onclick=function(){openDrawer(false);}; el('cancelBtn').onclick=function(){openDrawer(false);};
  el('addBtn').onclick=function(){openEditor(null);};

  el('saveBtn').onclick=async function(){
    var col=COLLECTIONS[current]; var rec={};
    for(var i=0;i<col.fields.length;i++){
      var fd=col.fields[i]; var node=el('f_'+fd.k); if(!node) continue;
      if(fd.t==='bool') rec[fd.k]=node.checked;
      else if(fd.t==='number') rec[fd.k]= node.value===''?null:Number(node.value);
      else rec[fd.k]=node.value.trim();
      if(fd.req && !rec[fd.k]){ toast(fd.label+' is required',true); return; }
    }
    var btn=el('saveBtn'); btn.disabled=true; btn.textContent='Saving…';
    var res;
    if(editing&&editing.id){ res=await sb.from(current).update(rec).eq('id',editing.id); }
    else { rec.sort_order=rows.length; res=await sb.from(current).insert(rec); }
    btn.disabled=false; btn.textContent='Save';
    if(res.error){ toast(res.error.message,true); return; }
    toast('Saved ✓'); openDrawer(false); refreshCount(current); load(current);
  };

  async function del(row){
    if(!confirm('Delete “'+(row[COLLECTIONS[current].title]||'this item')+'”? This cannot be undone.')) return;
    var r=await sb.from(current).delete().eq('id',row.id);
    if(r.error){ toast(r.error.message,true); return; }
    toast('Deleted'); refreshCount(current); load(current);
  }

  function esc(s){return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
})();
