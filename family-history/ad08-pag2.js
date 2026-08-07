// AD08: search Sedan, diagnose pagination control, click through pages, collect état-civil rows (naissance/décennale/186x).
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
    document.querySelectorAll('tr,li,div').forEach(row=>{
      const txt=(row.innerText||'').replace(/\s+/g,' ').trim();
      if(txt.length<10||txt.length>200) return;
      if(!/(2 E|2E|EDEPOT|E dépôt).*(naiss|décenn|decenn|mariage|décès)|table décenn|naissance.*186|décenn.*186|186[0-9].*naiss/i.test(txt)) return;
      const btn=row.querySelector('button[data-rebond],button[data-term],a[data-rebond]');
      out.push({txt:txt.slice(0,170),term:btn?(btn.getAttribute('data-term')||btn.innerText||'').trim().slice(0,50):'',reb:btn?(btn.getAttribute('data-rebond')||''):''});
    });
    return out;
  });
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const c=await p.$('#commune'); if(c){ await c.click(); await c.type('Sedan',{delay:90}); }
    await sleep(2500); await p.keyboard.press('ArrowDown'); await sleep(400); await p.keyboard.press('Enter'); await sleep(1200);
    try{ await p.getByRole('button',{name:/^rechercher$/i}).first().click({force:true,timeout:8000}); }catch(e){ await p.keyboard.press('Enter'); }
    await sleep(7000);
    try{ await p.selectOption('#select_nombre_resultats','100'); await sleep(4500); }catch(e){}
    // Diagnose pagination controls
    const pag=await p.evaluate(()=>{
      const cand=Array.from(document.querySelectorAll('a,button')).filter(e=>{
        const t=(e.innerText||'').trim(); const c=(e.className||''); const h=e.getAttribute('href')||'';
        return /^\d+$/.test(t)&&+t<=12 || /pagin|suivant|next|page/i.test(c+h+(e.getAttribute('aria-label')||''));
      }).map(e=>({tag:e.tagName,txt:(e.innerText||'').trim().slice(0,15),cls:(e.className||'').slice(0,40),href:(e.getAttribute('href')||'').slice(0,60),al:e.getAttribute('aria-label')||''}));
      return cand.slice(0,30);
    });
    fs.writeFileSync(`${OUT}/pag-controls.json`,JSON.stringify(pag,null,1));
    console.log('=== PAGINATION CANDIDATES ==='); pag.forEach(x=>console.log(`<${x.tag}> "${x.txt}" cls="${x.cls}" href="${x.href}" al="${x.al}"`));
    // collect page 1 hits, then click numeric pages 2..7
    let all=[]; const seen=new Set();
    const add=rows=>rows.forEach(r=>{const k=r.txt.slice(0,50); if(!seen.has(k)){seen.add(k);all.push(r);}});
    add(await grab());
    for(let pg=2; pg<=7; pg++){
      let moved=false;
      // strategy 1: anchor/button whose exact text is the page number, inside a pagination container
      const clicked=await p.evaluate((n)=>{
        const els=Array.from(document.querySelectorAll('a,button')).filter(e=>(e.innerText||'').trim()===String(n));
        // prefer one in a pagination-ish container
        const el=els.find(e=>/pagin|pager|nav/i.test((e.closest('[class]')||{className:''}).className||'')) || els[els.length-1];
        if(el){ el.scrollIntoView(); el.click(); return true; } return false;
      }, pg);
      if(clicked){ await sleep(4500); moved=true; }
      if(!moved) break;
      add(await grab());
    }
    fs.writeFileSync(`${OUT}/pag2-hits.json`,JSON.stringify(all,null,1));
    console.log('\n=== ÉTAT-CIVIL naissance/décennale/186x HITS ('+all.length+') ===');
    all.slice(0,50).forEach(r=>console.log(`[${r.term}] ${r.txt}`));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
