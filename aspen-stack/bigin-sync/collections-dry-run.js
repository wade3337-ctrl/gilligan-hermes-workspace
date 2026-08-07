#!/usr/bin/env node
/*
 * Aspen -> Bigin COLLECTIONS DRY-RUN (v1). Reads the LIVE AR feed (ar-collections-monitor.js --json,
 * sourced from Dimitry's weekly email — NOT TRIM IT), maps each behind account to a per-account card in
 * the rep's Aspen Feed @ Collections stage, checks Bigin for existing cards, and REPORTS what WOULD be
 * created / updated / cleared / skipped. WRITES NOTHING. Review gate before go-live.
 *
 * Design (locked 2026-08-07):
 *   - Card granularity = per ACCOUNT (PM company); properties listed in the card notes.  [decision A]
 *   - Source = Dimitry's email feed (QuickBooks->Aspen back-feed is a later phase).
 *   - Routing = BestRep (already computed by the monitor).
 *   - Lifecycle: auto-clear when the account drops off the newest report (=paid);
 *                crossing 90+ escalates to Jason+Nate.  [decision B]
 *   - Property-manager "who to call" = Phase-2 enrichment (not in the email); omitted for now.
 *   - Dedup: [AR:<slug>] tag embedded in Deal_Name (stable per account, like [TI:] on the sell side).
 *
 * Usage: node collections-dry-run.js ["Rep Name"]      (default "Ethan Chesley" = pilot)
 */
const fs = require('fs'), https = require('https'), cp = require('child_process'), path = require('path');
const DIR = __dirname;
const REP_NAME = process.argv[2] || 'Ethan Chesley';
const MONITOR = '/home/wade3337/arbor-stack/anomaly-monitor/ar-collections-monitor.js';
const AR_DIR = '/home/wade3337/arbor-stack/ar-report';
const STAGE = 'Collections';

const ownerMap = JSON.parse(fs.readFileSync(path.join(DIR, 'owner-map.json'), 'utf8'));
const repByName = {};
Object.entries(ownerMap.reps).forEach(([id, r]) => { repByName[r.name] = Object.assign({ salesRepId: id }, r); });
const rep = repByName[REP_NAME];
if (!rep) { console.error('No rep "' + REP_NAME + '" in owner-map.json. Known: ' + Object.keys(repByName).join(', ')); process.exit(1); }

