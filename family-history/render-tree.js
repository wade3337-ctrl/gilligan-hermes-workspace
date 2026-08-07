const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const os=require('os');
const CHROME=os.homedir()+'/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome';
(async()=>{
  const b=await chromium.launch({headless:true,executablePath:CHROME,args:['--no-sandbox']});
  const p=await b.newPage({viewport:{width:1720,height:1200},deviceScaleFactor:2});
  await p.goto('file:///home/wade3337/.openclaw/workspace/family-history/tree.html',{waitUntil:'networkidle'});
  await p.waitForTimeout(600);
  await p.screenshot({path:'/home/wade3337/.openclaw/workspace/family-history/Wade-Ainsworth-Family-Tree.png',fullPage:true});
  await b.close();
  console.log('rendered PNG');
})();
