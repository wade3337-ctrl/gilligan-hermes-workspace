// AD08: search Sedan, walk ALL result pages via real pager buttons, dump EVERY register row (cote+text+viewer term).
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1500,height:1800},locale:'fr-FR'});
  const p=await ctx.newPage();
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
  const grab=async()=>p.evaluate(()=>{
    const out=[];
    document.querySelectorAll('tr,li').forEach(row=>{
      const txt=(row.innerText||'').replace(/\s+/g,' ').trim();
      if(txt.length<10||txt.length>220) return;
      if(!/(2\s?E|EDEPOT|E dépôt|1 Mi|Mi \d|Collection communale)/i.test(txt)) return;
      const btn=row.querySelector('button[data-rebond],button[data-term],a[data-rebond]');
      out.push({txt:txt.slice(0,180),term:btn?(btn.getAttribute('data-term')||btn.innerText||'').trim().slice(0,55):'',reb:btn?(btn.getAttribute('data-rebond')||''):''});
    });
    return out;
  });
  const sig=async()=>{ const r=await grab(); return r.map(x=>x.txt.slice(0,30)).join('|').slice(0,200); };
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const c=await p.$('#commune'); if(c){ await c.click(); await c.type('Sedan',{delay:90}); }
    await sleep(2500); await p.keyboard.press('ArrowDown'); await sleep(400); await p.keyboard.press('Enter'); await sleep(1200);
    try{ await p.getByRole('button',{name:/^rechercher$/i}).first().click({force:true,timeout:8000}); }catch(e){ await p.keyboard.press('Enter'); }
    await sleep(7000);
    try{ await p.selectOption('#select_nombre_resultats','100'); await sleep(5000); }catch(e){}
    const all=[]; const seen=new Set();
    const add=rows=>rows.forEach(r=>{const k=r.txt.slice(0,45); if(!seen.has(k)){seen.add(k);all.push(r);}});
    add(await grab());
    let last=await sig();
    for(let step=0; step<10; step++){
      // click the highest-numbered visible page button, else "Derniers résultats"
      const advanced=await p.evaluate(()=>{
        const nums=Array.from(document.querySelectorAll('button,a')).filter(e=>/^\d+$/.test((e.innerText||'').trim()));
        // find the max numeric page button greater than the current (active) one
        let cur=1; const act=document.querySelector('.pagination .active,.active[aria-current],[aria-current="page"]'); if(act) cur=+(act.innerText||'1')||1;
        const bigger=nums.map(e=>({e,n:+(e.innerText.trim())})).filter(o=>o.n>cur).sort((a,b)=>a.n-b.n)[0];
        if(bigger){ bigger.e.scrollIntoView(); bigger.e.click(); return 'num'; }
        return null;
      });
      if(!advanced) break;
      await sleep(4500);
      const s=await sig(); if(s===last){ break; } last=s;
      add(await grab());
    }
    fs.writeFileSync(`${OUT}/all-sedan.json`,JSON.stringify(all,null,1));
    console.log('TOTAL REGISTER ROWS:',all.length);
    console.log('\n=== rows w/ Naissance or décennale or 185x-187x ===');
    all.filter(r=>/naiss|décenn|decenn|18[567][0-9]/i.test(r.txt)).forEach(r=>console.log(`[term=${r.term}] ${r.txt}`));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
