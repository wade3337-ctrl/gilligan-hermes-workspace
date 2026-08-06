#!/usr/bin/env node
/*
 * Aspen -> Bigin DRY-RUN push (v2). Reads a rep's live TRIM IT pipeline (cockpit-read.sh v2, which
 * MIRRORS the canonical Sales Cockpit), checks Bigin for existing deals, and REPORTS what WOULD be
 * created/updated/skipped. WRITES NOTHING. This is the review gate before go-live.
 *
 * Linchpin (#2): dedups on the "TRIM IT ProjectID" custom field IF it exists on the Pipelines module;
 * otherwise falls back to a [TI:<ProjectID>] tag embedded in Deal_Name. The planned card payload always
 * carries the ProjectID (in the custom field when present) + RunningDry/ReSell as tags.
 *
 * Usage: node dry-run-push.js <SalesRepID>      (default 1140 = Ethan)
 */
const fs=require('fs'),https=require('https'),cp=require('child_process'),path=require('path');
const REP=process.argv[2]||'1140';
const DIR=__dirname;
const ownerMap=JSON.parse(fs.readFileSync(path.join(DIR,'owner-map.json'),'utf8'));
const rep=ownerMap.reps[REP];
if(!rep){console.error('No rep '+REP+' in owner-map.json');process.exit(1);}
const TI_FIELD_LABEL='TRIM IT ProjectID';           // the custom field we want (create in Bigin UI)
const TI_FIELD_API='TRIM_IT_ProjectID';             // likely api_name once created

