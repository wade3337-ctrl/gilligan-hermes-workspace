const PDFDocument=require('pdfkit'), fs=require('fs');
const D='/home/wade3337/.openclaw/workspace/gis-work/deliverables';

function imgPdf(png, out, title){
  const b=fs.readFileSync(png); const W=b.readUInt32BE(16), H=b.readUInt32BE(20);
  // fit image on a Letter-ish page at the image's aspect, margin for a title
  const maxW=720, maxH=930;            // points (~10x12.9in usable)
  const s=Math.min(maxW/W,(maxH-30)/H);
  const iw=W*s, ih=H*s;
  const doc=new PDFDocument({size:[iw+40, ih+70], margin:0});
  const stream=fs.createWriteStream(out); doc.pipe(stream);
  doc.fontSize(11).fillColor('#333').text(title, 20, 18, {width:iw});
  doc.image(png, 20, 50, {width:iw, height:ih});
  doc.end();
  return new Promise(r=>stream.on('finish',r));
}

(async()=>{
  await imgPdf(D+'/BlueJay-Falcon-ContractAreaMap.png', D+'/BlueJay-Falcon-ContractAreaMap.pdf',
    'Blue Jay / Falcon Contract Area Map — USFS Cleveland NF (map frame only)');
  await imgPdf(D+'/BlueJay-Falcon-CAM-fullsheet.png', D+'/BlueJay-Falcon-CAM-fullsheet.pdf',
    'Blue Jay / Falcon Contract Area Map — full sheet (title, legend, locator inset)');

  // README markdown -> simple text PDF
  const md=fs.readFileSync(D+'/README-georeferencing.md','utf8');
  const doc=new PDFDocument({size:'LETTER', margin:54});
  const st=fs.createWriteStream(D+'/BlueJay-Falcon-README.pdf'); doc.pipe(st);
  for(const line of md.split('\n')){
    if(line.startsWith('# ')) doc.moveDown(0.4).fontSize(15).fillColor('#000').text(line.slice(2)).moveDown(0.2);
    else if(line.startsWith('## ')) doc.moveDown(0.3).fontSize(12).fillColor('#1a3').text(line.slice(3)).moveDown(0.15);
    else if(line.startsWith('|')) doc.fontSize(8).fillColor('#333').font('Courier').text(line).font('Helvetica');
    else doc.fontSize(9.5).fillColor('#222').text(line||' ');
  }
  doc.end(); await new Promise(r=>st.on('finish',r));
  console.log('PDFs written.');
})().catch(e=>{console.error('ERR',e.message);process.exit(1)});
