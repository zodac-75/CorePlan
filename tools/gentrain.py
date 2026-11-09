"""Writes classes/<class>/TrainData.lua (trainer ranks) and prints ns.spells for Data.lua.
python3 tools/gentrain.py <class> classes/<class>/TrainData.lua path/to/forge
(forge = https://github.com/brainw0rm/forge, the WoW Forever client data)."""
import json, re, sys
cls, out = sys.argv[1], sys.argv[2]
FORGE = sys.argv[3] if len(sys.argv) > 3 else 'forge'
d = json.load(open('%s/public/data/leveling/%s.json' % (FORGE, cls)))['abilities']
ranks, spells = {}, {}
for a in d:
    if a['passive']: continue
    m = re.match(r'Rank (\d+)', a['rank'] or '')
    r = int(m.group(1)) if m else None
    if r and not (a['level'] == 1 and r == 1):
        ranks.setdefault(a['name'], []).append((a['level'], r))
    if (r is None or r == 1) and a['level'] > 1 and 'talent' not in a:
        spells.setdefault(a['level'], []).append(a['name'])
L = ['-- @ADDON@: spell ranks taught by the class trainer, from the WoW Forever client data',
     '-- (build 1.60.1.70790). name = { {level, rank}, ... }', 'local _, ns = ...', '', 'ns.RANK_TABLE = {']
for n in sorted(ranks):
    L.append('  [%s] = { %s },' % (json.dumps(n), ', '.join('{%d,%d}' % x for x in sorted(ranks[n]))))
L.append('}')
open(out, 'w').write('\n'.join(L) + '\n')
print('ns.spells = {')
for lv in sorted(spells):
    print('  [%d] = { %s },' % (lv, ', '.join(json.dumps(s) for s in spells[lv])))
print('}')
print('RANKED', sorted(ranks))
