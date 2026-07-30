const fs=require('fs'), path=require('path'), sharp=require('sharp'), AdmZip=require('adm-zip');
(async()=>{
const OUT='/home/wade3337/.openclaw/workspace/gis-work/deliverables';
fs.mkdirSync(OUT,{recursive:true});
const src='rendered/cam-p01.png';
const b=fs.readFileSync(src); const W=b.readUInt32BE(16), H=b.readUInt32BE(20);

// neatline frame fractions (from vision)
const fx0=0.211, fx1=0.998, fy0=0.003, fy1=0.996;
const cropL=Math.round(fx0*W), cropT=Math.round(fy0*H);
const cropW=Math.round((fx1-fx0)*W), cropH=Math.round((fy1-fy0)*H);

// crop to the map frame -> clean overlay image
const mapPng=path.join(OUT,'BlueJay-Falcon-ContractAreaMap.png');
await sharp(src).extract({left:cropL,top:cropT,width:cropW,height:cropH}).toFile(mapPng);
// also keep the full high-res sheet
fs.copyFileSync(src, path.join(OUT,'BlueJay-Falcon-CAM-fullsheet.png'));

// transform: scale from scale bar (reliable), anchor Blue Jay, north-up
const ftPerPx=1540/((0.488-0.226)*W);          // 2.474
const bjPx={x:0.44*W,y:0.448*H}, bj={lat:33.6517,lon:-117.4506};
const ftLat=364000, ftLon=364000*Math.cos(bj.lat*Math.PI/180);
const toll=(px,py)=>({lon: bj.lon+((px-bjPx.x)*ftPerPx)/ftLon, lat: bj.lat-((py-bjPx.y)*ftPerPx)/ftLat});

// neatline corners -> geographic box (north-up so rotation 0)
const tl=toll(cropL,cropT), br=toll(cropL+cropW,cropT+cropH);
const north=tl.lat, south=br.lat, west=tl.lon, east=br.lon;

// ---- KMZ (Google Earth ground overlay) ----
const kml=`<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
 <GroundOverlay>
  <name>Blue Jay / Falcon Contract Area Map (APPROX)</name>
  <description>USFS Cleveland NF post-fire fuels-reduction contract area. Size/scale from the map's own scale bar; ABSOLUTE POSITION IS APPROXIMATE - use the overlay handles to drag/align to Blue Jay &amp; Falcon campgrounds and Long Canyon Rd. North-up.</description>
  <color>b4ffffff</color>
  <Icon><href>BlueJay-Falcon-ContractAreaMap.png</href></Icon>
  <LatLonBox>
   <north>${north.toFixed(6)}</north>
   <south>${south.toFixed(6)}</south>
   <east>${east.toFixed(6)}</east>
   <west>${west.toFixed(6)}</west>
   <rotation>0</rotation>
  </LatLonBox>
 </GroundOverlay>
 <Placemark><name>Blue Jay Campground (control pt)</name><Point><coordinates>-117.4506,33.6517,0</coordinates></Point></Placemark>
 <Placemark><name>Falcon Group Campground (control pt)</name><Point><coordinates>-117.4508,33.6575,0</coordinates></Point></Placemark>
</kml>`;
const zip=new AdmZip();
zip.addFile('doc.kml', Buffer.from(kml,'utf8'));
zip.addLocalFile(mapPng);
zip.writeZip(path.join(OUT,'BlueJay-Falcon-overlay-APPROX.kmz'));

// ---- QGIS/ArcGIS world file (.pgw) for the cropped PNG, EPSG:4326 ----
// affine: A=deg/px x, E=-deg/px y, C/F = center of UL pixel
const degPxX=(east-west)/cropW, degPxY=(north-south)/cropH;
const pgw=[degPxX, 0, 0, -degPxY, west+degPxX/2, north-degPxY/2].map(n=>n.toExponential(10)).join('\n');
fs.writeFileSync(path.join(OUT,'BlueJay-Falcon-ContractAreaMap.pgw'), pgw+'\n');
fs.writeFileSync(path.join(OUT,'BlueJay-Falcon-ContractAreaMap.prj'),
 'GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]]');

console.log(`map frame crop: ${cropW}x${cropH} px`);
console.log(`ft/px (scale bar): ${ftPerPx.toFixed(3)}`);
console.log(`overlay box: N ${north.toFixed(5)} S ${south.toFixed(5)} E ${east.toFixed(5)} W ${west.toFixed(5)}`);
console.log(`box size: ${((east-west)*ftLon/5280).toFixed(2)} mi W-E x ${((north-south)*ftLat/5280).toFixed(2)} mi N-S`);
})().catch(e=>{console.error('ERR',e.message);process.exit(1)});
