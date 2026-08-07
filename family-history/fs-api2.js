// Generic FamilySearch search-API dumper (same-origin fetch, saved session).
// Usage: node fs-api2.js "<querystring>" ["<querystring2>" ...]
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_records'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const Q=process.argv.slice(2);
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox','--disable-blink-features=AutomationControlled']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'});
  const p=await ctx.newPage();
  try{
    await p.goto('https://www.familysearch.org/search/record/results',{waitUntil:'domcontentloaded',timeout:60000}); await sleep(3000);
    for(const q of Q){
      const url='/service/search/hr/v2/personas?'+q+'&count=60';
      const raw=await p.evaluate(async(u)=>{try{const r=await fetch(u,{headers:{Accept:'application/json'},credentials:'include'});return await r.text();}catch(e){return JSON.stringify({err:String(e)});}},url);
      fs.writeFileSync(`${OUT}/apiq-${q.replace(/[^a-z0-9]+/gi,'_').slice(0,50)}.json`,raw);
      let j; try{j=JSON.parse(raw);}catch(e){console.log('parse fail',q,raw.slice(0,150));continue;}
      console.log(`\n##### ${q}  (results=${j.results}) #####`);
      (j.entries||[]).slice(0,15).forEach((e,i)=>{
        const gx=e.content&&e.content.gedcomx; if(!gx)return;
        let coll=''; try{coll=(gx.sourceDescriptions||[]).map(s=>(s.titles||[]).map(t=>t.value).join('')).filter(Boolean)[0]||'';}catch(_){}
        if(!coll && e.title) coll=e.title;
        const ppl=(gx.persons||[]).map(pp=>{const nm=pp.display&&pp.display.name; const role=pp.display&&pp.display.role; return nm?`${nm}${role?'('+role+')':''}`:null;}).filter(Boolean);
        const facts=[]; (gx.persons||[]).forEach(pp=>{(pp.facts||[]).forEach(f=>{const ty=(f.type||'').split('/').pop(); const d=f.date&&f.date.original; const pl=f.place&&f.place.original; if(d||pl)facts.push(`${ty}:${d||''}${pl?'@'+pl:''}`);});});
        (gx.relationships||[]).forEach(r=>{(r.facts||[]).forEach(f=>{const ty=(f.type||'').split('/').pop(); const d=f.date&&f.date.original; const pl=f.place&&f.place.original; if(d||pl)facts.push(`${ty}:${d||''}${pl?'@'+pl:''}`);});});
        console.log(`  [${i}] {${coll}}  ${ppl.join(' + ')}`);
        if(facts.length) console.log(`       ${[...new Set(facts)].slice(0,6).join(' | ')}`);
      });
    }
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
