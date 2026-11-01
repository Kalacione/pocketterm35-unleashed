#!/usr/bin/env python3
"""Icônes pixel de la charte Phosphore, sur une grille de 32 x 32.

Chaque icône est une liste de formes (rectangle, cadre, anneau, polygone,
trait) tramées sur la grille, puis écrites en SVG de rectangles : nettes à 32,
64 et 128 px. Le dessin est au trait, fond transparent, pour que le lanceur
puisse le teindre d'une seule couleur sur la sélection.
  python3 tools/icons.py   # regénère home/.local/share/icons/Phosphore
"""
import math
from pathlib import Path

N = 32
G, B, M = "#63e6a4", "#d4ffe9", "#5e8f78"  # primary, bright, muted


def rect(x, y, w, h):
    return lambda px, py: x <= px < x + w and y <= py < y + h


def frame(x, y, w, h, t=2):
    outer, inner = rect(x, y, w, h), rect(x + t, y + t, w - 2 * t, h - 2 * t)
    return lambda px, py: outer(px, py) and not inner(px, py)


def disc(cx, cy, r):
    return lambda px, py: math.hypot(px + 0.5 - cx, py + 0.5 - cy) <= r


def ring(cx, cy, r, t=2):
    return lambda px, py: r - t < math.hypot(px + 0.5 - cx, py + 0.5 - cy) <= r


def poly(*pts):
    def inside(px, py):
        x, y, hit = px + 0.5, py + 0.5, False
        for (x1, y1), (x2, y2) in zip(pts, pts[1:] + pts[:1]):
            if (y1 > y) != (y2 > y) and x < x1 + (y - y1) * (x2 - x1) / (y2 - y1):
                hit = not hit
        return hit
    return inside


def line(x1, y1, x2, y2, t=2):
    def near(px, py):
        x, y = px + 0.5, py + 0.5
        dx, dy = x2 - x1, y2 - y1
        k = max(0, min(1, ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)))
        return math.hypot(x - x1 - k * dx, y - y1 - k * dy) <= t / 2
    return near


def minus(a, b):
    return lambda px, py: a(px, py) and not b(px, py)


def gear(cx, cy):
    def hit(px, py):
        x, y = px + 0.5 - cx, py + 0.5 - cy
        d, a = math.hypot(x, y), math.atan2(y, x)
        tooth = math.cos(8 * a) > 0.35
        return 5.5 < d <= 10.5 or (10.5 < d <= 14 and tooth)
    return hit


ICONS = {
    "foot": [  # terminal
        (G, frame(2, 4, 28, 24)), (G, rect(2, 4, 28, 5)),
        (B, line(8, 13, 13, 17)), (B, line(13, 17, 8, 21)), (B, rect(15, 21, 9, 2)),
    ],
    "system-file-manager": [  # fichiers
        (G, poly((2, 6), (12, 6), (15, 9), (30, 9), (30, 28), (2, 28))),
        (None, poly((4, 12), (28, 12), (28, 26), (4, 26))),
        (B, rect(7, 16, 18, 2)), (M, rect(7, 20, 13, 2)),
    ],
    "mousepad": [  # éditeur
        (G, minus(frame(4, 2, 20, 28), poly((17, 2), (24, 2), (24, 9)))),
        (G, line(17, 3, 23, 9)), (G, rect(17, 2, 2, 8)), (G, rect(17, 8, 7, 2)),
        (M, rect(8, 13, 10, 2)), (M, rect(8, 17, 12, 2)), (M, rect(8, 21, 8, 2)),
        (B, line(28, 12, 17, 27, 3)), (B, poly((15, 30), (16, 26), (19, 28))),
    ],
    "vlc": [  # le cône
        (G, poly((13, 3), (19, 3), (25, 25), (7, 25))),
        (B, poly((11.2, 10), (20.8, 10), (21.9, 14), (10.1, 14))),
        (B, poly((9, 18), (23, 18), (24.1, 22), (7.9, 22))),
        (G, rect(3, 25, 26, 4)),
    ],
    "mpv": [  # vidéo
        (G, frame(2, 5, 28, 22)),
        *[(M, rect(x, y, 2, 2)) for x in range(6, 28, 5) for y in (8, 22)],
        (B, poly((12, 11), (21, 16), (12, 21))),
    ],
    "chromium": [  # navigateur : globe, équateur, méridien
        (G, ring(16, 16, 14)),
        (G, rect(3, 15, 26, 2)),
        (M, rect(6, 9, 20, 1)), (M, rect(6, 22, 20, 1)),
        (B, lambda x, y: 0.75 < math.hypot((x + 0.5 - 16) / 6.5, (y + 0.5 - 16) / 13) <= 1),
    ],
    "darkwire": [  # assistant
        (G, frame(3, 4, 26, 18)), (G, poly((8, 22), (14, 22), (8, 28))),
        (B, rect(9, 12, 3, 3)), (B, rect(15, 12, 3, 3)), (B, rect(21, 12, 3, 3)),
    ],
    "preferences-system": [  # paramètres
        (G, gear(16, 16)),
        (B, ring(16, 16, 3.5, 2)),
    ],
    "utilities-system-monitor": [  # moniteur
        (G, frame(2, 3, 28, 20)), (G, rect(14, 23, 4, 4)), (G, rect(8, 27, 16, 2)),
        (B, line(6, 17, 11, 12)), (B, line(11, 12, 15, 15)), (B, line(15, 15, 20, 8)), (B, line(20, 8, 26, 13)),
    ],
    "baobab": [  # disque
        (G, ring(16, 16, 14)),
        (B, minus(disc(16, 16, 10), lambda x, y: not (x >= 16 and y < 16))),
        (M, ring(16, 16, 10, 2)),
    ],
    "multimedia-photo-viewer": [  # images
        (G, frame(2, 5, 28, 22)),
        (G, poly((4, 25), (12, 14), (18, 21), (21, 18), (28, 25))),
        (B, disc(22, 11, 3)),
    ],
    "galculator": [  # calculatrice
        (G, frame(6, 2, 20, 28)), (B, rect(9, 5, 14, 6)),
        *[(G if (c, r) != (2, 3) else B, rect(9 + c * 5, 14 + r * 4, 4, 3)) for c in range(3) for r in range(4)],
    ],
}


def raster(shapes):
    grid = [[None] * N for _ in range(N)]
    for color, shape in shapes:
        for y in range(N):
            for x in range(N):
                if shape(x, y):
                    grid[y][x] = color
    rects = []
    for y, row in enumerate(grid):
        x = 0
        while x < N:
            n = 1
            while x + n < N and row[x + n] == row[x]:
                n += 1
            if row[x]:
                rects.append(f'<rect x="{x}" y="{y}" width="{n}" height="1" fill="{row[x]}"/>')
            x += n
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="32" height="32" '
            'shape-rendering="crispEdges">' + "".join(rects) + "</svg>\n")


if __name__ == "__main__":
    out = Path(__file__).resolve().parent.parent / "home/.local/share/icons/Phosphore/32x32/apps"
    out.mkdir(parents=True, exist_ok=True)
    for name, shapes in ICONS.items():
        (out / f"{name}.svg").write_text(raster(shapes))
    print(f"{len(ICONS)} icônes dans {out}")
