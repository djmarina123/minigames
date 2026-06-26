#!/usr/bin/env python3
"""Generate Play Store feature graphic (1024×500) for MiniPlay."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ICON = ROOT / "assets/branding/miniplay_icon_512.png"
OUT = ROOT / "assets/branding/miniplay_feature_graphic_1024x500.png"

W, H = 1024, 500
BG_TOP = (0xFF, 0xF8, 0xF3)
BG_BOTTOM = (0xF0, 0xE8, 0xDC)
PINK = (0xE8, 0x43, 0x93)
PINK_SOFT = (0xF4, 0x8F, 0xB1)
CORAL = (0xFF, 0x6B, 0x6B)
TEXT = (0x2D, 0x34, 0x36)
MUTED = (0x63, 0x6E, 0x72)
WHITE = (255, 255, 255)

# HubTheme card colors — id, short title, card, accent
GAMES = (
    ("memory", "Memória", (0x5B, 0x4B, 0xB7), (0xFF, 0x76, 0x75)),
    ("tap_rush", "Tap Rush", (0xE8, 0x43, 0x93), (0xFD, 0xCB, 0x6E)),
    ("game_2048", "2048", (0x00, 0xB8, 0x94), (0xFD, 0xCB, 0x6E)),
    ("infinite_runner", "Corrida", (0xFF, 0x9F, 0x43), (0x54, 0xA0, 0xFF)),
    ("snake", "Cobra", (0x16, 0xA0, 0x85), (0xF3, 0x9C, 0x12)),
    ("sudoku", "Sudoku", (0x48, 0x34, 0xD4), (0xF9, 0xCA, 0x24)),
)

FEATURES = ("Ranking", "Moedas", "Missões", "Offline")


def _lerp(a: int, b: int, t: float) -> int:
    return round(a + (b - a) * t)


def _blend(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (_lerp(c1[0], c2[0], t), _lerp(c1[1], c2[1], t), _lerp(c1[2], c2[2], t))


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    names = (
        [
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        ]
        if bold
        else [
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
        ]
    )
    for path in names:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def _gradient_bg() -> Image.Image:
    img = Image.new("RGB", (W, H))
    px = img.load()
    last = H - 1
    for y in range(H):
        t = y / last
        row = _blend(BG_TOP, BG_BOTTOM, t)
        for x in range(W):
            px[x, y] = row
    return img


def _blob_layer(
    cx: int,
    cy: int,
    r: int,
    color: tuple[int, int, int],
    alpha: int,
) -> Image.Image:
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*color, alpha))
    return layer.filter(ImageFilter.GaussianBlur(radius=max(8, r // 6)))


def _composite_blobs(base: Image.Image) -> Image.Image:
    canvas = base.convert("RGBA")
    for cx, cy, r, color, alpha in (
        (900, 60, 160, PINK, 42),
        (960, 380, 130, CORAL, 32),
        (780, 460, 100, PINK_SOFT, 28),
        (30, 60, 90, PINK, 22),
        (120, 460, 110, PINK_SOFT, 20),
        (520, 250, 200, PINK, 14),
    ):
        canvas = Image.alpha_composite(canvas, _blob_layer(cx, cy, r, color, alpha))
    return canvas


def _round_rect(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int, int, int],
    radius: int,
    fill: tuple[int, int, int] | tuple[int, int, int, int],
    outline: tuple[int, int, int] | None = None,
    width: int = 0,
) -> None:
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def _tile_shadow(tile_w: int, tile_h: int, radius: int) -> Image.Image:
    shadow = Image.new("RGBA", (tile_w + 16, tile_h + 16), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((4, 8, tile_w + 8, tile_h + 10), radius=radius, fill=(0, 0, 0, 55))
    return shadow.filter(ImageFilter.GaussianBlur(radius=5))


def _draw_memory_art(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    w: int,
    h: int,
    card: tuple[int, int, int],
    accent: tuple[int, int, int],
) -> None:
    blend = _blend(card, accent, 0.45)
    soft = _blend(accent, WHITE, 0.22)
    specs = (
        (card, -0.24, 0.06, -18),
        (accent, 0.04, 0.00, 8),
        (blend, -0.10, 0.16, -6),
        (soft, 0.20, 0.10, 14),
    )
    cw, ch = int(w * 0.40), int(h * 0.46)
    base_x = x + w // 2
    base_y = y + int(h * 0.54)
    for color, dx, dy, angle in specs:
        cx = base_x + int(dx * w)
        cy = base_y + int(dy * h)
        layer = Image.new("RGBA", (cw + 8, ch + 8), (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        ld.rounded_rectangle((2, 6, cw + 2, ch + 4), radius=10, fill=(0, 0, 0, 35))
        ld.rounded_rectangle((0, 0, cw, ch), radius=10, fill=(*color, 255))
        ld.rounded_rectangle((0, 0, cw - 1, ch - 1), radius=10, outline=(*WHITE, 90), width=2)
        rotated = layer.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
        ox = cx - rotated.width // 2
        oy = cy - rotated.height // 2
        draw._image.paste(rotated, (ox, oy), rotated)


def _draw_tap_rush_art(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    w: int,
    h: int,
    card: tuple[int, int, int],
    accent: tuple[int, int, int],
) -> None:
    cx = x + w // 2
    cy = y + int(h * 0.54)
    r = min(w, h) * 0.30
    soft = _blend(accent, WHITE, 0.22)
    draw.ellipse(
        (cx - r * 1.1, cy - r * 1.1, cx + r * 1.1, cy + r * 1.1),
        fill=(*accent, 50),
    )
    for radius, color, alpha in (
        (r, WHITE, 55),
        (r * 0.80, card, 255),
        (r * 0.58, accent, 255),
        (r * 0.36, soft, 255),
        (r * 0.14, WHITE, 255),
    ):
        draw.ellipse(
            (cx - radius, cy - radius, cx + radius, cy + radius),
            fill=(*color, alpha) if alpha < 255 else color,
        )


def _draw_2048_art(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    w: int,
    h: int,
    card: tuple[int, int, int],
    accent: tuple[int, int, int],
) -> None:
    blend = _blend(card, accent, 0.45)
    soft = _blend(accent, WHITE, 0.22)
    tiles = (
        (2, -0.30, -0.10, soft),
        (4, -0.06, 0.04, blend),
        (8, 0.18, -0.06, accent),
        (16, 0.02, 0.20, card),
    )
    ts = int(w * 0.19)
    base_x = x + w // 2
    base_y = y + int(h * 0.56)
    num_font = _font(max(12, ts // 2), bold=True)
    for value, dx, dy, color in tiles:
        cx = base_x + int(dx * w)
        cy = base_y + int(dy * h)
        box = (cx - ts // 2, cy - ts // 2, cx + ts // 2, cy + ts // 2)
        _round_rect(draw, (box[0], box[1] + 2, box[2], box[3] + 2), max(4, ts // 7), (0, 0, 0, 30))
        _round_rect(draw, box, max(4, ts // 7), color)
        _round_rect(draw, box, max(4, ts // 7), WHITE, width=2)
        label = str(value)
        bbox = draw.textbbox((0, 0), label, font=num_font)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        fg = WHITE if value >= 8 else (0x77, 0x6E, 0x65)
        draw.text((cx - tw // 2, cy - th // 2 - 2), label, fill=fg, font=num_font)


def _draw_runner_art(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    w: int,
    h: int,
    card: tuple[int, int, int],
    accent: tuple[int, int, int],
) -> None:
    ground_y = y + int(h * 0.72)
    draw.line((x + 8, ground_y, x + w - 8, ground_y), fill=(*WHITE, 80), width=3)
    for i, gap in enumerate((0.0, 0.22, 0.48, 0.72)):
        ox = x + int(w * (0.18 + gap))
        block_h = int(h * (0.10 + (i % 2) * 0.04))
        _round_rect(
            draw,
            (ox, ground_y - block_h, ox + int(w * 0.10), ground_y),
            4,
            accent if i % 2 else _blend(card, accent, 0.5),
        )

    runner_x = x + int(w * 0.58)
    runner_y = ground_y - int(h * 0.02)
    body_h = int(h * 0.28)
    head_r = int(w * 0.07)
    draw.ellipse(
        (runner_x - head_r, runner_y - body_h - head_r * 2, runner_x + head_r, runner_y - body_h),
        fill=WHITE,
    )
    draw.rounded_rectangle(
        (runner_x - head_r, runner_y - body_h, runner_x + head_r // 2, runner_y - int(h * 0.06)),
        radius=6,
        fill=WHITE,
    )
    draw.line(
        (runner_x, runner_y - int(h * 0.06), runner_x + int(w * 0.14), runner_y - int(h * 0.14)),
        fill=WHITE,
        width=4,
    )
    draw.line(
        (runner_x, runner_y - int(h * 0.08), runner_x - int(w * 0.10), runner_y),
        fill=WHITE,
        width=4,
    )
    draw.line(
        (runner_x, runner_y - int(h * 0.04), runner_x + int(w * 0.08), runner_y + int(h * 0.02)),
        fill=WHITE,
        width=4,
    )
    draw.line(
        (runner_x, runner_y - int(h * 0.04), runner_x - int(w * 0.06), runner_y + int(h * 0.04)),
        fill=WHITE,
        width=4,
    )


def _draw_snake_art(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    w: int,
    h: int,
    card: tuple[int, int, int],
    accent: tuple[int, int, int],
) -> None:
    points = []
    segments = 9
    for i in range(segments):
        t = i / (segments - 1)
        px = x + int(w * (0.14 + t * 0.72))
        wave = math.sin(t * math.pi * 1.6) * h * 0.14
        py = y + int(h * 0.52 + wave)
        points.append((px, py))
    r = int(w * 0.055)
    for i, (px, py) in enumerate(points):
        color = accent if i == 0 else _blend(card, accent, i / segments)
        draw.ellipse((px - r, py - r, px + r, py + r), fill=color)
        if i == 0:
            draw.ellipse((px - r // 3, py - r // 4, px, py + r // 5), fill=WHITE)
    food_x = x + int(w * 0.82)
    food_y = y + int(h * 0.34)
    fr = int(w * 0.05)
    draw.ellipse((food_x - fr, food_y - fr, food_x + fr, food_y + fr), fill=accent)


def _draw_sudoku_art(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    w: int,
    h: int,
    card: tuple[int, int, int],
    accent: tuple[int, int, int],
) -> None:
    grid = int(min(w, h) * 0.58)
    gx = x + (w - grid) // 2
    gy = y + (h - grid) // 2 + 4
    _round_rect(draw, (gx - 4, gy - 4, gx + grid + 4, gy + grid + 4), 8, (*WHITE, 200))
    cell = grid // 3
    for row in range(3):
        for col in range(3):
            cx = gx + col * cell
            cy = gy + row * cell
            fill = accent if (row + col) % 2 == 0 else _blend(card, accent, 0.35)
            _round_rect(draw, (cx + 2, cy + 2, cx + cell - 2, cy + cell - 2), 5, (*fill, 180))
    for i in range(4):
        lw = 3 if i % 3 == 0 else 1
        draw.line((gx, gy + i * cell, gx + grid, gy + i * cell), fill=WHITE, width=lw)
        draw.line((gx + i * cell, gy, gx + i * cell, gy + grid), fill=WHITE, width=lw)
    nums = ((0, 0, "5"), (0, 2, "3"), (1, 1, "7"), (2, 0, "1"), (2, 2, "9"))
    nf = _font(max(11, cell // 2), bold=True)
    for row, col, val in nums:
        cx = gx + col * cell + cell // 2
        cy = gy + row * cell + cell // 2
        bbox = draw.textbbox((0, 0), val, font=nf)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        draw.text((cx - tw // 2, cy - th // 2 - 2), val, fill=WHITE, font=nf)


def _draw_tile_art(
    draw: ImageDraw.ImageDraw,
    game_id: str,
    x: int,
    y: int,
    w: int,
    h: int,
    card: tuple[int, int, int],
    accent: tuple[int, int, int],
) -> None:
    artists = {
        "memory": _draw_memory_art,
        "tap_rush": _draw_tap_rush_art,
        "game_2048": _draw_2048_art,
        "infinite_runner": _draw_runner_art,
        "snake": _draw_snake_art,
        "sudoku": _draw_sudoku_art,
    }
    artists.get(game_id, _draw_tap_rush_art)(draw, x, y, w, h, card, accent)


def _draw_feature_pills(draw: ImageDraw.ImageDraw, x: int, y: int) -> None:
    pill_font = _font(16, bold=True)
    px = x
    for label in FEATURES:
        bbox = draw.textbbox((0, 0), label, font=pill_font)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        pad_x, pad_y = 12, 6
        pw, ph = tw + pad_x * 2, th + pad_y * 2
        _round_rect(
            draw,
            (px, y, px + pw, y + ph),
            ph // 2,
            WHITE,
            outline=PINK,
            width=2,
        )
        draw.text((px + pad_x, y + pad_y - 2), label, fill=PINK, font=pill_font)
        px += pw + 8


def generate() -> Path:
    img = _composite_blobs(_gradient_bg())
    draw = ImageDraw.Draw(img)

    # Accent band
    top = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    td = ImageDraw.Draw(top)
    for x in range(W):
        t = x / (W - 1)
        c = _blend(PINK, CORAL, t)
        td.line((x, 0, x, 11), fill=(*c, 255))
    img = Image.alpha_composite(img, top)
    draw = ImageDraw.Draw(img)

    # App icon with glow
    icon = Image.open(ICON).convert("RGBA")
    icon_size = 152
    icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    ix, iy = 48, 44
    glow = Image.new("RGBA", (icon_size + 40, icon_size + 40), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.rounded_rectangle(
        (8, 8, icon_size + 32, icon_size + 32),
        radius=40,
        fill=(*PINK, 45),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=12))
    img.paste(glow, (ix - 20, iy - 16), glow)
    shadow = _tile_shadow(icon_size, icon_size, 36)
    img.paste(shadow, (ix - 4, iy + 2), shadow)
    img.paste(icon, (ix, iy), icon)
    draw = ImageDraw.Draw(img)

    # Title block
    title_font = _font(58, bold=True)
    tag_font = _font(24)
    tx = 48
    ty = iy + icon_size + 18
    draw.text((tx + 2, ty + 2), "MiniPlay", fill=(*PINK, 40), font=title_font)
    draw.text((tx, ty), "MiniPlay", fill=PINK, font=title_font)
    draw.text(
        (tx, ty + 62),
        "Minijogos casuais num só lugar",
        fill=TEXT,
        font=tag_font,
    )
    _draw_feature_pills(draw, tx, ty + 104)

    # Game tiles
    tile_w, tile_h = 118, 118
    gap = 14
    cols, rows = 3, 2
    grid_w = cols * tile_w + (cols - 1) * gap
    grid_h = rows * tile_h + (rows - 1) * gap
    gx = W - grid_w - 52
    gy = (H - grid_h) // 2 + 6

    name_font = _font(15, bold=True)

    for i, (game_id, title, card, accent) in enumerate(GAMES):
        col = i % cols
        row = i // cols
        x = gx + col * (tile_w + gap)
        y = gy + row * (tile_h + gap)

        shadow = _tile_shadow(tile_w, tile_h, 22)
        img.paste(shadow, (x - 4, y + 2), shadow)

        tile = Image.new("RGBA", (tile_w, tile_h), (0, 0, 0, 0))
        td = ImageDraw.Draw(tile)
        _round_rect(td, (0, 0, tile_w, tile_h), 22, card)
        _round_rect(td, (2, 2, tile_w - 2, tile_h - 2), 20, _blend(card, WHITE, 0.08), width=0)
        _round_rect(td, (1, 1, tile_w - 2, tile_h - 2), 21, WHITE, width=3)
        _draw_tile_art(td, game_id, 0, 0, tile_w, tile_h, card, accent)
        img.paste(tile, (x, y), tile)

        # Title ribbon
        bbox = draw.textbbox((0, 0), title, font=name_font)
        tw = bbox[2] - bbox[0]
        ribbon_w = tw + 16
        ribbon_h = 22
        rx = x + (tile_w - ribbon_w) // 2
        ry = y + tile_h - ribbon_h // 2 - 2
        _round_rect(draw, (rx, ry, rx + ribbon_w, ry + ribbon_h), 8, (*TEXT, 210))
        draw.text((rx + 8, ry + 2), title, fill=WHITE, font=name_font)

    draw = ImageDraw.Draw(img)

    # Subtle connector dots between branding and grid
    mid_y = H // 2
    for i, alpha in enumerate((30, 50, 70, 50, 30)):
        cx = 360 + i * 18
        r = 3 if i in (1, 3) else 4
        draw.ellipse((cx - r, mid_y - r, cx + r, mid_y + r), fill=(*PINK, alpha))

    # "+8 jogos" hint under grid
    hint_font = _font(16)
    hint = "+ mais jogos no app"
    hb = draw.textbbox((0, 0), hint, font=hint_font)
    hw = hb[2] - hb[0]
    draw.text((gx + (grid_w - hw) // 2, gy + grid_h + 10), hint, fill=MUTED, font=hint_font)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(OUT, "PNG", optimize=True)
    return OUT


if __name__ == "__main__":
    path = generate()
    print(f"Saved {path} ({path.stat().st_size // 1024} KB)")
