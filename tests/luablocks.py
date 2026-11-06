import re, sys
def tokens(src):
    i, n, line = 0, len(src), 1
    while i < n:
        c = src[i]
        if c == '\n': line += 1; i += 1; continue
        if src.startswith('--[[', i) or src.startswith('--[==[', i):
            close = ']]' if src.startswith('--[[', i) else ']==]'
            j = src.find(close, i); line += src.count('\n', i, j); i = j + len(close); continue
        if src.startswith('--', i):
            j = src.find('\n', i); i = n if j < 0 else j; continue
        if src.startswith('[[', i):
            j = src.find(']]', i); line += src.count('\n', i, j); i = j + 2; yield ('str', line); continue
        if c in '"\'':
            j = i + 1
            while src[j] != c:
                if src[j] == '\\': j += 1
                if src[j] == '\n': raise SyntaxError(f'line {line}: unterminated string')
                j += 1
            i = j + 1; yield ('str', line); continue
        m = re.match(r'[A-Za-z_][A-Za-z0-9_]*', src[i:])
        if m:
            yield (m.group(0), line); i += len(m.group(0)); continue
        yield (c, line); i += 1
def check(path):
    src = open(path, encoding='utf-8').read()
    stack = []; prev = None
    pairs = {'(': ')', '{': '}', '[': ']'}
    for tok, line in tokens(src):
        if tok in ('function', 'if', 'do', 'repeat'):
            # 'do' after for/while belongs to that loop
            if tok == 'do' and stack and stack[-1][0] in ('for', 'while') and not stack[-1][2]:
                stack[-1] = (stack[-1][0], stack[-1][1], True)
            else:
                stack.append((tok, line, True))
        elif tok in ('for', 'while'):
            stack.append((tok, line, False))
        elif tok in pairs:
            stack.append((tok, line, True))
        elif tok in (')', '}', ']'):
            if not stack or pairs.get(stack[-1][0]) != tok:
                return f'{path}:{line}: unexpected {tok} (open: {stack[-1] if stack else None})'
            stack.pop()
        elif tok == 'end':
            if not stack or stack[-1][0] not in ('function', 'if', 'do', 'for', 'while'):
                return f'{path}:{line}: unexpected end (open: {stack[-1] if stack else None})'
            stack.pop()
        elif tok == 'until':
            if not stack or stack[-1][0] != 'repeat':
                return f'{path}:{line}: unexpected until'
            stack.pop()
    if stack: return f'{path}: unclosed {stack[-1]}'
    return None
bad = 0
for p in sys.argv[1:]:
    try: r = check(p)
    except SyntaxError as e: r = f'{p}: {e}'
    print('OK  ' + p if r is None else 'FAIL ' + r); bad += r is not None
sys.exit(1 if bad else 0)
