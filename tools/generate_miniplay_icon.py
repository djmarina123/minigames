#!/usr/bin/env python3
"""Generate MiniPlay app icon (512x512 source) and platform variants."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageChops, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/branding/miniplay_icon_512.png"
ORIGINAL_REF = ROOT / "assets/branding/proposals/icon_reference_512.png"

TOP = (0xE8, 0x43, 0x93)
BOTTOM = (0xFF, 0x6B, 0x6B)
SIZE = 512
GAMEPAD_SCALE = 0.72
BORDER_SKIP = 48


def _lerp(a: int, b: int, t: float) -> int:
    return round(a + (b - a) * t)


def _gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    last = size - 1
    for y in range(size):
        t = y / last
        row = (
            _lerp(TOP[0], BOTTOM[0], t),
            _lerp(TOP[1], BOTTOM[1], t),
            _lerp(TOP[2], BOTTOM[2], t),
        )
        for x in range(size):
            px[x, y] = row
    return img


def _largest_component_bbox(mask: Image.Image) -> tuple[int, int, int, int] | None:
    """Keep only the largest white blob — drops corner matte specks."""
    w, h = mask.size
    visited = bytearray(w * h)
    best = 0
    best_box = None
    px = mask.load()

    def idx(x: int, y: int) -> int:
        return y * w + x

    for sy in range(h):
        for sx in range(w):
            i = idx(sx, sy)
            if visited[i] or px[sx, sy] == 0:
                continue
            stack = [(sx, sy)]
            visited[i] = 1
            count = 0
            x0 = x1 = sx
            y0 = y1 = sy
            while stack:
                x, y = stack.pop()
                count += 1
                x0, y0 = min(x0, x), min(y0, y)
                x1, y1 = max(x1, x), max(y1, y)
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if nx < 0 or ny < 0 or nx >= w or ny >= h:
                        continue
                    ni = idx(nx, ny)
                    if not visited[ni] and px[nx, ny]:
                        visited[ni] = 1
                        stack.append((nx, ny))
            if count > best:
                best = count
                best_box = (x0, y0, x1 + 1, y1 + 1)
    return best_box


def _gamepad_mask(ref: Image.Image) -> Image.Image:
    """White body only — cutouts stay empty."""
    mask = Image.new("L", (SIZE, SIZE), 0)
    px = ref.load()
    mpx = mask.load()
    for y in range(SIZE):
        for x in range(SIZE):
            if (
                x < BORDER_SKIP
                or y < BORDER_SKIP
                or x >= SIZE - BORDER_SKIP
                or y >= SIZE - BORDER_SKIP
            ):
                continue
            r, g, b, a = px[x, y]
            if a > 200 and r > 244 and g > 244 and b > 244:
                mpx[x, y] = 255
    mask = mask.filter(ImageFilter.MaxFilter(3))
    bbox = _largest_component_bbox(mask)
    if bbox is None:
        return mask
    cleaned = Image.new("L", (SIZE, SIZE), 0)
    cleaned.paste(mask.crop(bbox), bbox[:2])
    return cleaned


def _shadow_mask(ref: Image.Image, pad_mask: Image.Image) -> Image.Image:
    """Soft drop shadow from the reference, excluding corner matte."""
    shadow = Image.new("L", (SIZE, SIZE), 0)
    px = ref.load()
    spx = shadow.load()
    for y in range(SIZE):
        for x in range(SIZE):
            if (
                x < BORDER_SKIP
                or y < BORDER_SKIP
                or x >= SIZE - BORDER_SKIP
                or y >= SIZE - BORDER_SKIP
            ):
                continue
            r, g, b, a = px[x, y]
            if a < 200 or pad_mask.getpixel((x, y)) > 0:
                continue
            if r > 210 or g > 170 or b > 175:
                continue
            lum = (r + g + b) / 3
            if lum < 205:
                spx[x, y] = min(255, round((205 - lum) * 4))
    return shadow.filter(ImageFilter.GaussianBlur(radius=4))


def _foreground_layer(ref: Image.Image) -> Image.Image:
    pad = _gamepad_mask(ref)
    shadow = _shadow_mask(ref, pad)
    bbox = ImageChops.lighter(pad, shadow).getbbox()
    if bbox is None:
        raise RuntimeError("Could not detect gamepad in reference image.")

    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    for y in range(bbox[1], bbox[3]):
        for x in range(bbox[0], bbox[2]):
            if pad.getpixel((x, y)):
                layer.putpixel((x, y), (255, 255, 255, 255))
            elif shadow.getpixel((x, y)):
                a = shadow.getpixel((x, y))
                layer.putpixel((x, y), (0, 0, 0, a))
    return layer.crop(bbox)


def _scale_center(layer: Image.Image, scale: float) -> Image.Image:
    w, h = layer.size
    nw, nh = max(1, round(w * scale)), max(1, round(h * scale))
    scaled = layer.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    canvas.alpha_composite(scaled, ((SIZE - nw) // 2, (SIZE - nh) // 2))
    return canvas


def render_icon(size: int = SIZE) -> Image.Image:
    if not ORIGINAL_REF.exists():
        raise FileNotFoundError(f"Missing reference icon: {ORIGINAL_REF}")
    ref = Image.open(ORIGINAL_REF).convert("RGBA")
    if ref.size != (size, size):
        ref = ref.resize((size, size), Image.Resampling.LANCZOS)
    gamepad = _scale_center(_foreground_layer(ref), GAMEPAD_SCALE)
    bg = _gradient(size).convert("RGBA")
    return Image.alpha_composite(bg, gamepad)


def _save_resized(src: Image.Image, path: Path, px: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    src.resize((px, px), Image.Resampling.LANCZOS).save(path, format="PNG", optimize=True)


def _maskable(src: Image.Image, size: int, inset_ratio: float = 0.1) -> Image.Image:
    canvas = _gradient(size).convert("RGBA")
    inner = round(size * (1 - inset_ratio * 2))
    art = src.resize((inner, inner), Image.Resampling.LANCZOS)
    offset = (size - inner) // 2
    canvas.alpha_composite(art, (offset, offset))
    return canvas


def propagate(src: Image.Image) -> None:
    android = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, px in android.items():
        _save_resized(
            src,
            ROOT / f"android/app/src/main/res/{folder}/ic_launcher.png",
            px,
        )

    ios_master = src.resize((1024, 1024), Image.Resampling.LANCZOS)
    ios_set = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    ios_files = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for name, px in ios_files.items():
        master = ios_master if px == 1024 else src
        _save_resized(master, ios_set / name, px)

    web = ROOT / "web/icons"
    _save_resized(src, web / "Icon-192.png", 192)
    _save_resized(src, web / "Icon-512.png", 512)
    _save_resized(_maskable(src, 192), web / "Icon-maskable-192.png", 192)
    _save_resized(_maskable(src, 512), web / "Icon-maskable-512.png", 512)


def main() -> None:
    icon = render_icon(SIZE)
    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    icon.save(SOURCE, format="PNG", optimize=True)
    propagate(icon)
    print(f"Wrote {SOURCE} and platform icons.")


if __name__ == "__main__":
    main()
