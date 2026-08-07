// Open a FS image ark, dismiss modals, zoom in, screenshot high-res. Usage: node fs-zoom.js "<ark-url>" <tag> <zoomClicks>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const URL=process.argv[2], TAG=process.argv[3]||'zoom', ZC=parseInt(process.argv[4]||'4',10);
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_img'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1600,height:1200},deviceScaleFactor:3});
  const p=await ctx.newPage();
  try{
    await p.goto(URL,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(7000);
    // dismiss modal (NOT NOW / Not now / close)
    for(const re of [/not now/i,/^close$/i,/plus tard/i,/dismiss/i]){ const el=p.getByRole('button',{name:re}).first(); if(await el.count()){ try{await el.click({timeout:3000}); console.log('dismissed',re);}catch(e){} } }
    await sleep(1500);
    // screenshot fit-to-page first
    await p.screenshot({path:`${OUT}/${TAG}-fit.png`});
    // zoom in: try the '+'/zoom-in control, else double-click center, else Ctrl+wheel
    let zoomed=false;
    for(const re of [/zoom in/i,/agrandir/i,/^\+$/]){ const el=p.getByRole('button',{name:re}).first(); if(await el.count()){ for(let i=0;i<ZC;i++){ try{await el.click({timeout:1500}); zoomed=true; await sleep(700);}catch(e){} } if(zoomed)break; } }
    if(!zoomed){ // double-click near the upper-left entry area then wheel-zoom
      const box={x:520,y:430}; for(let i=0;i<ZC;i++){ await p.mouse.dblclick(box.x,box.y); await sleep(600);} zoomed=true; console.log('dblclick-zoom');
    } else console.log('button-zoom x',ZC);
    await sleep(1500);
    await p.screenshot({path:`${OUT}/${TAG}-zoom.png`});
    console.log('shots:', `${TAG}-fit.png`, `${TAG}-zoom.png`);
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
