#!/usr/bin/env python3
"""wiki-lint — health check for the atomic [[linked]] wiki. READ-ONLY.

Checks:
  1. BROKEN LINKS   — [[target]] with no matching note. Split into TYPOS (probable
                      mistakes) vs PLANNED (intentional forward-references, which
                      AGENTS.md explicitly allows as "worth writing later").
  2. ORPHANS        — notes nothing links to AND no MOC lists.
  3. MOC GAPS       — notes absent from every index/*.md map.
  4. FRONTMATTER    — missing/invalid required keys.
  5. STALE          — updated: older than STALE_DAYS, worst first; notes whose text
                      claims in-progress work are flagged HARDER (they mislead).

Deliberately NOT flagged:
  - links inside `code spans` or ``` fences ``` (illustrative, not real links)
  - wiki/README.md (it documents the format using example links)
  - point-in-time archives under wiki/_archive/ (immutable records, not atomic notes)
"""
import os, re, sys, datetime, collections

ROOT = os.path.dirname(os.path.abspath(__file__))
W = os.path.join(ROOT, 'wiki')
STALE_DAYS = 45
TODAY = datetime.date.today()

# Root-level workspace docs that are legitimate link targets.
ROOT_DOCS = {os.path.splitext(f)[0] for f in os.listdir(ROOT) if f.endswith('.md')}
VALID_TYPES = {'fact', 'project', 'reference', 'index'}
SKIP_FILES = {os.path.join(W, 'README.md')}
SKIP_DIRS = {'_archive'}
INPROGRESS = re.compile(r'\b(in progress|in-flight|pending|waiting on|TODO|next step|resume here)\b', re.I)

def strip_code(t):
    t = re.sub(r'```.*?```', ' ', t, flags=re.S)
    return re.sub(r'`[^`\n]*`', ' ', t)

def notes(include_archive=False):
    for r, d, f in os.walk(W):
        if not include_archive:
            d[:] = [x for x in d if x not in SKIP_DIRS]
        for n in sorted(f):
            if n.endswith('.md'):
                yield os.path.join(r, n)

def frontmatter(text):
    m = re.match(r'^---\n(.*?)\n---\n', text, re.S)
    if not m:
        return None
    fm = {}
    for line in m.group(1).split('\n'):
        mm = re.match(r'^([A-Za-z_]+):\s*(.*)$', line)
        if mm:
            fm[mm.group(1)] = mm.group(2).strip()
    return fm

def main():
    quiet = '--quiet' in sys.argv
    files = list(notes())                       # atomic notes: quality-checked
    stems = {os.path.splitext(os.path.basename(p))[0] for p in files}
    # Archived artifacts are NOT atomic notes (not quality-checked, not MOC-required)
    # but they ARE valid link targets — Obsidian resolves [[name]] by filename, not path.
    archived = {os.path.splitext(os.path.basename(p))[0] for p in notes(True)} - stems
    known = stems | archived | ROOT_DOCS

    links_out = collections.defaultdict(set)   # stem -> targets
    broken = collections.defaultdict(list)
    fm_problems, stale = [], []

    for p in files:
        raw = open(p, encoding='utf-8').read()
        stem = os.path.splitext(os.path.basename(p))[0]
        rel = os.path.relpath(p, ROOT)

        fm = frontmatter(raw)
        if fm is None:
            fm_problems.append((rel, 'no YAML frontmatter'))
        else:
            for key in ('title', 'type', 'domain', 'tags', 'links', 'updated'):
                if key not in fm or not fm[key]:
                    fm_problems.append((rel, f'missing `{key}`'))
            t = fm.get('type', '')
            if t and t not in VALID_TYPES:
                fm_problems.append((rel, f'invalid type `{t}` (want {"/".join(sorted(VALID_TYPES))})'))
            u = fm.get('updated', '')
            if u:
                try:
                    d = datetime.date.fromisoformat(u)
                    age = (TODAY - d).days
                    if age > STALE_DAYS:
                        stale.append((age, rel, bool(INPROGRESS.search(raw))))
                except ValueError:
                    fm_problems.append((rel, f'unparseable updated `{u}`'))

        if p in SKIP_FILES:
            continue
        for tgt in re.findall(r'\[\[([^\]|#]+)', strip_code(raw)):
            tgt = tgt.strip()
            links_out[stem].add(tgt)
            if tgt not in known:
                broken[tgt].append(rel)

    # inbound links + MOC membership
    inbound = collections.defaultdict(set)
    for src, tgts in links_out.items():
        for t in tgts:
            inbound[t].add(src)
    moc_listed = set()
    for p in files:
        if os.sep + 'index' + os.sep in p:
            for t in re.findall(r'\[\[([^\]|#]+)', strip_code(open(p, encoding='utf-8').read())):
                moc_listed.add(t.strip())

    # A "typo" looks like an existing note with different case, or has odd characters.
    lower = {s.lower(): s for s in known}
    typos, planned = {}, {}
    for t, refs in broken.items():
        if t.lower() in lower:
            typos[t] = (refs, f'case mismatch -> [[{lower[t.lower()]}]]')
        elif re.search(r'[,\s]', t):
            typos[t] = (refs, 'illegal char (space/comma) in link target')
        else:
            planned[t] = refs

    orphans, gaps = [], []
    for p in files:
        stem = os.path.splitext(os.path.basename(p))[0]
        if os.sep + 'index' + os.sep in p or p in SKIP_FILES:
            continue
        rel = os.path.relpath(p, ROOT)
        if stem not in moc_listed:
            gaps.append(rel)
            if not inbound.get(stem):
                orphans.append(rel)

    problems = bool(typos or fm_problems or orphans)
    if quiet and not problems and not stale:
        return 0

    W_ = lambda s='': print(s)
    W_(f'== wiki-lint {TODAY} — {len(files)} notes, {len(archived)} archived ==')
    W_()
    W_(f'1. BROKEN LINKS — {len(typos)} likely typo(s), {len(planned)} planned note(s)')
    for t, (refs, why) in sorted(typos.items()):
        W_(f'   ❌ [[{t}]] — {why}')
        for r in sorted(set(refs)):
            W_(f'        in {r}')
    if planned:
        W_(f'   ℹ️  planned (forward-references, allowed): ' + ', '.join(f'[[{t}]]' for t in sorted(planned)))
    W_()
    W_(f'2. ORPHANS (no inbound link AND no MOC) — {len(orphans)}')
    for r in orphans:
        W_(f'   🕳️  {r}')
    W_()
    W_(f'3. MOC GAPS (reachable, but on no map) — {len(gaps)}')
    for r in gaps:
        W_(f'   🗺️  {r}')
    W_()
    W_(f'4. FRONTMATTER DEFECTS — {len(fm_problems)}')
    for r, why in sorted(fm_problems):
        W_(f'   📋 {r}: {why}')
    W_()
    W_(f'5. STALE (> {STALE_DAYS}d) — {len(stale)}')
    for age, r, wip in sorted(stale, reverse=True):
        W_(f'   {"🔴" if wip else "🕰️ "} {age}d  {r}{"   ← claims work in progress" if wip else ""}')
    W_()
    W_('CLEAN ✅' if not problems else 'PROBLEMS FOUND — see above')
    return 1 if problems else 0

if __name__ == '__main__':
    sys.exit(main())
