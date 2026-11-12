"""Makes allclass/Media/Logo.tga (512x512, badge at the top, h = 408/512) and Icon.tga (64x64)
from AllClassPlan-original.png: the dark background outside the badge becomes transparent.

    python3 allclass/art/make_logo.py
"""
from PIL import Image, ImageFilter
from collections import deque
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
im = Image.open(os.path.join(HERE, 'AllClassPlan-original.png')).convert('RGBA')
W, H = im.size
px = im.load()
CX, CY, RX, RY = 408, 282, 318, 250
def bg(p, x, y):
    if ((x - CX) / RX) ** 2 + ((y - CY) / RY) ** 2 < 1: return False
    r, g, b, a = p
    return max(r, g, b) < 60
mask = Image.new('L', (W, H), 255)
m = mask.load()
seen = bytearray(W * H)
q = deque()
for x in range(W):
    for y in (0, H - 1): q.append((x, y))
for y in range(H):
    for x in (0, W - 1): q.append((x, y))
while q:
    x, y = q.popleft()
    i = y * W + x
    if seen[i]: continue
    seen[i] = 1
    if not bg(px[x, y], x, y): continue
    m[x, y] = 0
    for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
        nx, ny = x + dx, y + dy
        if 0 <= nx < W and 0 <= ny < H and not seen[ny * W + nx]: q.append((nx, ny))
mask = mask.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.2))
im.putalpha(mask)
box = mask.point(lambda v: 255 if v > 20 else 0).getbbox()
im = im.crop(box)
print('crop', box, im.size)
w = 512; h = round(im.size[1] * w / im.size[0])
logo = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
logo.alpha_composite(im.resize((w, h), Image.LANCZOS), (0, 0))
logo.save(os.path.join(HERE, '..', 'Media', 'Logo.tga'))
sq = Image.new('RGBA', (512, 512), (0, 0, 0, 0)); sq.alpha_composite(logo.crop((0, 0, 512, h)), (0, (512 - h) // 2))
sq.resize((64, 64), Image.LANCZOS).save(os.path.join(HERE, '..', 'Media', 'Icon.tga'))
print('h', h)
