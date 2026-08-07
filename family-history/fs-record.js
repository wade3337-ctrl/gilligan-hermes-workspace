// Open a FamilySearch URL with the saved session and dump innerText + ark links.
// Usage: node fs-record.js "<url>" <tag>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs = require('fs'); const os = require('os');
const CHROME = os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE = os.homedir()+'/.openclaw/.secrets/fs-state.json';
const URL = process.argv[2]; const TAG = process.argv[3]||'rec';
const OUT = '/home/wade3337/.openclaw/workspace/family-history/_data/_records';
fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b = await chromium.launch({headless:true, executablePath:CHROME, args:['--no-sandbox','--disable-blink-features=AutomationControlled']});
  const ctx = await b.newContext({storageState:STATE, userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', viewport:{width:1366,height:1400}});
  const p = await ctx.newPage();
  try{
    await p.goto(URL,{waitUntil:'domcontentloaded',timeout:60000});
    await sleep(7000);
    for(let i=0;i<3;i++){
      const t = await p.evaluate(()=>document.body.innerText||'');
      if(/Something Went Wrong|unable to display/i.test(t)){ console.log('retry reload',i+1); await p.reload({waitUntil:'domcontentloaded',timeout:60000}); await sleep(8000);} else break;
    }
    const text = await p.evaluate(()=>document.body.innerText||'');
    const links = await p.evaluate(()=>Array.from(document.querySelectorAll('a[href]')).map(a=>({t:(a.innerText||'').trim().replace(/\s+/g,' ').slice(0,80),h:a.getAttribute('href')})).filter(x=>/ark:|\/record\/|\/memorial\//.test(x.h||'')));
    fs.writeFileSync(`${OUT}/${TAG}.txt`, text);
    fs.writeFileSync(`${OUT}/${TAG}.links.json`, JSON.stringify(links,null,1));
    console.log('=== '+TAG+' ('+URL+') ===');
    console.log(text.slice(0,3500));
    if(links.length){ console.log('--- record links ---'); links.slice(0,25).forEach(l=>console.log(l.t,'->',l.h)); }
  }catch(e){ console.log('ERR',e.message); }
  finally{ await b.close(); }
})();