const cfg = JSON.parse(fs.readFileSync(process.env.HOME + '/.secrets/bigin-oauth.json', 'utf8'));
const API = (cfg.api_domain || 'https://www.zohoapis.com').replace(/^https?:\/\//, '');
const ACC = (cfg.accounts_domain || 'https://accounts.zoho.com').replace(/^https?:\/\//, '');
const SCHEME = 'Zoho-oauth' + 'token ';
const post = (host, p, body) => new Promise((res, rej) => { const data = new URLSearchParams(body).toString(); const r = https.request({ host, path: p, method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': Buffer.byteLength(data) } }, x => { let b = ''; x.on('data', d => b += d); x.on('end', () => res(b)); }); r.on('error', rej); r.write(data); r.end(); });
const get = (host, p, tok) => new Promise((res, rej) => { const r = https.request({ host, path: p, method: 'GET', headers: { Authorization: SCHEME + tok } }, x => { let b = ''; x.on('data', d => b += d); x.on('end', () => res({ s: x.statusCode, b })); }); r.on('error', rej); r.end(); });

const money = n => '$' + Math.round(Number(n || 0)).toLocaleString('en-US');
const slug = s => String(s || '').toLowerCase().replace(/[^a-z0-9]/g, '').slice(0, 40);

// newest AR xlsx (same picker the monitor uses)
function latestAr() {
  const xls = fs.readdirSync(AR_DIR).filter(f => /^AR[ -]Aging.*\.xlsx$/i.test(f))
    .map(f => ({ f, t: fs.statSync(path.join(AR_DIR, f)).mtimeMs })).sort((a, b) => b.t - a.t);
  if (!xls.length) { console.error('No AR Aging xlsx in ' + AR_DIR); process.exit(1); }
  return path.join(AR_DIR, xls[0].f);
}

function readArFeed() {
  const file = latestAr();
  const out = cp.execFileSync('node', [MONITOR, '--file=' + file, '--json', '--allow-stale'], { encoding: 'utf8', maxBuffer: 1e8 });
  return { file: path.basename(file), feed: JSON.parse(out) };
}

// build the collections card payload for one behind account
function cardFor(a) {
  const tags = ['Collections']; if (a.d90 > 0) tags.push('90+ Days');
  const props = (a.properties || []);
  const noteLines = props.slice(0, 12).map(p => '  • ' + p.prop + ' — ' + money(p.bal) + ' — ' + p.aging + ' days');
  if (props.length > 12) noteLines.push('  • + ' + (props.length - 12) + ' more');
  return {
    Deal_Name: (a.account + ' [AR:' + slug(a.account) + ']').slice(0, 120),
    Sub_Pipeline: rep.aspen_feed_sub, Stage: STAGE, Amount: Math.round(a.behind),
    Owner: { id: rep.bigin_owner_id }, Tag: tags,
    Description: 'AR ' + a.oldest + ' past due (data as of report ' + '{REPORT}' + ').\n' +
      'Total behind: ' + money(a.behind) + (a.d90 > 0 ? '  ***90+ ESCALATE (Jason+Nate)***' : '') + '\nProperties behind:\n' + noteLines.join('\n'),
    _key: slug(a.account), _account: a.account, _behind: Math.round(a.behind), _esc: a.d90 > 0, _props: props.length
  };
}

(async () => {
  const rt = JSON.parse(await post(ACC, '/oauth/v2/token', { refresh_token: cfg.refresh_token, client_id: cfg.client_id, client_secret: cfg.client_secret, grant_type: 'refresh_token' }));
  const tok = rt.access_token;
  if (!tok) { console.error('Bigin token refresh failed: ' + JSON.stringify(rt).slice(0, 200)); process.exit(1); }

  const { file, feed } = readArFeed();
  const accts = (feed.byRep[REP_NAME] || []);
  const cards = accts.map(cardFor).map(c => (c.Description = c.Description.replace('{REPORT}', feed.wk || feed.reportISO || '?'), c));

  console.log('\n=== COLLECTIONS DRY-RUN: ' + rep.name + ' -> ' + rep.bigin_pipeline + ' / ' + rep.aspen_feed_sub + ' @ ' + STAGE + ' ===');
  console.log('AR source: ' + file + '  (Dimitry email feed, data as of ' + (feed.wk || feed.reportISO) + ', ' + feed.ageDays + 'd old)');
  console.log('Behind accounts for ' + rep.name + ': ' + accts.length + '  |  total behind ' + money(accts.reduce((s, a) => s + a.behind, 0)));

  // existing deals in the rep's pipeline (paginate), keep the Collections cards (by [AR:] tag)
  const wantFields = ['Deal_Name', 'Stage', 'Pipeline', 'Sub_Pipeline', 'Amount'];
  let existing = [], page = 1, more = true, guard = 0;
  while (more && guard < 20) {
    guard++;
    const d = await get(API, '/bigin/v2/Pipelines?fields=' + wantFields.join(',') + '&per_page=200&page=' + page, tok);
    if (d.s !== 200) { if (page === 1) console.log('(note: Bigin read returned HTTP ' + d.s + ' — ' + String(d.b).slice(0, 120) + ')'); break; }
    const j = JSON.parse(d.b);
    for (const r of (j.data || [])) if (r.Pipeline && r.Pipeline.name === rep.bigin_pipeline) existing.push(r);
    more = j.info && j.info.more_records; page++;
  }
  const existingAR = {};
  existing.forEach(e => { const m = (e.Deal_Name || '').match(/\[AR:([a-z0-9]+)\]/); if (m) existingAR[m[1]] = e; });
  console.log('Existing deals in ' + rep.bigin_pipeline + ': ' + existing.length + '  |  existing Collections (AR) cards: ' + Object.keys(existingAR).length);

  // plan
  const plan = { create: [], update: [], skip: [], clear: [] };
  const liveKeys = new Set(cards.map(c => c._key));
  for (const c of cards) {
    const ex = existingAR[c._key];
    if (!ex) plan.create.push(c);
    else if (Math.round(Number(ex.Amount || 0)) !== c._behind) plan.update.push({ from: Math.round(Number(ex.Amount || 0)), to: c._behind, card: c });
    else plan.skip.push(c);
  }
  // auto-clear: existing AR cards whose account is no longer behind (dropped off the report = paid)
  for (const [k, e] of Object.entries(existingAR)) if (!liveKeys.has(k)) plan.clear.push({ key: k, name: e.Deal_Name, amount: Math.round(Number(e.Amount || 0)) });

  const esc = cards.filter(c => c._esc);
  console.log('\nWOULD CREATE: ' + plan.create.length + '  |  UPDATE amount: ' + plan.update.length + '  |  SKIP: ' + plan.skip.length + '  |  AUTO-CLEAR (paid): ' + plan.clear.length);
  console.log('New-card collections value: ' + money(plan.create.reduce((s, c) => s + c._behind, 0)));
  console.log('90+ ESCALATIONS -> Jason+Nate: ' + esc.length + (esc.length ? '  [' + esc.map(c => c._account + ' ' + money(c._behind)).join(' · ') + ']' : ''));

  console.log('\n--- would-create cards (by value) ---');
  plan.create.sort((a, b) => b._behind - a._behind).forEach(c =>
    console.log('  ' + money(c._behind).padStart(10) + '  ' + c._account + '  {' + c.Tag.join(',') + '}  (' + c._props + ' props)'));
  if (plan.update.length) { console.log('\n--- would-update (amount changed) ---'); plan.update.forEach(u => console.log('  ' + money(u.from) + ' -> ' + money(u.to) + '  ' + u.card._account)); }
  if (plan.clear.length) { console.log('\n--- would auto-clear (off newest report = paid) ---'); plan.clear.forEach(c => console.log('  ' + money(c.amount) + '  ' + c.name)); }

  console.log('\n*** DRY-RUN ONLY — nothing was written to Bigin. ***');
  const outp = path.join(DIR, 'collections-dry-run-' + slug(REP_NAME) + '.json');
  fs.writeFileSync(outp, JSON.stringify({ rep: rep.name, source: file, reportDate: feed.reportISO, generated: new Date().toISOString(), counts: { create: plan.create.length, update: plan.update.length, skip: plan.skip.length, clear: plan.clear.length, escalations: esc.length }, plan }, null, 2));
  console.log('Full plan written: ' + outp);
})().catch(e => { console.error('ERR', e.message); process.exit(1); });
