const fs=require('fs'), sharp=require('sharp');
(async()=>{
const src='rendered/cam-p01.png';
const b=fs.readFileSync(src); const W=b.readUInt32BE(16), H=b.readUInt32BE(20);
// centered north-up transform (scale from scale bar; translation best-fit to BOTH campgrounds)
const S=1540/((0.488-0.226)*W);                 // ft/px = 2.474
const ftLat=364000, ftLon=364000*Math.cos(33.655*Math.PI/180);
const kLon=S/ftLon, kLat=S/ftLat;
const bj={x:0.44*W,y:0.448*H,lat:33.6517,lon:-117.4506};
const fa={x:0.485*W,y:0.105*H,lat:33.6575,lon:-117.4508};
const Clon=((bj.lon-bj.x*kLon)+(fa.lon-fa.x*kLon))/2;
const Clat=((bj.lat+bj.y*kLat)+(fa.lat+fa.y*kLat))/2;
// neatline frame px
const L=0.211*W, T=0.003*H, R=0.998*W, B=0.996*H;
const west=Clon+L*kLon, east=Clon+R*kLon, north=Clat-T*kLat, south=Clat-B*kLat;
console.log(`bbox W ${west.toFixed(5)} E ${east.toFixed(5)} S ${south.toFixed(5)} N ${north.toFixed(5)}`);
const gw=(east-west)*ftLon, gh=(north-south)*ftLat;
const OW=1600, OH=Math.round(OW*gh/gw);
console.log(`ground ${gw.toFixed(0)}x${gh.toFixed(0)} ft -> image ${OW}x${OH}`);

// fetch Esri World Imagery for the exact bbox
const url=`https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/export`+
  `?bbox=${west},${south},${east},${north}&bboxSR=4326&imageSR=4326&size=${OW},${OH}&format=png&f=image`;
const r=await fetch(url); if(!r.ok) throw new Error('esri '+r.status);
const sat=Buffer.from(await r.arrayBuffer());
fs.writeFileSync('sat.png', sat);
console.log('satellite fetched:', sat.length, 'bytes');

// crop map to neatline, resize to sat, composite (multiply keeps sat visible through white)
const mapFrame=await sharp(src).extract({left:Math.round(L),top:Math.round(T),width:Math.round(R-L),height:Math.round(B-T)})
  .resize(OW,OH,{fit:'fill'}).toBuffer();
await sharp('sat.png').composite([{input:mapFrame, blend:'multiply'}]).png()
  .toFile('deliverables/BlueJay-Falcon-SAT-overlay.png');
console.log('composite written:', OW+'x'+OH);
})().catch(e=>{console.error('ERR',e.message);process.exit(1)});
