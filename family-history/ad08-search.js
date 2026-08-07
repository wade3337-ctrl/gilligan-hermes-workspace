// Drive AD08 nominative search: fill name, choose Naissance/Sedan, submit; dump results + fiche links.
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const NOM=process.argv[2]||'Mathieu';
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1400,height:1400},locale:'fr-FR'});
  const p=await ctx.newPage();
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil/recherche-nominative';
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(5000);
    // capture all text inputs on page
    const fields=await p.evaluate(()=>Array.from(document.querySelectorAll('input[type=text],input:not([type]),input[type=search]')).map(e=>({name:e.name,id:e.id,ph:e.placeholder,cls:e.className})));
    fs.writeFileSync(`${OUT}/textfields.json`,JSON.stringify(fields,null,1));
    console.log('TEXT FIELDS:',JSON.stringify(fields));
    // try to type name into first text field
    let typed=false;
    for(const f of fields){ const sel=f.id?('#'+f.id):(f.name?`[name="${f.name}"]`:null); if(!sel)continue; try{ await p.fill(sel,NOM); typed=true; console.log('typed into',sel); break;}catch(e){} }
    if(!typed){ const el=await p.$('input[type=text]'); if(el){await el.fill(NOM); typed=true; console.log('typed via generic');} }
    // set results per page to 100 if the select exists
    try{ await p.selectOption('#select_nombre_resultats','100'); console.log('set 100/page'); }catch(e){}
    await sleep(500);
    // click Rechercher
    const rb=p.getByRole('button',{name:/rechercher/i}).first();
    if(await rb.count()){ await rb.click(); console.log('clicked Rechercher'); } else { await p.keyboard.press('Enter'); }
    await sleep(6000);
    try{ await p.selectOption('#select_nombre_resultats','100'); await sleep(4000); }catch(e){}
    let text=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n');
    // page through up to 12 pages collecting Sedan lines
    let sedan=text.split('\n').filter(l=>/sedan/i.test(l));
    for(let pg=2; pg<=12; pg++){
      const nb=p.getByRole('button',{name:new RegExp('^'+pg+'$')}).first();
      if(!(await nb.count())) break;
      try{ await nb.click(); await sleep(3500); }catch(e){ break; }
      const t=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n');
      sedan=sedan.concat(t.split('\n').filter(l=>/sedan/i.test(l)));
      text+='\n'+t;
    }
    fs.writeFileSync(`${OUT}/sedan-lines-${NOM}.txt`, [...new Set(sedan)].join('\n'));
    console.log('\n=== SEDAN lines across pages ==='); console.log([...new Set(sedan)].slice(0,80).join('\n'));
    // grab result rows mentioning Mathieu / Sedan / Naissance
    const rows=text.split('\n').filter(l=>/mathieu|sedan|naissance|186[0-9]/i.test(l));
    fs.writeFileSync(`${OUT}/search-${NOM}.txt`,text);
    console.log('\n=== matching lines ==='); console.log(rows.slice(0,60).join('\n'));
    const fiches=await p.evaluate(()=>Array.from(document.querySelectorAll('a[href*="fiche"],a[href*="redirect"]')).map(a=>a.getAttribute('href')));
    fs.writeFileSync(`${OUT}/fiches-${NOM}.json`,JSON.stringify([...new Set(fiches)],null,1));
    console.log('\n=== fiche links (first 15) ==='); [...new Set(fiches)].slice(0,15).forEach(h=>console.log(h));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
