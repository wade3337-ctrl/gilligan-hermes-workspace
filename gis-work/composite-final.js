const fs=require('fs'), sharp=require('sharp');
(async()=>{
const src='rendered/cam-p01.png';
const b=fs.readFileSync(src); const W=b.readUInt32BE(16), H=b.readUInt32BE(20);
const L=Math.round(0.211*W),T=Math.round(0.003*H),R=Math.round(0.998*W),Bt=Math.round(0.996*H);
const m=await sharp('sat.png').metadata(); const OW=m.width, OH=m.height;
const frame=await sharp(src).extract({left:L,top:T,width:R-L,height:Bt-T}).resize(OW,OH,{fit:'fill'}).toBuffer();

// lift crushed shadows: brighten sat + 30% white wash, THEN multiply the map
const satBright=await sharp('sat.png').modulate({brightness:1.5}).toBuffer();
const white=await sharp({create:{width:OW,height:OH,channels:4,background:{r:255,g:255,b:255,alpha:0.30}}}).png().toBuffer();
const satLifted=await sharp(satBright).composite([{input:white,blend:'over'}]).toBuffer();
await sharp(satLifted).composite([{input:frame, blend:'multiply'}]).png()
  .toFile('deliverables/BlueJay-Falcon-SAT-overlay.png');
console.log('final composite written', OW+'x'+OH);
// cleanup the A/B trials
for(const f of ['sat-overlay-A-multiply.png','sat-overlay-B-50pct.png']) try{fs.unlinkSync('deliverables/'+f)}catch(e){}
})().catch(e=>{console.error('ERR',e.message);process.exit(1)});
