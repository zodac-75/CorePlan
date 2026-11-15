#!/usr/bin/env python3
"""Turn the ChatGPT-made egg pictures (PNG with transparency) into the TGAs in core/Media.

  python3 tools/importmedia.py <folder with the PNGs>

Each picture is cropped to what is drawn, scaled to fit its canvas (same sizes as before, so the
code that places them does not change) and written as a 32-bit TGA. Missing files are skipped, so
you can run it with a folder holding just the pictures you changed.
"""
import os, sys
from PIL import Image

# source file -> (target name, canvas width, canvas height)
MAP = {
    "discokula": ("Disco", 256, 256), "fiol": ("Violin", 256, 256), "fisk": ("Fish", 256, 256),
    "fodelsedagstarta": ("Cake", 256, 256), "hjarta": ("Heart", 256, 256), "krona": ("Crown", 256, 256),
    "ledset_moln": ("Cloud", 256, 160), "not": ("Note", 256, 256), "ol": ("Mug", 256, 256),
    "paskagg": ("Egg", 256, 256), "pumpa": ("Pumpkin", 256, 256), "regnbage": ("Rainbow", 256, 256),
    "stjarna": ("Star", 128, 128), "orkide": ("Flower", 256, 256), "tag": ("Train", 512, 160),
}
PAD = 0.03  # empty margin around the drawing, as a share of the canvas

def convert(src, name, w, h, out):
    im = Image.open(src).convert("RGBA")
    box = im.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    im = im.crop(box)
    s = min(w * (1 - 2 * PAD) / im.width, h * (1 - 2 * PAD) / im.height)
    size = (max(1, round(im.width * s)), max(1, round(im.height * s)))
    # scale with premultiplied alpha so the edges get no dark fringe
    im = im.convert("RGBa").resize(size, Image.LANCZOS).convert("RGBA")
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    canvas.paste(im, ((w - size[0]) // 2, (h - size[1]) // 2))
    canvas.save(os.path.join(out, name + ".tga"))

if __name__ == "__main__":
    src = sys.argv[1]
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "core", "Media")
    for f, (name, w, h) in MAP.items():
        if not os.path.exists(os.path.join(src, f + ".png")):
            continue
        convert(os.path.join(src, f + ".png"), name, w, h, out)
        print("wrote", name, w, h)
