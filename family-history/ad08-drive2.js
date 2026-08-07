// AD08 état-civil: search commune=Sedan, dump results table + ALL fiche/viewer links with row context.
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const COMMUNE=process.argv[2]||'Sedan';
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1400,height:1600},locale:'fr-FR'});
  const p=await ctx.newPage();
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const c=await p.$('#commune');
    if(c){ await c.click(); await c.type(COMMUNE,{delay:80}); console.log('typed commune'); }
    await sleep(2500); // autocomplete
    // choose suggestion via keyboard
    await p.keyboard.press('ArrowDown'); await sleep(400); await p.keyboard.press('Enter'); await sleep(1500);
    // click Rechercher (force)
    try{ const rb=p.getByRole('button',{name:/^rechercher$/i}).first(); await rb.click({force:true,timeout:8000}); console.log('Rechercher'); }
    catch(e){ await p.keyboard.press('Enter'); console.log('enter-fallback'); }
    await sleep(7000);
    // set 100/page if possible
    try{ await p.selectOption('#select_nombre_resultats','100'); await sleep(4000); }catch(e){}
    const text=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n');
    fs.writeFileSync(`${OUT}/drive2-${COMMUNE}.txt`,text);
    // rows: capture links with nearest row text
    const rows=await p.evaluate(()=>{
      const out=[];
      document.querySelectorAll('a[href*="redirect-fiche"],a[href*="fiche-principale"]').forEach(a=>{
        let row=a.closest('tr,li,.arko-resultats-ligne,.ligne,div');
        const t=(row?row.innerText:a.innerText||'').replace(/\s+/g,' ').trim().slice(0,140);
        out.push({h:a.getAttribute('href'),t});
      });
      return out;
    });
    fs.writeFileSync(`${OUT}/drive2-rows.json`,JSON.stringify(rows,null,1));
    console.log('\n=== TABLE TEXT (naissance/décennale/186x lines) ===');
    console.log(text.split('\n').filter(l=>/naiss|d\u00e9cenn|table|186[0-9]|185[0-9]|registre|E \d/i.test(l)).slice(0,60).join('\n'));
    console.log('\n=== FICHE ROWS ('+rows.length+') ===');
    rows.slice(0,40).forEach(r=>console.log(r.h,'::',r.t));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
