// Open a person's Sources tab, click the source row matching a needle, dump the detail drawer.
// Usage: node fs-click-source.js <PID> "<needle>" <tag>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs = require('fs'); const os = require('os');
const CHROME = os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE = os.homedir()+'/.openclaw/.secrets/fs-state.json';
const PID=process.argv[2], NEEDLE=process.argv[3], TAG=process.argv[4]||'src';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_records'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox','--disable-blink-features=AutomationControlled']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1400,height:1600}});
  const p=await ctx.newPage();
  try{
    await p.goto(`https://www.familysearch.org/tree/person/sources/${PID}`,{waitUntil:'domcontentloaded',timeout:60000});
    await sleep(6000);
    const before=(await p.evaluate(()=>document.body.innerText||'')).length;
    // try clicking the row/link containing the needle
    let clicked=false;
    const loc = p.getByText(new RegExp(NEEDLE,'i')).first();
    if(await loc.count()){ try{ await loc.click({timeout:8000}); clicked=true; }catch(e){ console.log('click1 fail',e.message);} }
    await sleep(5000);
    // If a "View" / "Review Attachment" / detail appeared, capture full text
    const text=await p.evaluate(()=>document.body.innerText||'');
    fs.writeFileSync(`${OUT}/${TAG}.txt`,text);
    console.log(`=== ${TAG} clicked=${clicked} needle="${NEEDLE}" (len ${before}->${text.length}) ===`);
    // Print the region around the needle
    const idx=text.toLowerCase().indexOf(NEEDLE.toLowerCase());
    console.log(idx>=0? text.slice(Math.max(0,idx-200), idx+1500) : text.slice(0,1800));
  }catch(e){ console.log('ERR',e.message); }
  finally{ await b.close(); }
})();
