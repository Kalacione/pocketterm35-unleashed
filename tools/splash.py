#!/usr/bin/env python3
"""Écran de démarrage Plymouth, tiré de la charte : couleurs de DESIGN.md,
obturateur de docs/design/icone-main, VT323. install.sh le lance à chaque fois,
donc un changement de charte suit tout seul.
  tools/splash.py <dossier>   écrit splash-0.png à splash-14.png (barre de 0 à 14 segments)"""
import re
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

TITLE = "POCKETTERM OS"
MENTION = "kalacione edition"  # "" pour ne rien afficher
W, H = 640, 480
SEGMENTS = 14

root = Path(__file__).resolve().parent.parent
colors = dict(re.findall(r'^  ([a-z-]+): "(#[0-9a-f]{6})"', (root / "DESIGN.md").read_text(), re.M))
P, BG, MUTED, LINE, BRIGHT = (colors[k] for k in ("primary", "background", "muted", "line", "bright"))
shutter = [l for l in (root / "docs/design/icone-main/D-obturateur.txt").read_text().split() if l]
font = str(root / "home/.local/share/fonts/VT323-Regular.ttf")


def spaced(d, cx, y, s, f, fill, gap):
    width = sum(d.textlength(c, font=f) for c in s) + gap * (len(s) - 1)
    x = cx - width / 2
    for c in s:
        d.text((x, y), c, font=f, fill=fill, anchor="lm")
        x += d.textlength(c, font=f) + gap


def frame(lit):
    fg = Image.new("RGBA", (W, H))
    d = ImageDraw.Draw(fg)
    k = 6
    x0, y0 = (W - len(shutter[0]) * k) // 2, 150
    for j, row in enumerate(shutter):
        for i, c in enumerate(row):
            if c == "#":
                d.rectangle([x0 + i * k, y0 + j * k, x0 + (i + 1) * k - 1, y0 + (j + 1) * k - 1], fill=P)
    spaced(d, W / 2, 285, TITLE, ImageFont.truetype(font, 36), BRIGHT, 6)
    d.rectangle([220, 320, 420, 326], outline=LINE)
    for i in range(lit):
        d.rectangle([222 + i * 14, 322, 231 + i * 14, 324], fill=P)
    if MENTION:
        d.text((W / 2, H - 40), MENTION, font=ImageFont.truetype(font, 22), fill=MUTED, anchor="mm")
    # halo puis scanlines, comme le rendu du menu
    img = Image.new("RGB", (W, H), BG)
    halo = fg.filter(ImageFilter.GaussianBlur(9)).getchannel("A").point(lambda a: a * 45 // 100)
    img.paste(Image.new("RGB", (W, H), P), mask=halo)
    img.paste(fg, mask=fg)
    px = img.load()
    for y in range(0, H, 3):
        for x in range(W):
            px[x, y] = tuple(v * 72 // 100 for v in px[x, y])
    return img


out = Path(sys.argv[1])
for n in range(SEGMENTS + 1):
    frame(n).save(out / f"splash-{n}.png", optimize=True)
