// Dump ALL hrefs from a FS page (authenticated). Usage: node fs-links.js "<url>" <grep>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const URL=process.argv[2], GREP=(process.argv[3]||'catalog').toLowerCase();
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'});
  const p=await ctx.newPage();
  try{
    await p.goto(URL,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const links=await p.evaluate(()=>Array.from(document.querySelectorAll('a[href]')).map(a=>({t:(a.innerText||'').trim().replace(/\s+/g,' ').slice(0,70),h:a.href})));
    const hit=links.filter(l=>(l.h||'').toLowerCase().includes(GREP));
    console.log('matches for "'+GREP+'":');
    [...new Map(hit.map(l=>[l.h,l])).values()].forEach(l=>console.log(' •',l.t,'->',l.h));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
