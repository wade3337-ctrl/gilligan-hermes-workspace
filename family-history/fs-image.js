// Open a FS record ark, click "View Original Document", screenshot the image viewer. Usage: node fs-image.js <ark-url> <tag>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const URL=process.argv[2], TAG=process.argv[3]||'img';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_img'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1500,height:1400},deviceScaleFactor:2});
  const p=await ctx.newPage();
  try{
    await p.goto(URL,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(5000);
    // click "View Original Document" / "View the Original"
    let clicked=false;
    for(const re of [/view original document/i,/view the original/i,/view image/i,/original document/i]){
      const el=p.getByText(re).first();
      if(await el.count()){ try{ await el.click({timeout:6000}); clicked=true; console.log('clicked',re); break;}catch(e){} }
    }
    await sleep(2500);
    // handle possible new tab
    const pages=ctx.pages(); const pg=pages[pages.length-1];
    await pg.waitForTimeout(6000);
    console.log('URL now:', pg.url());
    const txt=(await pg.evaluate(()=>document.body.innerText||'')).replace(/\s+/g,' ').slice(0,400);
    console.log('TEXT:', txt);
    await pg.screenshot({path:`${OUT}/${TAG}.png`});
    console.log('shot', `${OUT}/${TAG}.png`, 'clicked=',clicked);
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
