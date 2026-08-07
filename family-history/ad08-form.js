// Find the AD08 état-civil register-selection form: dump all SELECTs + their options, and any date inputs.
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const URL=process.argv[2]||'https://archives.cd08.fr/archives-numerisees/sources-genealogiques/registres-paroissiaux-et-detat-civil';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1400,height:1400},locale:'fr-FR'});
  const p=await ctx.newPage();
  try{
    await p.goto(URL,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const selects=await p.evaluate(()=>Array.from(document.querySelectorAll('select')).map(s=>({name:s.name,id:s.id,cls:s.className,opts:Array.from(s.options).slice(0,12).map(o=>o.text.trim()+(o.value?`[${o.value}]`:'')),n:s.options.length})));
    const inputs=await p.evaluate(()=>Array.from(document.querySelectorAll('input')).map(i=>({name:i.name,id:i.id,type:i.type,ph:i.placeholder})));
    const forms=await p.evaluate(()=>Array.from(document.querySelectorAll('form')).map(f=>({action:f.action,id:f.id,cls:f.className})));
    const btns=await p.evaluate(()=>Array.from(document.querySelectorAll('button,a.btn,input[type=submit]')).map(x=>(x.innerText||x.value||'').trim()).filter(Boolean).slice(0,25));
    console.log('URL FINAL:',p.url());
    console.log('\n=== FORMS ==='); forms.forEach(f=>console.log(JSON.stringify(f)));
    console.log('\n=== SELECTS ==='); selects.forEach(s=>console.log(`name="${s.name}" id="${s.id}" (${s.n} opts) :: ${s.opts.join(' | ')}`));
    console.log('\n=== INPUTS ==='); inputs.slice(0,25).forEach(i=>console.log(JSON.stringify(i)));
    console.log('\n=== BUTTONS ==='); console.log(btns.join(' | '));
    fs.writeFileSync(`${OUT}/form-dump.json`,JSON.stringify({selects,inputs,forms,btns,url:p.url()},null,1));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
