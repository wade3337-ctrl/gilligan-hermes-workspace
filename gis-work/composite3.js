const fs=require('fs'), sharp=require('sharp');
(async()=>{
const src='rendered/cam-p01.png';
const b=fs.readFileSync(src); const W=b.readUInt32BE(16), H=b.readUInt32BE(20);
const L=Math.round(0.211*W),T=Math.round(0.003*H),R=Math.round(0.998*W),Bt=Math.round(0.996*H);
const m=await sharp('sat.png').metadata(); const OW=m.width, OH=m.height;
const frame=await sharp(src).extract({left:L,top:T,width:R-L,height:Bt-T}).resize(OW,OH,{fit:'fill'}).toBuffer();

// A: brightened satellite, map MULTIPLIED on top (white->sat shows, lines darken)
const satA=await sharp('sat.png').modulate({brightness:1.6}).toBuffer();
await sharp(satA).composite([{input:frame, blend:'multiply'}]).png().toFile('deliverables/sat-overlay-A-multiply.png');

// B: brightened satellite + map at 50% opacity (semi-transparent veil)
const satB=await sharp('sat.png').modulate({brightness:1.25}).toBuffer();
const half=await sharp(frame).ensureAlpha(0.5).png().toBuffer();
await sharp(satB).composite([{input:half, blend:'over'}]).png().toFile('deliverables/sat-overlay-B-50pct.png');

console.log('wrote A (multiply) and B (50% veil), both', OW+'x'+OH);
})().catch(e=>{console.error('ERR',e.message);process.exit(1)});
