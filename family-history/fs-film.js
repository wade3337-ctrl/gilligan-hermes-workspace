// Open a FamilySearch film image and screenshot the viewer. Usage: node fs-film.js <film> <imageIndex>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const FILM=process.argv[2], I=process.argv[3]||'1';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_film'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1500,height:1200},deviceScaleFactor:2});
  const p=await ctx.newPage();
  try{
    await p.goto(`https://www.familysearch.org/search/film/${FILM}?i=${I}`,{waitUntil:'domcontentloaded',timeout:60000});
    await sleep(9000);
    const txt=(await p.evaluate(()=>document.body.innerText||'')).replace(/\s+/g,' ').slice(0,600);
    console.log('IMG',I,'CONTEXT:',txt);
    await p.screenshot({path:`${OUT}/img-${String(I).padStart(4,'0')}.png`});
    console.log('shot',`${OUT}/img-${String(I).padStart(4,'0')}.png`);
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