const cfg=JSON.parse(fs.readFileSync(process.env.HOME+'/.secrets/bigin-oauth.json','utf8'));
const API=(cfg.api_domain||'https://www.zohoapis.com').replace(/^https?:\/\//,'');
const ACC=(cfg.accounts_domain||'https://accounts.zoho.com').replace(/^https?:\/\//,'');
const SCHEME='Zoho-oauth'+'token ';
function post(host,p,body){return new Promise((res,rej)=>{const data=new URLSearchParams(body).toString();const r=https.request({host,path:p,method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded','Content-Length':Buffer.byteLength(data)}},x=>{let b='';x.on('data',d=>b+=d);x.on('end',()=>res(b));});r.on('error',rej);r.write(data);r.end();});}
function get(host,p,tok){return new Promise((res,rej)=>{const r=https.request({host,path:p,method:'GET',headers:{Authorization:SCHEME+tok}},x=>{let b='';x.on('data',d=>b+=d);x.on('end',()=>res({s:x.statusCode,b}));});r.on('error',rej);r.end();});}

function readCockpit(repId){
  const out=cp.execFileSync('bash',[path.join(DIR,'cockpit-read.sh'),repId],{encoding:'utf8',maxBuffer:1e8});
  const lines=out.split('\n').filter(l=>l.includes('|')&&!/^-+\|/.test(l));
  const rows=[]; let header=null;
  for(const l of lines){ const c=l.split('|'); if(!header){header=c.map(s=>s.trim());continue;}
    const o={}; header.forEach((h,i)=>o[h]=(c[i]||'').trim()); if(o.ProjectID&&/^\d+$/.test(o.ProjectID))rows.push(o); }
  return rows;
}

(async()=>{
 const rt=JSON.parse(await post(ACC,'/oauth/v2/token',{refresh_token:cfg.refresh_token,client_id:cfg.client_id,client_secret:cfg.client_secret,grant_type:'refresh_token'}));
 const tok=rt.access_token;
 if(!tok){console.error('token refresh failed');process.exit(1);}

 // 0) is the TRIM IT ProjectID custom field present yet? (drives dedup + payload)
 let tiField=null;
 try{const fm=await get(API,'/bigin/v2/settings/fields?module=Pipelines',tok);const fj=JSON.parse(fm.b);
   tiField=(fj.fields||[]).find(f=>f.custom_field&&/trim.?it.?project/i.test((f.field_label||'')+f.api_name));
 }catch(e){}
 const dedupMode=tiField?('custom field "'+tiField.api_name+'"'):('[TI:<id>] tag in Deal_Name (fallback \u2014 create the field to upgrade)');

 // 1) read TRIM IT pipeline (cockpit-mirrored)
 const src=readCockpit(REP);
 console.log('\n=== DRY-RUN v2: '+rep.name+' (SalesRepID '+REP+') -> '+rep.bigin_pipeline+' / '+rep.aspen_feed_sub+' ===');
 console.log('Linchpin dedup: '+dedupMode);
 console.log('TRIM IT live-pipeline projects (cockpit-mirrored): '+src.length);

 // 2) existing Bigin deals in the rep's pipeline
 const wantFields=['Deal_Name','Stage','Pipeline','Sub_Pipeline'].concat(tiField?[tiField.api_name]:[]);
 let existing=[]; let page=1,more=true,guard=0;
 while(more&&guard<20){guard++;
   const d=await get(API,'/bigin/v2/Pipelines?fields='+wantFields.join(',')+'&per_page=200&page='+page,tok);
   if(d.s!==200)break; const j=JSON.parse(d.b);
   for(const r of (j.data||[])){ if(r.Pipeline&&r.Pipeline.name===rep.bigin_pipeline) existing.push(r); }
   more=j.info&&j.info.more_records; page++;
 }
 console.log('Existing deals in '+rep.bigin_pipeline+': '+existing.length);

 // 3) dedup index: by custom field if present, else by [TI:] tag in name
 const idx={};
 for(const e of existing){
   let pid=null;
   if(tiField&&e[tiField.api_name])pid=String(e[tiField.api_name]).trim();
   else{const m=(e.Deal_Name||'').match(/\[TI:(\d+)\]/);if(m)pid=m[1];}
   if(pid)idx[pid]=e;
 }
 // also index existing by normalized name to warn about pre-existing untagged overlaps
 const byName={}; existing.forEach(e=>byName[(e.Deal_Name||'').toLowerCase().replace(/\[ti:\d+\]/,'').trim()]=e);

 const plan={create:[],update:[],skip:[]}; let nameOverlap=0;
 for(const r of src){
   const val=Number(r.Val||0);
   const tags=[]; if(r.RunningDry==='1')tags.push('Running Dry'); if(r.ReSell==='1')tags.push('Re-Sell');
   const baseName=(r.Property||r.Account||('Project '+r.ProjectID)).slice(0,110);
   const card={
     Deal_Name: tiField? baseName : (baseName+' [TI:'+r.ProjectID+']'),
     Sub_Pipeline:rep.aspen_feed_sub, Stage:r.Lane, Amount:val,
     Owner:{id:rep.bigin_owner_id}, Tag:tags,
     projectId:r.ProjectID, account:r.Account
   };
   if(tiField)card[tiField.api_name]=r.ProjectID;
   const ex=idx[r.ProjectID];
   if(!ex){ plan.create.push(card);
     if(byName[baseName.toLowerCase()])nameOverlap++;
   } else if(ex.Stage!==r.Lane)plan.update.push({from:ex.Stage,to:r.Lane,card});
   else plan.skip.push(card);
 }

 // 4) report
 const money=n=>'$'+Number(n).toLocaleString('en-US');
 const laneTally={}; src.forEach(r=>laneTally[r.Lane]=(laneTally[r.Lane]||0)+1);
 const dry=src.filter(r=>r.RunningDry==='1').length, resell=src.filter(r=>r.ReSell==='1').length;
 console.log('\nLane distribution:'); ['Bidding','Working','Scheduled (Won)','Recently Done','Follow Up'].forEach(k=>{if(laneTally[k])console.log('  '+k+': '+laneTally[k]);});
 console.log('Overlay flags: Running Dry '+dry+' | Re-Sell '+resell);
 console.log('\nWOULD CREATE: '+plan.create.length+'  |  WOULD UPDATE stage: '+plan.update.length+'  |  SKIP (unchanged): '+plan.skip.length);
 if(!tiField&&nameOverlap)console.log('\u26a0\ufe0f  '+nameOverlap+' new cards share a name with an existing untagged deal \u2014 possible double-card until the TRIM IT ProjectID field exists.');
 const totalVal=plan.create.reduce((a,c)=>a+c.Amount,0);
 console.log('New-card pipeline value: '+money(totalVal));
 console.log('\n--- sample new cards (top 15 by value) ---');
 plan.create.sort((a,b)=>b.Amount-a.Amount).slice(0,15).forEach(c=>
   console.log('  ['+c.Stage.padEnd(15)+'] '+money(c.Amount).padStart(11)+'  '+c.Deal_Name+(c.Tag.length?'  {'+c.Tag.join(',')+'}':'')+'  ('+c.account+')'));
 if(plan.update.length){console.log('\n--- stage changes ---');
   plan.update.slice(0,15).forEach(u=>console.log('  '+u.from+' -> '+u.to+'  '+u.card.Deal_Name));}
 console.log('\n*** DRY-RUN ONLY — nothing was written to Bigin. ***');
 const outp=path.join(DIR,'dry-run-'+REP+'.json');
 fs.writeFileSync(outp,JSON.stringify({rep,generated:new Date().toISOString(),dedupMode,counts:{create:plan.create.length,update:plan.update.length,skip:plan.skip.length},plan},null,2));
 console.log('Full plan written: '+outp);
})().catch(e=>{console.error('ERR',e.message);process.exit(1);});
