// FamilySearch login -> save storageState (reusable session) -> test pull.
// Uses playwright from arbor-stack/trimit-browser/node_modules.
const { chromium } = require('/home/wade3337/arbor-stack/trimit-browser/node_modules/playwright');
const fs = require('fs');
const os = require('os');

const creds = JSON.parse(fs.readFileSync(os.homedir() + '/.openclaw/.secrets/familysearch.json', 'utf8'));
const STATE = os.homedir() + '/.openclaw/.secrets/fs-state.json';
const DBG = '/home/wade3337/.openclaw/workspace/family-history/_debug';
fs.mkdirSync(DBG, { recursive: true });

const sleep = ms => new Promise(r => setTimeout(r, ms));
async function shot(page, name){ try{ await page.screenshot({path:`${DBG}/${name}.png`, fullPage:false}); console.log('shot', name);}catch(e){console.log('shot-fail',name,e.message);} }

(async () => {
  const CHROME = '/home/wade3337/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell';
  const browser = await chromium.launch({ headless: true, executablePath: CHROME, args:['--no-sandbox','--disable-blink-features=AutomationControlled'] });
  const ctx = await browser.newContext({
    userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
    viewport:{width:1366,height:900}, locale:'en-US'
  });
  const page = await ctx.newPage();
  try {
    console.log('goto sign-in');
    await page.goto('https://www.familysearch.org/auth/familysearch/login?returnUrl=https%3A%2F%2Fwww.familysearch.org%2Ftree%2Foverview', {waitUntil:'domcontentloaded', timeout:60000});
    await sleep(3000); await shot(page,'01-landing');

    // Username step
    const userSel = ['#input28','input[name="userName"]','input[name="username"]','input[type="text"]','input[type="email"]'];
    let filled=false;
    for (const s of userSel){ const el=await page.$(s); if(el){ await el.fill(creds.user); filled=true; console.log('user via',s); break; } }
    if(!filled){ await shot(page,'01b-nouser'); throw new Error('username field not found'); }
    await sleep(600);
    // submit username (button or Enter)
    let nextBtn = await page.$('#sign-in-next-button, button[type="submit"], input[type="submit"]');
    if(nextBtn){ await nextBtn.click(); } else { await page.keyboard.press('Enter'); }
    await sleep(3500); await shot(page,'02-afteruser');

    // Password step
    const pwSel = ['#input36','input[name="password"]','input[type="password"]'];
    let pwFilled=false;
    for (const s of pwSel){ const el=await page.$(s); if(el){ await el.fill(creds.password); pwFilled=true; console.log('pw via',s); break; } }
    if(!pwFilled){ await shot(page,'02b-nopw'); throw new Error('password field not found'); }
    await sleep(600);
    let signBtn = await page.$('#sign-in-button, button[type="submit"], input[type="submit"]');
    if(signBtn){ await signBtn.click(); } else { await page.keyboard.press('Enter'); }
    await sleep(6000); await shot(page,'03-afterpw');

    const url = page.url();
    const title = await page.title();
    console.log('post-login url:', url);
    console.log('post-login title:', title);

    // Consider logged in if we're off the auth/login path
    const loggedIn = !/\/auth\/|login|signin/i.test(url);
    await ctx.storageState({ path: STATE });
    console.log('saved storageState ->', STATE, 'loggedIn?', loggedIn);

    // Test pull: Donald Lee Ainsworth ancestors profile
    await page.goto('https://ancestors.familysearch.org/en/GW3Y-3WN/donald-lee-ainsworth-1931-1990', {waitUntil:'domcontentloaded', timeout:60000});
    await sleep(5000); await shot(page,'04-donald');
    const bodyText = (await page.evaluate(()=>document.body.innerText||'')).slice(0,4000);
    fs.writeFileSync(`${DBG}/donald-profile.txt`, bodyText);
    console.log('=== DONALD PROFILE TEXT (first 1500) ===');
    console.log(bodyText.slice(0,1500));
  } catch(e){
    console.error('ERROR:', e.message);
    await shot(page,'99-error');
  } finally {
    await browser.close();
  }
})();
