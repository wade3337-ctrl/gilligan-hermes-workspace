// Drive AD08 état-civil register selector: commune=Sedan, decade button, dump register results + fiche links.
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const COMMUNE=process.argv[2]||'Sedan';
const DECADE=process.argv[3]||'1863-1872';
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1400,height:1500},locale:'fr-FR'});
  const p=await ctx.newPage();
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    // fill commune
    try{ await p.fill('#commune',COMMUNE); console.log('commune=',COMMUNE);}catch(e){ console.log('commune fill fail',e.message); }
    await sleep(1200);
    // a commune autocomplete may appear; try to click a matching suggestion
    try{ const sug=p.getByText(new RegExp('^'+COMMUNE+'\\b','i')).first(); if(await sug.count()){ await sug.click({timeout:3000}); console.log('picked commune suggestion'); } }catch(e){}
    await sleep(800);
    // click the decade button
    try{ const db=p.getByRole('button',{name:DECADE}).first(); if(await db.count()){ await db.click(); console.log('decade clicked',DECADE);} else { const alt=p.getByText(DECADE,{exact:true}).first(); if(await alt.count()){await alt.click();console.log('decade via text');} } }catch(e){ console.log('decade fail',e.message); }
    await sleep(1500);
    // click Rechercher
    try{ const rb=p.getByRole('button',{name:/^rechercher$/i}).first(); if(await rb.count()){ await rb.click(); console.log('Rechercher clicked'); } }catch(e){ console.log('search fail',e.message); }
    await sleep(6500);
    const text=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n');
    fs.writeFileSync(`${OUT}/drive-${COMMUNE}-${DECADE}.txt`,text);
    // capture result rows + fiche links
    const rows=text.split('\n').filter(l=>/sedan|naissance|table|d\u00e9cennale|186[0-9]|registre|E \d|cote/i.test(l));
    console.log('\n=== RESULT LINES ==='); console.log(rows.slice(0,50).join('\n'));
    const fiches=await p.evaluate(()=>Array.from(document.querySelectorAll('a[href*="redirect-fiche"],a[href*="fiche"]')).map(a=>a.getAttribute('href')));
    fs.writeFileSync(`${OUT}/drive-fiches.json`,JSON.stringify([...new Set(fiches)],null,1));
    console.log('\n=== FICHE LINKS ==='); [...new Set(fiches)].slice(0,20).forEach(h=>console.log(h));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
