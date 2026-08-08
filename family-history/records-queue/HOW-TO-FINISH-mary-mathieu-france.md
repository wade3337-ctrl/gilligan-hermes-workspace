# How to finish: Mary Mathieu's parents (Sedan, France, b. 1866)

**Goal:** prove the parents of Mary Mathieu (Adeline Eischen's mother), b. ~3 Jan 1866, Sedan, Ardennes.
**Status:** French ORIGIN = Confirmed (1900/1910 census). Parents = **Possible** candidate only:
**Georges Mathieu × Marie Élisabeth Constance Munaux** of Sedan (indexed kids 1862, 1865, 1867; 1866 gap).

## What I mapped (the exact AD08 path — it works)
- Source: **Archives départementales des Ardennes → archives.cd08.fr** (free; real scans; not FamilySearch, which is index-only and shows "no images" for film 008613492).
- Page: *Archives numérisées → Sources généalogiques → Registres paroissiaux et d'état civil*.
- Form has a **`commune` text box** (autocomplete) + **decade facet buttons** incl. **`1863-1872`**.
- Results table lists, in order: Protestant parish registers → then **civil-registration (état civil) registers + their tables (annuelle/décennale)**.
- Clicking a register opens the **Arkothèque image viewer** (verified: renders real scans, page-nav `n / total`, cote like `2E…` or `EDEPOT/…`).

## The two records to open (in that viewer)
1. **Table décennale des naissances, Sedan, 1863–1872** — one alphabetical list of every birth that decade. Find "Mathieu, Marie" → it gives the **exact 1866 birth date + act number** to jump to.
2. **Registre des naissances, Sedan, 1866** — open to that act #. The birth act **names both parents** (father's name/age/occupation, mother's maiden name) → proves or refutes the Georges Mathieu × Munaux candidate, and gives grandparents.

## Why I stopped (honest)
- The results table loads for Sedan, but the "view register" control + the specific 1863–72 décennale/1866 rows sit deep in a fragile JS table; my link-extraction returned 0 view-links on this run.
- Even once open, it's **handwritten 1860s French cursive to transcribe** — a task a human (or a French-records volunteer) does faster/more reliably than my headless OCR.

## Fastest finish options
- **You/a helper, ~10 min in a browser:** go to the page above, type "Sedan", open the **1863–1872 naissances décennale**, Ctrl-find "Mathieu". Screenshot the entry + the 1866 act → send to me and I'll transcribe/verify + slot it in.
- **Or** I take one more targeted swing to grab the exact "view register" link for the Sedan 1863–72 décennale (no promise it renders cleanly).
- **Or** a paid assist (Geneanet/pro lookup) — not needed if the above works.

Harnesses already built: `ad08.js`, `ad08-search.js`, `ad08-drive2.js`, `ad08-fiche.js`, `ad08-rows.js`, `ad08-decade.js`, `ad08-paginate.js`, `ad08-pag2.js`, `ad08-all.js` (in family-history/).

## Option-2 swing (2026-08-07 late) — CRACKED the filter, BLOCKED on the scan read
- ✅ **Headless AD08 commune filter now WORKS** (`ad08-commune.js`): fill `#commune`, type name, **ArrowDown+Enter to select the autocomplete**, then Rechercher. Bazeilles → 35 registers listed clean. Can now enumerate ANY village's registers headless.
- ✅ Every Sedan-suburb village has a small **~22-image Table décennale 1863-1872** (e.g. Bazeilles = cote **2E/SEDAN 14**, contenuId **968219**, 22 imgs).
- ✅ AD08 image server is IIIF-style: **`/image/2516/<id>`** (Bazeilles décennale img seen = **129909**).
- ❌ **Can't READ the scan headless yet:** the arko image viewer opens (network shows `/image/2516/129909`) but a full-page screenshot captures the PORTAL, not the lightbox overlay; **direct `curl /image/2516/<id>?...` returns HTML** (needs the arko session cookie + signed params, not yet reverse-engineered); **fiche-redirect with contenuId 968219 = "Page introuvable"** (redirect wants an annotation fiche id, not a contenuId).
- **Next-time ideas:** (a) capture the lightbox by screenshotting the popup/iframe or waiting for the arko viewer canvas; (b) sniff the FULL signed IIIF URL (with its `r=`/token param) from the viewer network and replay it; (c) just use the PHONE (proven works) to open a village décennale like we did for Sedan.
- **Villages to check (closest to Sedan first):** Bazeilles, Balan, Floing, Glaire, Wadelincourt, Givonne, La Moncelle, Daigny, Donchery. Target: a **Mathieu born ~3 Jan 1866**.

## Automation state (2026-08-07, after 5+ swings) — the exact blocker
- **AD08 uses a IIIF image server:** `/image/2516/<imageId>?size=!800,800&region=full&format=pdf` (proven on the mode-d'emploi PDF). If we get the décennale's image IDs, we can pull scans directly — no viewer needed.
- **Register rows open the Arkothèque viewer** via a `<button data-rebond="arko_default_67764c880046a" data-term="<daterange>[[hash]]">` (AJAX facet/open). The viewer then serves pages via the IIIF endpoint.
- **THE WALL:** for commune=Sedan, the headless driver only ever loads **24 rows — all *parish/protestant* registers (2E409, 1 Mi microfilms, 1573–1793)**. The **état-civil (civil, 1792+) section — which holds the 1863–1872 naissances *table décennale* and the 1866 birth register — never renders.** The site lists parish first, then civil; the civil rows are on later result pages.
- **Pager = ** buttons `"2"`, `"3"`, and `bouton_pagination` **"Derniers résultats"** (jump to last), plus `"1"` = `reset-filtre`. **My clicks on 2/3/last did NOT advance the result set** (same 24 rows after every click; tried getByRole, JS `.click()`, force-click, ArrowDown+Enter). Likely the pager fires an AJAX call that needs a token/handler my headless click doesn't trigger.
- **Next automation idea (if retried):** capture the XHR the pager fires (network sniff) and replay it directly, OR click "Derniers résultats" and detect the état-civil block, OR drive with a full (non-headless-shell) Chromium + real user gestures. Untested.
- **Recommendation stands:** a human in a normal browser reaches the Sedan 1863–72 naissances décennale in ~10 min (the pager works with a real click) → Ctrl-find "Mathieu" → screenshot → I transcribe/verify.

## ⏸️ RESUME POINTER (paused 2026-08-07 ~23:45 UTC)
Jason was live on his PHONE at **archives.moselle.fr / archives57.com** (passed the Anubis anti-bot). Path reached:
Menu ☰ → **To research** → **Online archives** → **Parish and civil registration records** → the green link **"Click here to access digitized parish and civil registration records"** (civil records online **1793–1904**, so 1866 IS covered; digitized w/ FamilySearch).
**NEXT TAP:** that green "Click here…" link → search form → **commune = Marspich** (fallback Hayange) → **Naissances (Births)** → **1866** → find **Mathieu, Marie** → read **"fille de [FATHER] et de [MOTHER]"** = her parents. (Backup: "Ten-year civil status indexes" = table décennale 1863–1872, alphabetical → M.)
