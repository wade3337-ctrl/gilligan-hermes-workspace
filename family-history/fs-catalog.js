// Search FS catalog for a place's records (civil registration / church). Usage: node fs-catalog.js "<place>"
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const PLACE=process.argv[2]||'Hayange, Moselle, France';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_records'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'});
  const p=await ctx.newPage();
  try{
    await p.goto('https://www.familysearch.org/search/catalog/results?q.placeKeywords='+encodeURIComponent(PLACE),{waitUntil:'domcontentloaded',timeout:60000});
    await sleep(6000);
    const text=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n');
    console.log('=== CATALOG RESULTS for',PLACE,'===');
    console.log(text.slice(0,2200));
    const links=await p.evaluate(()=>Array.from(document.querySelectorAll('a[href*="/catalog/"]')).map(a=>({t:(a.innerText||'').trim().slice(0,70),h:a.getAttribute('href')})).filter(x=>x.t));
    console.log('\n=== catalog links ==='); [...new Map(links.map(l=>[l.h,l])).values()].slice(0,20).forEach(l=>console.log(l.t,'->',l.h));
    fs.writeFileSync(`${OUT}/catalog-${PLACE.split(',')[0]}.txt`,text);
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
