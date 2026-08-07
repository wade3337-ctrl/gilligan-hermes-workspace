// Open an AD08 fiche redirect, follow into the image viewer, capture final URL + nav controls + a screenshot.
// Usage: node ad08-fiche.js <ficheId>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome';
const ID=process.argv[2];
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1500,height:1300},locale:'fr-FR',deviceScaleFactor:2});
  const p=await ctx.newPage();
  try{
    await p.goto(`https://archives.cd08.fr/_recherche-api/redirect-fiche-principale/${ID}`,{waitUntil:'domcontentloaded',timeout:60000});
    await sleep(8000);
    console.log('FINAL URL:', p.url());
    const text=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n').slice(0,1500);
    console.log('--- TEXT ---'); console.log(text);
    // capture any cote/commune/year metadata + nav buttons
    const meta=await p.evaluate(()=>{
      const t=document.body.innerText||'';
      const grab=re=>{const m=t.match(re);return m?m[0]:'';};
      return {cote:grab(/\b\d?\s?E[\s\d.-]+/), commune:grab(/Sedan|Ardennes/i)};
    });
    console.log('--- META ---', JSON.stringify(meta));
    const links=await p.evaluate(()=>Array.from(document.querySelectorAll('a[href]')).map(a=>a.getAttribute('href')).filter(h=>h&&/ark|viewer|visual|image|\/ec\/|mnesys|cote|fonds/i.test(h)));
    console.log('--- VIEWER-ish LINKS ---'); [...new Set(links)].slice(0,15).forEach(h=>console.log(h));
    await p.screenshot({path:`${OUT}/fiche-${ID}.png`});
    console.log('shot', `${OUT}/fiche-${ID}.png`);
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
