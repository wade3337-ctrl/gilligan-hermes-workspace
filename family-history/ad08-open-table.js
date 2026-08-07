// AD08: filter commune, open the "Table décennale <daterange>" viewer, jump to an image, screenshot + dump image URLs.
// Usage: node ad08-open-table.js "<Commune>" "<daterange>" <imgIndex>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const COMMUNE=process.argv[2]||'Bazeilles', RANGE=process.argv[3]||'1863-1872', TARGET=parseInt(process.argv[4]||'13',10);
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1500,height:1400},deviceScaleFactor:2,locale:'fr-FR'});
  const p=await ctx.newPage();
  const imgUrls=new Set();
  p.on('response',r=>{const u=r.url(); if(/\/image\/2516\//.test(u)) imgUrls.add(u.split('?')[0]);});
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const c=await p.$('#commune'); await c.click(); await c.type(COMMUNE,{delay:110}); await sleep(2600);
    await p.keyboard.press('ArrowDown'); await sleep(500); await p.keyboard.press('Enter'); await sleep(1500);
    try{ await p.getByRole('button',{name:/^rechercher$/i}).first().click({force:true,timeout:8000}); }catch(e){ await p.keyboard.press('Enter'); }
    await sleep(6500);
    // click the Table décennale <RANGE> row's button
    const clicked=await p.evaluate((args)=>{
      const [RANGE]=args;
      const rows=Array.from(document.querySelectorAll('tr,li'));
      for(const row of rows){
        const t=(row.innerText||'');
        if(/décenn|decenn/i.test(t) && t.includes(RANGE)){
          const btn=row.querySelector('button[data-term],button[data-rebond],a');
          if(btn){ btn.scrollIntoView(); btn.click(); return t.replace(/\s+/g,' ').slice(0,80); }
        }
      }
      return null;
    },[RANGE]);
    console.log('clicked décennale row:', clicked);
    await sleep(12000);
    console.log('URL now:', p.url());
    // screenshot the viewer as-opened (no jump — jumping was closing the lightbox)
    await p.screenshot({path:`${OUT}/table-${COMMUNE}-${RANGE}-open.png`, fullPage:false});
    console.log('shot', `${OUT}/table-${COMMUNE}-${RANGE}-open.png`);
    // click the viewer 'next' arrow TARGET-1 times to advance, screenshot each few
    for(let k=0;k<TARGET-1;k++){
      const adv=await p.evaluate(()=>{
        const nx=document.querySelector('[aria-label*=uivant],[title*=uivant],.next,.suivant,[class*=next]');
        if(nx){ nx.click(); return true; } return false;
      });
      if(!adv) break; await sleep(1500);
    }
    await sleep(2000);
    await p.screenshot({path:`${OUT}/table-${COMMUNE}-${RANGE}-i${TARGET}.png`, fullPage:false});
    console.log('shot target', `${OUT}/table-${COMMUNE}-${RANGE}-i${TARGET}.png`);
    console.log('IIIF image urls seen:', [...imgUrls].join('\n'));
    fs.writeFileSync(`${OUT}/table-${COMMUNE}-imgurls.json`, JSON.stringify([...imgUrls],null,1));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
