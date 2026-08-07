# Wade–Ainsworth Family History — Master Tracker

**Subject:** Jason Roger Wade (b. Dec 21, 1973, Arcadia, CA)
**Source brief:** `00-source-handoff.md` (from J's wife, 2026-08-07)
**Run model:** Gilligan + crew (A Eischen · B Ainsworth · C Wade/Thompson · D Gaunt/Hanley/Ballew · E Verifier)

## Evidence tiers (enforced)
- **Confirmed** — family-confirmed OR original certificate/census image OR govt vital index
- **Strongly supported** — indexed record (FamilySearch/Ancestry), sourced FindAGrave, matching trees
- **Possible** — single tree / uncorroborated lead
- **Unverified** — oral history, AI speculation, surname inference

Rule for every parent-child link: *"What record directly links this child to these parents?"*
Never convert narrative into fact.

## Branch files
- `branches/A-eischen.md` — 🇫🇷 Adeline Mary Belinda Eischen (TOP priority)
- `branches/B-ainsworth.md` — 🌲 Norman Brocaw Ainsworth line
- `branches/C-wade-thompson.md` — 🏭 Wade / Thompson (paternal)
- `branches/D-gaunt-hanley-ballew.md` — 🌾 Gaunt / Hanley / Ballew (maternal)
- `records-queue/` — exact records to pull (paywalled/gated), per branch
- `conflicts.md` — Verifier E: contradictions, dupes, hallucination flags

## Priority stack (from brief)
1. Norman × Adeline marriage record
2. Adeline's birth / parents / birthplace + the French claim (documented)
3. Verify Norman's parents (Newton Elmer Ainsworth Sr. / Emma D. Sweet)
4. Donald Lee Ainsworth's childhood census household
5. Jack Wade death year (2006 vs 2008)

## Direct-line spine (family-confirmed unless noted)

| Person | Born | Died | Notes | Tier |
|---|---|---|---|---|
| Jason Roger Wade | 1973-12-21 Arcadia CA | — | subject | Confirmed |
| Jack Roger Wade (father) | 1940-05-29 Akron OH | 2006 **or** 2008 ⚠️ | LA Co. Public Works 39 yrs (obit lead) | Confirmed / death-yr Unverified |
| Antoinette Ainsworth (mother) | ? | living? | now Slowikowski | Confirmed |
| Thomas Samuel Wade (pat. gf) | ? | ? | wife Frances Della Thompson | Confirmed |
| Frances Della Thompson (pat. gm) | ? | ? | parents David M. Thompson / Sarah Ann Adkins? | Confirmed / parents Possible |
| **Donald Lee Ainsworth (mat. gf)** | 1931-08-14 Fresno CA | 1990-08-11 Placer Co. CA | "Diesel Don," diesel mechanic | Confirmed |
| Dorcie Dell Gaunt (mat. gm) | 1935-01-15 MO? | 1997 El Monte? | later Miller; m. Donald 1954-05-12 Yuma AZ | Confirmed / dates Possible |
| Norman Brocaw Ainsworth (mat. g-gf) | 1903-07-14 Stevens Point WI | 1976-05-25 Vista CA | parents Newton Elmer Sr. / Emma D. Sweet? | Strongly supported / parents Possible |
| Adeline Mary Belinda Eischen (mat. g-gm) | **1900-08-21 Park Ridge, Cook Co. IL** | **1990-11-25 San Diego CA** | parents Louis S. Eischen + **Mary Mathieu** (French line!) | Strongly supported |
| — Newton Elmer Ainsworth Sr (2xg-gf) | 1861 | 1930 | Norman's father [9XFG-DBV] | Strongly supported |
| — Emma Dean Sweet (2xg-gm) | 1861 | 1918 | Norman's mother [9XFG-DBK] | Strongly supported |
| — Louis S. Eischen (2xg-gf) | 1864 | 1929 | Adeline's father [GZDY-VYY] · Eischen=Luxembourg/German | Strongly supported |
| — Mary Mathieu (2xg-gm) | 1866 | 1946 | Adeline's mother [GZQM-82L] · **the French thread** | Strongly supported |
| Rhoda May Hanley (mat. g-gm) | 1915-03-18? | 1999-06-26? | later Gaunt, Heeb; par. John Ray Hanley / Bertha Ballew | Confirmed par. / dates Possible |

## Status log
- 2026-08-07 — Project opened; source retrieved from Spam; scaffold built.
- 2026-08-07 — FamilySearch login working (headless Chrome on jdog1; session saved to ~/.openclaw/.secrets/fs-state.json, reusable). Fetcher `fs-pull.js` built.
- 2026-08-07 — **Priority line cracked (first pass).** Walked Donald → Norman → Adeline. Answered priorities #1 (marriage: Cook Co. IL 1926), #2 (Adeline's parents/birthplace: Louis Eischen + Mary Mathieu, b. Park Ridge IL 1900), #4 (Norman's parents = Newton Elmer Ainsworth Sr + Emma Dean Sweet, record-backed), #5 (Donald's 1940 childhood census located). French question: Eischen=Luxembourg/German; **French likely via mother Mary Mathieu** → next target GZQM-82L. All Strongly supported (indexed records); image-verify pending. See branches/A,B + conflicts.md.
