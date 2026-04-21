"""
Generates the Tap Bird to Fly app icon.

Produces two PNGs used by flutter_launcher_icons:
  - assets/icon/app_icon.png             (1024x1024, full icon with background)
  - assets/icon/app_icon_foreground.png  (1024x1024, bird only, transparent,
                                          sized for Android adaptive-icon safe zone)

The artwork is generated from scratch by this script — no third-party or
licensed assets are used, so the output is free to ship.

Run: python3 tools/generate_icon.py
"""
from __future__ import annotations

import os
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "icon")
os.makedirs(OUT_DIR, exist_ok=True)

FINAL = 1024
SS = 4  # supersampling factor for smooth edges
SIZE = FINAL * SS


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def draw_sky_background(img: Image.Image) -> None:
    top = (78, 192, 202)     # #4EC0CA
    bottom = (167, 232, 238) # #A7E8EE
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        row = lerp(top, bottom, y / (h - 1))
        for x in range(w):
            pixels[x, y] = row + (255,)


def draw_bird(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int) -> None:
    body = (247, 208, 70)
    body_edge = (196, 157, 30)
    belly = (251, 232, 156)
    wing = (228, 184, 46)
    wing_edge = (170, 128, 20)
    beak = (238, 139, 46)
    beak_edge = (170, 85, 20)

    # Body (outlined)
    draw.ellipse(
        (cx - r, cy - r, cx + r, cy + r),
        fill=body,
        outline=body_edge,
        width=max(1, int(r * 0.05)),
    )

    # Belly (lighter lower oval)
    br = int(r * 0.65)
    bx = cx + int(r * 0.08)
    by = cy + int(r * 0.18)
    draw.ellipse((bx - br, by - br, bx + br, by + br), fill=belly)

    # Wing (teardrop-ish polygon)
    wing_poly = [
        (cx - int(r * 0.15), cy + int(r * 0.05)),
        (cx - int(r * 0.75), cy + int(r * 0.45)),
        (cx - int(r * 0.15), cy + int(r * 0.55)),
        (cx + int(r * 0.30), cy + int(r * 0.45)),
    ]
    draw.polygon(wing_poly, fill=wing, outline=wing_edge)

    # Eye (white + pupil)
    eye_r = int(r * 0.20)
    ex = cx + int(r * 0.30)
    ey = cy - int(r * 0.22)
    draw.ellipse(
        (ex - eye_r, ey - eye_r, ex + eye_r, ey + eye_r),
        fill=(255, 255, 255),
        outline=(0, 0, 0),
        width=max(1, int(r * 0.03)),
    )
    pupil_r = int(eye_r * 0.55)
    px = ex + int(eye_r * 0.25)
    py = ey + int(eye_r * 0.05)
    draw.ellipse(
        (px - pupil_r, py - pupil_r, px + pupil_r, py + pupil_r),
        fill=(0, 0, 0),
    )
    # Eye highlight
    hr = int(pupil_r * 0.45)
    draw.ellipse(
        (px - hr - int(pupil_r * 0.25),
         py - hr - int(pupil_r * 0.25),
         px - int(pupil_r * 0.25),
         py - int(pupil_r * 0.25)),
        fill=(255, 255, 255),
    )

    # Beak (chunky triangle pointing right)
    beak_poly = [
        (cx + int(r * 0.55), cy - int(r * 0.05)),
        (cx + int(r * 1.15), cy + int(r * 0.10)),
        (cx + int(r * 0.55), cy + int(r * 0.28)),
    ]
    draw.polygon(beak_poly, fill=beak, outline=beak_edge)
    # Beak crease
    draw.line(
        [(cx + int(r * 0.60), cy + int(r * 0.12)),
         (cx + int(r * 1.10), cy + int(r * 0.10))],
        fill=beak_edge,
        width=max(1, int(r * 0.02)),
    )


def with_shadow(layer: Image.Image, offset_y: int, blur: int, alpha: int) -> Image.Image:
    """Returns a new RGBA image with a soft drop shadow composited under `layer`."""
    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    # Build the shadow from the alpha of the layer.
    alpha_mask = layer.split()[-1]
    sh = Image.new("RGBA", layer.size, (0, 0, 0, alpha))
    shadow.paste(sh, (0, offset_y), alpha_mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    return Image.alpha_composite(shadow, layer)


def render_full_icon() -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_sky_background(img)

    # Soft rounded clouds in the corners for depth.
    draw = ImageDraw.Draw(img)
    cloud_color = (255, 255, 255, 140)
    for cx, cy, rr in [
        (int(SIZE * 0.18), int(SIZE * 0.22), int(SIZE * 0.09)),
        (int(SIZE * 0.82), int(SIZE * 0.78), int(SIZE * 0.10)),
    ]:
        draw.ellipse((cx - rr, cy - rr, cx + rr, cy + rr), fill=cloud_color)
        draw.ellipse(
            (cx - int(rr * 1.6), cy - int(rr * 0.5),
             cx - int(rr * 0.2), cy + int(rr * 0.9)),
            fill=cloud_color,
        )
        draw.ellipse(
            (cx + int(rr * 0.2), cy - int(rr * 0.5),
             cx + int(rr * 1.6), cy + int(rr * 0.9)),
            fill=cloud_color,
        )

    # Draw the bird onto its own layer so we can drop a shadow.
    bird_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    bird_draw = ImageDraw.Draw(bird_layer)
    r = int(SIZE * 0.30)
    cx = SIZE // 2 - int(SIZE * 0.03)
    cy = SIZE // 2 + int(SIZE * 0.02)
    draw_bird(bird_draw, cx, cy, r)
    bird_layer = with_shadow(bird_layer, offset_y=int(SIZE * 0.015),
                             blur=int(SIZE * 0.015), alpha=110)

    img = Image.alpha_composite(img, bird_layer)
    return img.resize((FINAL, FINAL), Image.LANCZOS)


def render_foreground_icon() -> Image.Image:
    """Android adaptive icon foreground: bird centered in the inner 66% safe zone."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    bird_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(bird_layer)
    r = int(SIZE * 0.22)  # smaller so it fits in the adaptive-icon safe zone
    cx = SIZE // 2 - int(SIZE * 0.02)
    cy = SIZE // 2 + int(SIZE * 0.01)
    draw_bird(draw, cx, cy, r)
    bird_layer = with_shadow(bird_layer, offset_y=int(SIZE * 0.012),
                             blur=int(SIZE * 0.012), alpha=110)
    img = Image.alpha_composite(img, bird_layer)
    return img.resize((FINAL, FINAL), Image.LANCZOS)


def main() -> None:
    full = render_full_icon()
    full_path = os.path.join(OUT_DIR, "app_icon.png")
    full.save(full_path, optimize=True)
    print(f"wrote {full_path}  ({full.size[0]}x{full.size[1]})")

    fg = render_foreground_icon()
    fg_path = os.path.join(OUT_DIR, "app_icon_foreground.png")
    fg.save(fg_path, optimize=True)
    print(f"wrote {fg_path}  ({fg.size[0]}x{fg.size[1]})")


if __name__ == "__main__":
    main()
