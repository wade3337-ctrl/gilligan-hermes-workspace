// Reusable FamilySearch puller. Reuses saved session (fs-state.json).
// Usage: node fs-pull.js <PID> [slug]
// Dumps: ancestors innerText + related PIDs, tree/details, tree/sources -> _data/<PID>/
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs = require('fs'); const os = require('os');
const CHROME = os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE = os.homedir()+'/.openclaw/.secrets/fs-state.json';
const PID = process.argv[2];
if(!PID){ console.error('need PID'); process.exit(1); }
const OUT = '/home/wade3337/.openclaw/workspace/family-history/_data/'+PID;
fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));

(async()=>{
  const browser = await chromium.launch({headless:true, executablePath:CHROME, args:['--no-sandbox','--disable-blink-features=AutomationControlled']});
  const ctx = await browser.newContext({storageState:STATE,
    userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
    viewport:{width:1366,height:1400}, locale:'en-US'});
  const page = await ctx.newPage();
  const grab = async (url,tag,waitMs=5000)=>{
    try{
      await page.goto(url,{waitUntil:'domcontentloaded',timeout:60000});
      await sleep(waitMs);
      const text = await page.evaluate(()=>document.body.innerText||'');
      const links = await page.evaluate(()=>Array.from(document.querySelectorAll('a[href]'))
        .map(a=>({t:(a.innerText||'').trim().replace(/\s+/g,' ').slice(0,60), h:a.getAttribute('href')}))
        .filter(x=>/\b[A-Z0-9]{4}-[A-Z0-9]{3,4}\b/.test(x.h||'')));
      fs.writeFileSync(`${OUT}/${tag}.txt`, text);
      fs.writeFileSync(`${OUT}/${tag}.links.json`, JSON.stringify(links,null,1));
      console.log(`\n===== ${tag} (${url}) =====`);
      console.log(text.slice(0,1800));
      // unique related PIDs
      const pids={};
      links.forEach(l=>{ const m=(l.h||'').match(/\b([A-Z0-9]{4}-[A-Z0-9]{3,4})\b/); if(m){ const p=m[1]; if(p!==PID && !pids[p]) pids[p]=l.t; }});
      const rel=Object.entries(pids).map(([p,t])=>`${p}  ${t}`);
      if(rel.length){ console.log(`--- related PIDs (${tag}) ---`); console.log(rel.join('\n')); }
    }catch(e){ console.log(tag,'ERR',e.message); }
  };
  await grab(`https://ancestors.familysearch.org/en/${PID}/x`,'ancestors',5000);
  await grab(`https://www.familysearch.org/tree/person/details/${PID}`,'details',6000);
  await grab(`https://www.familysearch.org/tree/person/sources/${PID}`,'sources',6000);
  await browser.close();
  console.log('\n[done] saved to', OUT);
})();
