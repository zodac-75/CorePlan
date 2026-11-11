"""Draws the easter-egg pictures that were made in code (flat style, like Mug.tga):
Violin, Crown, Fish, Cake, Pumpkin and Note. Writes 256x256 32-bit TGAs to core/Media.

    python3 tools/drawmedia.py
"""
import math
import os
from PIL import Image, ImageDraw

S = 4  # supersampling
N = 256 * S
OUT = os.path.join(os.path.dirname(__file__), "..", "core", "Media")


def canvas():
    im = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def P(*pts):
    return [(x * S, y * S) for x, y in pts]


def B(x0, y0, x1, y1):
    return [x0 * S, y0 * S, x1 * S, y1 * S]


def save(im, name, rotate=0):
    if rotate:
        im = im.rotate(rotate, resample=Image.BICUBIC)
    im = im.resize((256, 256), Image.LANCZOS)
    im.save(os.path.join(OUT, name + ".tga"))
    return im


def violin():
    im, d = canvas()
    dark, body, light = (92, 46, 18, 255), (201, 112, 44, 255), (232, 150, 70, 255)
    W = 6 * S
    # neck and scroll
    d.rounded_rectangle(B(119, 22, 137, 120), radius=6 * S, fill=(70, 40, 24, 255), outline=dark, width=W // 2)
    d.ellipse(B(113, 10, 143, 40), fill=(120, 66, 30, 255), outline=dark, width=W // 2)
    for y in (48, 62):  # pegs
        d.rounded_rectangle(B(104, y, 152, y + 7), radius=3 * S, fill=dark)
    # body: upper and lower bouts with a waist
    d.ellipse(B(84, 96, 172, 170), fill=body, outline=dark, width=W)
    d.ellipse(B(72, 150, 184, 246), fill=body, outline=dark, width=W)
    d.rectangle(B(96, 140, 160, 176), fill=body)
    d.ellipse(B(60, 136, 96, 178), fill=(0, 0, 0, 0))
    d.ellipse(B(160, 136, 196, 178), fill=(0, 0, 0, 0))
    d.arc(B(60, 136, 96, 178), -62, 62, fill=dark, width=W)
    d.arc(B(160, 136, 196, 178), 118, 242, fill=dark, width=W)
    d.ellipse(B(96, 108, 124, 136), fill=light)
    # f-holes, bridge, tailpiece, strings
    for x in (104, 148):
        d.rounded_rectangle(B(x, 158, x + 5, 196), radius=2 * S, fill=dark)
    d.rectangle(B(108, 186, 148, 191), fill=(245, 225, 190, 255))
    d.polygon(P((118, 204), (138, 204), (133, 236), (123, 236)), fill=(50, 30, 20, 255))
    for x in (122, 126, 130, 134):
        d.line(P((x, 40), (x, 206)), fill=(250, 244, 225, 255), width=S)
    return save(im, "Violin", rotate=-35)


def crown():
    im, d = canvas()
    dark, gold, light = (150, 96, 10, 255), (247, 190, 40, 255), (255, 226, 120, 255)
    W = 6 * S
    pts = P((34, 196), (26, 84), (78, 138), (128, 52), (178, 138), (230, 84), (222, 196))
    d.polygon(pts, fill=gold, outline=dark)
    d.line(pts + [pts[0]], fill=dark, width=W, joint="curve")
    d.rounded_rectangle(B(30, 186, 226, 222), radius=10 * S, fill=gold, outline=dark, width=W)
    d.rectangle(B(44, 194, 212, 200), fill=light)
    for x, y, c in ((26, 84, (226, 60, 70, 255)), (128, 52, (70, 150, 240, 255)), (230, 84, (226, 60, 70, 255))):
        d.ellipse(B(x - 15, y - 15, x + 15, y + 15), fill=c, outline=dark, width=W // 2)
    for x, c in ((78, (90, 200, 120, 255)), (128, (226, 60, 70, 255)), (178, (90, 200, 120, 255))):
        d.ellipse(B(x - 10, 195, x + 10, 215), fill=c, outline=dark, width=W // 2)
    return save(im, "Crown")


def fish():
    im, d = canvas()
    dark, blue, light, belly = (20, 70, 110, 255), (70, 160, 215, 255), (130, 205, 240, 255), (225, 240, 245, 255)
    W = 6 * S
    d.polygon(P((176, 128), (246, 70), (232, 128), (246, 186)), fill=blue, outline=dark)
    d.line(P((176, 128), (246, 70), (232, 128), (246, 186), (176, 128)), fill=dark, width=W, joint="curve")
    d.polygon(P((98, 78), (150, 44), (160, 84)), fill=blue, outline=dark)
    d.line(P((98, 78), (150, 44), (160, 84)), fill=dark, width=W, joint="curve")
    d.ellipse(B(14, 68, 200, 188), fill=blue, outline=dark, width=W)
    d.chord(B(22, 84, 192, 182), 20, 160, fill=belly)
    d.arc(B(14, 68, 200, 188), 0, 360, fill=dark, width=W)
    d.arc(B(60, 80, 110, 176), -60, 60, fill=dark, width=W // 2)  # gill
    d.polygon(P((112, 132), (150, 150), (118, 160)), fill=light, outline=dark)
    d.ellipse(B(40, 98, 68, 126), fill=(255, 255, 255, 255), outline=dark, width=W // 2)
    d.ellipse(B(47, 106, 59, 118), fill=(20, 20, 30, 255))
    d.arc(B(22, 126, 60, 156), 20, 110, fill=dark, width=W // 2)  # mouth
    return save(im, "Fish")


def cake():
    im, d = canvas()
    dark, sponge, pink, cream = (110, 60, 40, 255), (232, 178, 110, 255), (245, 130, 170, 255), (255, 246, 232, 255)
    W = 6 * S
    d.rounded_rectangle(B(28, 214, 228, 236), radius=10 * S, fill=(230, 232, 240, 255), outline=(120, 124, 140, 255), width=W // 2)
    d.rounded_rectangle(B(44, 120, 212, 220), radius=14 * S, fill=sponge, outline=dark, width=W)
    d.rectangle(B(50, 164, 206, 176), fill=pink)
    # frosting with drips
    d.rounded_rectangle(B(44, 110, 212, 150), radius=16 * S, fill=cream, outline=dark, width=W)
    for x, h in ((62, 22), (98, 34), (134, 20), (170, 30)):
        d.rounded_rectangle(B(x, 136, x + 24, 150 + h), radius=11 * S, fill=cream, outline=dark, width=W)
        d.rectangle(B(x + 6, 132, x + 18, 150 + h - 12), fill=cream)
    d.rectangle(B(50, 122, 206, 142), fill=cream)
    # candles and flames
    for x, c in ((76, (90, 170, 240, 255)), (122, (245, 130, 170, 255)), (168, (120, 205, 130, 255))):
        d.rounded_rectangle(B(x, 68, x + 14, 116), radius=4 * S, fill=c, outline=dark, width=W // 2)
        d.ellipse(B(x - 3, 36, x + 17, 70), fill=(255, 170, 40, 255), outline=(190, 90, 10, 255), width=W // 2)
        d.ellipse(B(x + 3, 50, x + 11, 66), fill=(255, 240, 150, 255))
    return save(im, "Cake")


def pumpkin():
    im, d = canvas()
    dark, orange, light = (140, 62, 8, 255), (240, 132, 30, 255), (252, 170, 70, 255)
    W = 6 * S
    d.rounded_rectangle(B(116, 30, 140, 76), radius=8 * S, fill=(96, 140, 60, 255), outline=(50, 80, 30, 255), width=W)
    for x0, x1 in ((20, 120), (136, 236), (52, 152), (104, 204), (78, 178)):
        d.ellipse(B(x0, 62, x1, 232), fill=orange, outline=dark, width=W)
    d.ellipse(B(96, 76, 124, 150), fill=light)
    face = (60, 26, 4, 255)
    d.polygon(P((70, 118), (104, 128), (78, 150)), fill=face)
    d.polygon(P((186, 118), (152, 128), (178, 150)), fill=face)
    d.polygon(P((128, 140), (140, 160), (116, 160)), fill=face)
    d.polygon(P((64, 172), (86, 182), (100, 172), (114, 186), (128, 174), (142, 186), (156, 172), (170, 182), (192, 172),
                (172, 208), (156, 198), (142, 212), (128, 200), (114, 212), (100, 198), (84, 208)), fill=face)
    return save(im, "Pumpkin")


def note():
    im, d = canvas()
    dark, white = (40, 40, 60, 255), (255, 255, 255, 255)
    W = 7 * S
    # two eighth notes joined by a beam; white so the game can tint it any color
    for x, y in ((40, 168), (150, 148)):
        d.ellipse(B(x, y, x + 70, y + 54), fill=white, outline=dark, width=W)
    for x, y0, y1 in ((96, 52, 196), (206, 32, 176)):
        d.rectangle(B(x, y0, x + 14, y1), fill=white, outline=dark, width=W // 2)
    d.polygon(P((96, 44), (220, 22), (220, 60), (96, 82)), fill=white, outline=dark)
    d.line(P((96, 44), (220, 22), (220, 60), (96, 82), (96, 44)), fill=dark, width=W // 2, joint="curve")
    return save(im, "Note")


if __name__ == "__main__":
    sheet = Image.new("RGB", (256 * 6, 256), (40, 40, 40))
    for i, fn in enumerate((violin, crown, fish, cake, pumpkin, note)):
        im = fn()
        sheet.paste(im, (256 * i, 0), im)
    preview = os.environ.get("PREVIEW")
    if preview:
        sheet.save(preview)
