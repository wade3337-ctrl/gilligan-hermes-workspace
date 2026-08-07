// AD08: search commune, then dump EVERY clickable element in the results with row context + all attrs.
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const COMMUNE=process.argv[2]||'Sedan';
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1500,height:1600},locale:'fr-FR'});
  const p=await ctx.newPage();
  const url='https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
  try{
    await p.goto(url,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const c=await p.$('#commune'); if(c){ await c.click(); await c.type(COMMUNE,{delay:90}); }
    await sleep(2500); await p.keyboard.press('ArrowDown'); await sleep(400); await p.keyboard.press('Enter'); await sleep(1200);
    try{ await p.getByRole('button',{name:/^rechercher$/i}).first().click({force:true,timeout:8000}); }catch(e){ await p.keyboard.press('Enter'); }
    await sleep(7000);
    try{ await p.selectOption('#select_nombre_resultats','100'); await sleep(4000); }catch(e){}
    // Dump every a/button with attrs + closest row text
    const els=await p.evaluate(()=>{
      const out=[];
      document.querySelectorAll('a,button,[data-rebond],[onclick],[data-url],[data-ark]').forEach(e=>{
        const row=e.closest('tr,li,.arko-ligne,.ligne,article,div');
        const rowtxt=(row?row.innerText:'').replace(/\s+/g,' ').trim().slice(0,120);
        const attrs={}; for(const a of e.attributes){ attrs[a.name]=a.value.slice(0,80); }
        const txt=(e.innerText||e.getAttribute('title')||e.getAttribute('aria-label')||'').replace(/\s+/g,' ').trim().slice(0,50);
        // only keep ones whose row looks like an état-civil register/table row
        if(/décenn|naiss|table|186[0-9]|185[0-9]|187[0-9]|registre|état civil|2E|EDEPOT/i.test(rowtxt)){
          out.push({tag:e.tagName,txt,attrs,rowtxt});
        }
      });
      return out;
    });
    fs.writeFileSync(`${OUT}/rows-full-${COMMUNE}.json`,JSON.stringify(els,null,1));
    console.log('CLICKABLES IN EC ROWS:',els.length);
    els.slice(0,45).forEach((e,i)=>{
      const a=e.attrs; const key=a.href||a['data-rebond']||a['data-url']||a['data-ark']||a.onclick||'';
      console.log(`[${i}] <${e.tag}> "${e.txt}" key=${(key||'').slice(0,70)}\n      row: ${e.rowtxt}`);
    });
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
