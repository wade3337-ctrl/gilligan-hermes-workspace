// Drive the FamilySearch record-search FORM (not URL params) with the saved session.
// Usage: node fs-search-form.js
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const STATE=os.homedir()+'/.openclaw/.secrets/fs-state.json';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_records'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox','--disable-blink-features=AutomationControlled']});
  const ctx=await b.newContext({storageState:STATE,userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1400,height:1600}});
  const p=await ctx.newPage();
  const tryFill=async(labels,val)=>{ for(const l of labels){ try{ const el=p.getByLabel(l,{exact:false}).first(); if(await el.count()){ await el.fill(val); console.log('filled',l,'=',val); return true; } }catch(e){} } 
    // fallback by placeholder
    for(const l of labels){ const el=await p.$(`input[placeholder*="${l}"]`); if(el){ await el.fill(val); console.log('ph-filled',l); return true; } } return false; };
  try{
    await p.goto('https://www.familysearch.org/search/record/results',{waitUntil:'domcontentloaded',timeout:60000});
    await sleep(6000);
    // dump input labels for debugging
    const inputs=await p.evaluate(()=>Array.from(document.querySelectorAll('input,button')).map(e=>({tag:e.tagName,type:e.type||'',al:e.getAttribute('aria-label')||'',ph:e.getAttribute('placeholder')||'',name:e.getAttribute('name')||'',txt:(e.innerText||'').slice(0,30)})).filter(x=>x.al||x.ph||x.name||x.txt));
    fs.writeFileSync(`${OUT}/searchform-inputs.json`,JSON.stringify(inputs,null,1));
    await tryFill(['First Names','Given Names','First'],'Rhoda');
    await tryFill(["Spouse's Last Names",'Spouse Last','Spouse\u2019s Last Names'],'Davis');
    // marriage year range
    await tryFill(['Marriage Year','From'],'1960'); await tryFill(['To'],'1970');
    await sleep(500);
    // click SEARCH button
    let sb = p.getByRole('button',{name:/^search$/i}).first();
    if(await sb.count()){ await sb.click(); console.log('clicked SEARCH'); } else { await p.keyboard.press('Enter'); }
    await sleep(8000);
    for(let i=0;i<3;i++){ const t=await p.evaluate(()=>document.body.innerText||''); if(/Something Went Wrong|unable to display/i.test(t)){ console.log('reload',i+1); await p.reload({waitUntil:'domcontentloaded',timeout:60000}); await sleep(8000);} else break; }
    const text=await p.evaluate(()=>document.body.innerText||'');
    fs.writeFileSync(`${OUT}/search-rhoda-davis.txt`,text);
    console.log('=== RESULTS ==='); console.log(text.slice(0,3000));
  }catch(e){ console.log('ERR',e.message); }
  finally{ await b.close(); }
})();
