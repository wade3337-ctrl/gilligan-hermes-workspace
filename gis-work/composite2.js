const fs=require('fs'), sharp=require('sharp');
(async()=>{
const src='rendered/cam-p01.png';
const b=fs.readFileSync(src); const W=b.readUInt32BE(16), H=b.readUInt32BE(20);
const L=Math.round(0.211*W),T=Math.round(0.003*H),R=Math.round(0.998*W),Bt=Math.round(0.996*H);
const cw=R-L, ch=Bt-T;
const meta=await sharp('sat.png').metadata(); const OW=meta.width, OH=meta.height;

// map frame cropped + resized to satellite size
const frame=await sharp(src).extract({left:L,top:T,width:cw,height:ch}).resize(OW,OH,{fit:'fill'}).toBuffer();

// build alpha from luminance: white bg -> transparent, dark ink/color -> opaque
// grayscale -> negate (white=0, black=255) -> linear curve to drop faint tones, keep lines
const alpha=await sharp(frame).grayscale().negate().linear(1.7,-55).toColourspace('b-w').toBuffer();
const ink=await sharp(frame).ensureAlpha().joinChannel(alpha).png().toBuffer();

// brighten satellite base so lines read, then lay ink over it
const satBright=await sharp('sat.png').modulate({brightness:1.30}).toBuffer();
await sharp(satBright).composite([{input:ink, blend:'over'}]).png()
  .toFile('deliverables/BlueJay-Falcon-SAT-overlay.png');
console.log('improved composite written', OW+'x'+OH);
})().catch(e=>{console.error('ERR',e.message);process.exit(1)});
