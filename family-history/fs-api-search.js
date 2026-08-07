// FamilySearch search API (same-origin fetch) -> parse marriage entries, filter for our Rhoda.
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_records'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const QUERIES = process.argv.slice(2);
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox','--disable-blink-features=AutomationControlled']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'});
  const p=await ctx.newPage();
  try{
    await p.goto('https://www.familysearch.org/search/record/results',{waitUntil:'domcontentloaded',timeout:60000}); await sleep(3000);
    for(const q of QUERIES){
      const url='/service/search/hr/v2/personas?'+q+'&count=100';
      const raw = await p.evaluate(async(u)=>{ try{const r=await fetch(u,{headers:{Accept:'application/json'},credentials:'include'}); return await r.text();}catch(e){return JSON.stringify({err:String(e)});} }, url);
      fs.writeFileSync(`${OUT}/api-${q.replace(/[^a-z0-9]+/gi,'_').slice(0,40)}.json`, raw);
      let j; try{ j=JSON.parse(raw); }catch(e){ console.log('parse fail',q, raw.slice(0,200)); continue; }
      console.log(`\n##### QUERY: ${q}  (results=${j.results}) #####`);
      const ents=(j.entries||[]);
      let shown=0;
      for(const e of ents){
        const gx=e.content&&e.content.gedcomx; if(!gx) continue;
        const persons=(gx.persons||[]).map(pp=>({name:pp.display&&pp.display.name, role:pp.display&&pp.display.role, ark:(pp.identifiers&&pp.identifiers['http://gedcomx.org/Persistent']||[])[0]}));
        const rels=gx.relationships||[];
        let date='',place='';
        for(const r of rels){ for(const f of (r.facts||[])){ if(f.date&&f.date.original)date=f.date.original; if(f.place&&f.place.original)place=f.place.original; } }
        const blob=(persons.map(x=>x.name+'('+x.role+')').join(' + ')+' | '+date+' | '+place);
        // filter: California OR bride surname Gaunt/Hanley/Davis, and a Rhoda present
        const hasRhoda=/rhoda/i.test(blob);
        const relevant = hasRhoda && (/california/i.test(place) || /Gaunt|Hanley/i.test(blob));
        if(relevant){ console.log('  ★', blob); persons.forEach(x=>{ if(x.ark) console.log('     ',x.role, x.name, x.ark); }); shown++; }
      }
      if(!shown){ console.log('  (no CA/Gaunt/Hanley Rhoda match in top 100; first 5 raw:)'); ents.slice(0,5).forEach(e=>{ const gx=e.content&&e.content.gedcomx; const ns=(gx&&gx.persons||[]).map(pp=>pp.display&&pp.display.name+'('+(pp.display&&pp.display.role)+')').join(' + '); let d='',pl=''; (gx&&gx.relationships||[]).forEach(r=>(r.facts||[]).forEach(f=>{if(f.date)d=f.date.original;if(f.place)pl=f.place.original;})); console.log('   -',ns,'|',d,'|',pl); }); }
    }
  }catch(e){ console.log('ERR',e.message); }
  finally{ await b.close(); }
})();
