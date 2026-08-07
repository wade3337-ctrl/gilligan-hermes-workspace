// Load an AD08 (archives.cd08.fr) page, dump text + forms/inputs + links. Usage: node ad08.js "<url>" <tag>
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs=require('fs'), os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
const URL=process.argv[2], TAG=process.argv[3]||'ad08';
const OUT='/home/wade3337/.openclaw/workspace/family-history/_data/_ad08'; fs.mkdirSync(OUT,{recursive:true});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox','--disable-blink-features=AutomationControlled']});
  const ctx=await b.newContext({userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',viewport:{width:1400,height:1200},locale:'fr-FR'});
  const p=await ctx.newPage();
  try{
    await p.goto(URL,{waitUntil:'domcontentloaded',timeout:60000}); await sleep(6000);
    const text=(await p.evaluate(()=>document.body.innerText||'')).replace(/\n{2,}/g,'\n').slice(0,2500);
    const inputs=await p.evaluate(()=>Array.from(document.querySelectorAll('input,select,button,a')).map(e=>({tag:e.tagName,type:e.type||'',name:e.name||'',id:e.id||'',ph:e.placeholder||'',al:e.getAttribute&&e.getAttribute('aria-label')||'',txt:(e.innerText||e.value||'').trim().slice(0,40),href:e.getAttribute&&e.getAttribute('href')||''})).filter(x=>x.name||x.id||x.ph||x.al||(x.tag!=='A'&&x.txt)||/mathieu|sedan|naiss|etat|regist|visual|viewer|1866/i.test(x.href)));
    fs.writeFileSync(`${OUT}/${TAG}.txt`,text);
    fs.writeFileSync(`${OUT}/${TAG}.dom.json`,JSON.stringify(inputs,null,1));
    console.log('=== TEXT ==='); console.log(text);
    console.log('\n=== INPUTS/SELECTS/BUTTONS ==='); inputs.filter(x=>x.tag!=='A').slice(0,40).forEach(x=>console.log(`${x.tag} type=${x.type} name="${x.name}" id="${x.id}" ph="${x.ph}" al="${x.al}" txt="${x.txt}"`));
    console.log('\n=== INTERESTING LINKS ==='); inputs.filter(x=>x.tag==='A'&&x.href).slice(0,25).forEach(x=>console.log(`${x.txt} -> ${x.href}`));
  }catch(e){console.log('ERR',e.message);}
  finally{await b.close();}
})();
