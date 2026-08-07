// AD08: search Sedan, paginate all result pages, collect every register row (cote/type/dates + its viewer button term).
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const COMMUNE=process.argv[2]||'Sedan';
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1500,height:1700},locale:'fr-FR'});
  const p=await ctx.newPage();
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
  const collectRows=async()=>p.evaluate(()=>{
    const out=[];
    document.querySelectorAll('tr,li').forEach(row=>{
      const txt=(row.innerText||'').replace(/\s+/g,' ').trim();
      if(!/(2E|EDEPOT|1 Mi|Mi )/.test(txt) && !/décenn|decenn|naissance|mariage|décès|deces|baptême/i.test(txt)) return;
      if(txt.length<8) return;
      const btn=row.querySelector('button[data-rebond],button[data-term],a[data-rebond]');
      const term=btn?(btn.getAttribute('data-term')||btn.innerText||'').trim().slice(0,60):'';
      const reb=btn?(btn.getAttribute('data-rebond')||''):'';
      out.push({txt:txt.slice(0,160),term,reb});
    });
    return out;
  });
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const c=await p.$('#commune'); if(c){ await c.click(); await c.type(COMMUNE,{delay:90}); }
    await sleep(2500); await p.keyboard.press('ArrowDown'); await sleep(400); await p.keyboard.press('Enter'); await sleep(1200);
    try{ await p.getByRole('button',{name:/^rechercher$/i}).first().click({force:true,timeout:8000}); }catch(e){ await p.keyboard.press('Enter'); }
    await sleep(7000);
    try{ await p.selectOption('#select_nombre_resultats','100'); await sleep(4500); }catch(e){}
    let all=[]; let seen=new Set();
    for(let pg=1; pg<=8; pg++){
      const rows=await collectRows();
      rows.forEach(r=>{ const k=r.txt.slice(0,60); if(!seen.has(k)){ seen.add(k); all.push({pg,...r}); }});
      // try to go to next page
      let moved=false;
      try{ const nb=p.getByRole('button',{name:String(pg+1)}).first(); if(await nb.count()){ await nb.click({force:true}); await sleep(4000); moved=true; } }catch(e){}
      if(!moved){ // try a "suivant"/next arrow
        try{ const nx=p.getByRole('button',{name:/suivant|›|»/i}).first(); if(await nx.count()){ await nx.click({force:true}); await sleep(4000); moved=true; } }catch(e){}
      }
      if(!moved) break;
    }
    fs.writeFileSync(`${OUT}/paginate-${COMMUNE}.json`,JSON.stringify(all,null,1));
    console.log('TOTAL ROWS:',all.length);
    console.log('\n=== ROWS mentioning naissance / décennale / 186x / état-civil cotes ===');
    all.filter(r=>/décenn|decenn|naissance|186[0-9]|2 E|2E4/i.test(r.txt)).slice(0,60).forEach(r=>console.log(`p${r.pg} [${r.term}] ${r.txt}`));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
