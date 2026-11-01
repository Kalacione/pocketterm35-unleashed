#!/usr/bin/env python3
"""Écran de démarrage Plymouth, tiré de la charte : couleurs de DESIGN.md,
obturateur de docs/design/icone-main, VT323, version de PT35_VERSION. install.sh le lance à chaque fois,
donc un changement de charte suit tout seul.
  tools/splash.py <dossier>   écrit splash-0.png à splash-14.png (barre de 0 à 14 segments)"""
import re
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

MENTION = "UNLEASHED"  # "" pour ne rien afficher
W, H = 640, 480
SEGMENTS = 14

root = Path(__file__).resolve().parent.parent
colors = dict(re.findall(r'^  ([a-z-]+): "(#[0-9a-f]{6})"', (root / "DESIGN.md").read_text(), re.M))
P, BG, MUTED, LINE, BRIGHT, ON_P = (colors[k] for k in ("primary", "background", "muted", "line", "bright", "on-primary"))
shutter = [l for l in (root / "docs/design/icone-main/D-obturateur.txt").read_text().split() if l]
font = str(root / "home/.local/share/fonts/VT323-Regular.ttf")
version = "v" + (root / "PT35_VERSION").read_text().strip()


def spaced(d, x, y, s, f, fill, gap, anchor="l"):
    width = sum(d.textlength(c, font=f) for c in s) + gap * (len(s) - 1)
    x -= {"l": 0, "m": width / 2, "r": width}[anchor]
    for c in s:
        d.text((x, y), c, font=f, fill=fill, anchor="lm")
        x += d.textlength(c, font=f) + gap


def frame(lit):
    fg = Image.new("RGBA", (W, H))
    d = ImageDraw.Draw(fg)
    vt = lambda size: ImageFont.truetype(font, size)
    # cadre et étiquette BOOT, comme les panneaux du menu
    d.rectangle([24, 24, W - 25, H - 25], outline=LINE, width=2)
    d.rectangle([24, 24, 134, 46], fill=P)
    spaced(d, 79, 35, "BOOT", vt(20), ON_P, 4, "m")
    k = 8
    for j, row in enumerate(shutter):
        for i, c in enumerate(row):
            if c == "#":
                d.rectangle([64 + i * k, 130 + j * k, 63 + (i + 1) * k, 129 + (j + 1) * k], fill=P)
    d.text((208, 162), "POCKETTERM OS", font=vt(56), fill=P, anchor="lm")
    d.text((210, 214), version, font=vt(36), fill=BRIGHT, anchor="lm")
    d.text((64, 318), "> init system", font=vt(26), fill=MUTED, anchor="lm")
    d.rectangle([64, 340, W - 65, 352], outline=LINE)
    pitch = (W - 132) / SEGMENTS
    for i in range(lit):
        x = 68 + i * pitch
        d.rectangle([round(x), 344, round(x + pitch) - 5, 348], fill=P)
    if MENTION:
        spaced(d, W - 48, H - 48, MENTION, vt(20), MUTED, 4, "r")
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
