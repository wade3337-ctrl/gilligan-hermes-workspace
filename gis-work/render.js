const { pdfToPng } = require('pdf-to-png-converter');
const path = require('path');
const SRC = '/home/wade3337/arbor-stack/inbox-pull/brent-bluejay-falcon-2026-07-30';
(async () => {
  const jobs = [
    ['C04e_4 Blue Jay-Falcon CAM.pdf', 'cam'],
    ['C04c_2. Blue Jay-Falcon Appendix A.pdf', 'appA'],
  ];
  for (const [file, tag] of jobs) {
    const pages = await pdfToPng(path.join(SRC, file), {
      viewportScale: 3.0,          // high-res
      outputFolder: '/home/wade3337/.openclaw/workspace/gis-work/rendered',
      outputFileMaskFunc: (p) => `${tag}-p${String(p).padStart(2,'0')}.png`,
    });
    console.log(`${tag}: ${pages.length} page(s) rendered`);
  }
})().catch(e => { console.error('ERR', e.message); process.exit(1); });
