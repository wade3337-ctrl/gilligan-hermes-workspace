// AD08: apply commune filter via autocomplete-select (replicate phone flow), read filtered register list.
// Usage: node ad08-commune.js "<Commune>"
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const COMMUNE=process.argv[2]||'Bazeilles';
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1400,height:1600},locale:'fr-FR'});
  const p=await ctx.newPage();
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    // focus commune input
    const c=await p.$('#commune'); if(!c){ console.log('no #commune'); }
    await c.click(); await c.type(COMMUNE,{delay:110});
    await sleep(2800);
    // capture autocomplete suggestions
    const sugg=await p.evaluate(()=>{
      const items=[];
      document.querySelectorAll('ul li, .autocomplete li, .ui-menu-item, [role=option], .tt-suggestion').forEach(li=>{const t=(li.innerText||'').trim(); if(t) items.push(t);});
      return items.slice(0,10);
    });
    console.log('autocomplete suggestions:', JSON.stringify(sugg));
    // try clicking a suggestion matching the commune
    let picked=false;
    const opt=p.getByText(new RegExp('^'+COMMUNE+'\\b','i')).first();
    if(await opt.count()){ try{ await opt.click({timeout:5000}); picked=true; console.log('picked suggestion (text)'); }catch(e){console.log('pick text fail',e.message);} }
    if(!picked){ await p.keyboard.press('ArrowDown'); await sleep(500); await p.keyboard.press('Enter'); console.log('kbd select'); }
    await sleep(1500);
    // look for the green count badge / applied filter chip
    const badge=await p.evaluate(()=>{
      const el=document.querySelector('.badge, .compteur, .filtre-actif, [class*="count"]');
      return el?el.innerText.trim():'';
    });
    console.log('badge/chip:', badge);
    // click Rechercher
    try{ await p.getByRole('button',{name:/^rechercher$/i}).first().click({force:true,timeout:8000}); console.log('Rechercher'); }catch(e){ await p.keyboard.press('Enter'); }
    await sleep(7000);
    try{ await p.selectOption('#select_nombre_resultats','100'); await sleep(4000); }catch(e){}
    const text=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n');
    fs.writeFileSync(`${OUT}/commune-${COMMUNE}.txt`,text);
    const nres=(text.match(/([\d\s]+)\s*r[ée]sultats/i)||[])[1]||'?';
    console.log('RESULTS COUNT:', nres.trim());
    // dump register rows for this commune with viewer links
    const rows=await p.evaluate((COM)=>{
      const out=[];
      document.querySelectorAll('tr,li').forEach(row=>{
        const t=(row.innerText||'').replace(/\s+/g,' ').trim();
        if(!new RegExp(COM,'i').test(t)) return;
        if(!/naiss|décenn|decenn|table|186[0-9]|2E|EDEPOT|Mi /i.test(t)) return;
        const a=row.querySelector('a[href*="/image/"],a[href*="redirect-fiche"]');
        const btn=row.querySelector('button[data-term],button[data-rebond]');
        out.push({t:t.slice(0,150), img:a?a.getAttribute('href'):'', term:btn?(btn.getAttribute('data-term')||'').slice(0,40):''});
      });
      return out.slice(0,40);
    }, COMMUNE);
    fs.writeFileSync(`${OUT}/commune-${COMMUNE}-rows.json`,JSON.stringify(rows,null,1));
    console.log('\n=== '+COMMUNE+' register rows ('+rows.length+') ===');
    rows.forEach(r=>console.log(`[${r.term}] ${r.t}\n     img=${(r.img||'').slice(0,70)}`));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
