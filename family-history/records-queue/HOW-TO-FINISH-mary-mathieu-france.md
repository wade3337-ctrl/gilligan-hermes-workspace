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

Harnesses already built: `ad08.js`, `ad08-search.js`, `ad08-drive2.js`, `ad08-fiche.js` (in family-history/).
