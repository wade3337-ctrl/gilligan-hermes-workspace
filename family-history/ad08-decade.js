// AD08: search Sedan, click the 1863-1872 decade facet via JS, dump filtered register rows + view/IIIF links.
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const COMMUNE=process.argv[2]||'Sedan';
const DECADE=process.argv[3]||'1863-1872';
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1500,height:1700},locale:'fr-FR'});
  const p=await ctx.newPage();
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const c=await p.$('#commune'); if(c){ await c.click(); await c.type(COMMUNE,{delay:90}); }
    await sleep(2500); await p.keyboard.press('ArrowDown'); await sleep(400); await p.keyboard.press('Enter'); await sleep(1200);
    try{ await p.getByRole('button',{name:/^rechercher$/i}).first().click({force:true,timeout:8000}); }catch(e){ await p.keyboard.press('Enter'); }
    await sleep(7000);
    // Click the decade facet whose data-term starts with the decade, via JS
    const clicked=await p.evaluate((dec)=>{
      const btns=Array.from(document.querySelectorAll('button,[data-term],a'));
      const t=btns.find(x=>((x.getAttribute('data-term')||x.innerText||'').trim().startsWith(dec)));
      if(t){ t.scrollIntoView(); t.click(); return (t.getAttribute('data-term')||t.innerText||'').slice(0,40); }
      return null;
    }, DECADE);
    console.log('decade facet clicked:', clicked);
    await sleep(7000);
    try{ await p.selectOption('#select_nombre_resultats','100'); await sleep(4000); }catch(e){}
    // Dump all register rows now shown, with any /image/, arko, or fiche links
    const rows=await p.evaluate(()=>{
      const out=[];
      document.querySelectorAll('tr,li,.arko-ligne,.ligne,article').forEach(row=>{
        const txt=(row.innerText||'').replace(/\s+/g,' ').trim();
        if(!/naiss|décenn|table|186[0-9]|registre|2E|EDEPOT|état civil/i.test(txt)) return;
        const links=Array.from(row.querySelectorAll('a,button,[data-rebond],[data-url],[onclick]')).map(e=>{
          const a={}; for(const at of e.attributes) a[at.name]=at.value.slice(0,90);
          return {tag:e.tagName,txt:(e.innerText||e.getAttribute('title')||'').replace(/\s+/g,' ').trim().slice(0,30),href:a.href||a['data-url']||a['data-rebond']||a.onclick||''};
        }).filter(l=>l.href);
        out.push({txt:txt.slice(0,150),links});
      });
      return out;
    });
    fs.writeFileSync(`${OUT}/decade-${COMMUNE}-${DECADE}.json`,JSON.stringify(rows,null,1));
    const text=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n');
    fs.writeFileSync(`${OUT}/decade-${COMMUNE}-${DECADE}.txt`,text);
    console.log('\n=== ROWS ('+rows.length+') ===');
    rows.forEach((r,i)=>{ console.log(`[${i}] ${r.txt}`); r.links.forEach(l=>console.log(`     <${l.tag}> "${l.txt}" -> ${l.href.slice(0,80)}`)); });
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
