// Try FS catalog API (same-origin) for a place; dump JSON. Usage: node fs-catapi.js "Hayange"
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const PLACE=process.argv[2]||'Hayange';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_records'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'});
  const p=await ctx.newPage();
  try{
    await p.goto('https://www.familysearch.org/search/catalog',{waitUntil:'domcontentloaded',timeout:60000}); await sleep(4000);
    const urls=[
      '/service/search/catalog/search?q.placeKeywords='+encodeURIComponent(PLACE),
      '/service/search/catalog?q.placeKeywords='+encodeURIComponent(PLACE),
      '/service/tree/catalog/search?placeKeywords='+encodeURIComponent(PLACE),
      '/catalog/search?q.placeKeywords='+encodeURIComponent(PLACE)
    ];
    for(const u of urls){
      const r=await p.evaluate(async(u)=>{try{const res=await fetch(u,{headers:{Accept:'application/json'},credentials:'include'});const t=await res.text();return {s:res.status,ct:res.headers.get('content-type'),len:t.length,body:t.slice(0,1200)};}catch(e){return{err:String(e)};}},u);
      console.log('\n### '+u+' -> status='+r.s+' ct='+r.ct+' len='+r.len+(r.err?(' ERR '+r.err):''));
      if(r.body && /json/i.test(r.ct||'')) console.log(r.body);
      else if(r.body) console.log('(non-json)', r.body.slice(0,120));
    }
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
