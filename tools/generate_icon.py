"""
Generates the Tap Bird to Fly app icon and writes every size the native
iOS and Android projects need, so the launcher icon actually changes
without needing a separate `dart run flutter_launcher_icons` step.

Outputs:
  - assets/icon/app_icon.png                              (1024x1024 master)
  - assets/icon/app_icon_foreground.png                   (1024x1024 adaptive FG)
  - android/app/src/main/res/mipmap-*/ic_launcher.png
  - android/app/src/main/res/mipmap-*/ic_launcher_foreground.png
  - android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
  - android/app/src/main/res/values/ic_launcher_background.xml
  - ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png
  - ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json

All artwork is generated from primitives by this script — no third-party
clipart, fonts, or AI-generated assets — so the result is license-clean.

Run: python3 tools/generate_icon.py
"""
from __future__ import annotations

import json
import os

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSET_DIR = os.path.join(ROOT, "assets", "icon")
ANDROID_RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
IOS_APPICON = os.path.join(
    ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset"
)

FINAL = 1024
SS = 4  # supersampling factor for smooth edges
SIZE = FINAL * SS

ADAPTIVE_BG = (78, 192, 202, 255)  # #4EC0CA

ANDROID_LEGACY = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
ANDROID_ADAPTIVE_FG = {
    "mipmap-mdpi": 108,
    "mipmap-hdpi": 162,
    "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324,
    "mipmap-xxxhdpi": 432,
}

IOS_ICONS = [
    ("Icon-App-20x20@1x.png", 20, "20x20", "iphone", "1x"),
    ("Icon-App-20x20@2x.png", 40, "20x20", "iphone", "2x"),
    ("Icon-App-20x20@3x.png", 60, "20x20", "iphone", "3x"),
    ("Icon-App-29x29@1x.png", 29, "29x29", "iphone", "1x"),
    ("Icon-App-29x29@2x.png", 58, "29x29", "iphone", "2x"),
    ("Icon-App-29x29@3x.png", 87, "29x29", "iphone", "3x"),
    ("Icon-App-40x40@1x.png", 40, "40x40", "iphone", "1x"),
    ("Icon-App-40x40@2x.png", 80, "40x40", "iphone", "2x"),
    ("Icon-App-40x40@3x.png", 120, "40x40", "iphone", "3x"),
    ("Icon-App-60x60@2x.png", 120, "60x60", "iphone", "2x"),
    ("Icon-App-60x60@3x.png", 180, "60x60", "iphone", "3x"),
    ("Icon-App-20x20@1x.png", 20, "20x20", "ipad", "1x"),
    ("Icon-App-20x20@2x.png", 40, "20x20", "ipad", "2x"),
    ("Icon-App-29x29@1x.png", 29, "29x29", "ipad", "1x"),
    ("Icon-App-29x29@2x.png", 58, "29x29", "ipad", "2x"),
    ("Icon-App-40x40@1x.png", 40, "40x40", "ipad", "1x"),
    ("Icon-App-40x40@2x.png", 80, "40x40", "ipad", "2x"),
    ("Icon-App-76x76@1x.png", 76, "76x76", "ipad", "1x"),
    ("Icon-App-76x76@2x.png", 152, "76x76", "ipad", "2x"),
    ("Icon-App-83.5x83.5@2x.png", 167, "83.5x83.5", "ipad", "2x"),
    ("Icon-App-1024x1024@1x.png", 1024, "1024x1024", "ios-marketing", "1x"),
]


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def draw_sky_background(img: Image.Image) -> None:
    top = (78, 192, 202)
    bottom = (167, 232, 238)
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

    draw.ellipse(
        (cx - r, cy - r, cx + r, cy + r),
        fill=body,
        outline=body_edge,
        width=max(1, int(r * 0.05)),
    )

    br = int(r * 0.65)
    bx = cx + int(r * 0.08)
    by = cy + int(r * 0.18)
    draw.ellipse((bx - br, by - br, bx + br, by + br), fill=belly)

    wing_poly = [
        (cx - int(r * 0.15), cy + int(r * 0.05)),
        (cx - int(r * 0.75), cy + int(r * 0.45)),
        (cx - int(r * 0.15), cy + int(r * 0.55)),
        (cx + int(r * 0.30), cy + int(r * 0.45)),
    ]
    draw.polygon(wing_poly, fill=wing, outline=wing_edge)

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
    hr = int(pupil_r * 0.45)
    draw.ellipse(
        (px - hr - int(pupil_r * 0.25),
         py - hr - int(pupil_r * 0.25),
         px - int(pupil_r * 0.25),
         py - int(pupil_r * 0.25)),
        fill=(255, 255, 255),
    )

    beak_poly = [
        (cx + int(r * 0.55), cy - int(r * 0.05)),
        (cx + int(r * 1.15), cy + int(r * 0.10)),
        (cx + int(r * 0.55), cy + int(r * 0.28)),
    ]
    draw.polygon(beak_poly, fill=beak, outline=beak_edge)
    draw.line(
        [(cx + int(r * 0.60), cy + int(r * 0.12)),
         (cx + int(r * 1.10), cy + int(r * 0.10))],
        fill=beak_edge,
        width=max(1, int(r * 0.02)),
    )


def with_shadow(layer: Image.Image, offset_y: int, blur: int, alpha: int) -> Image.Image:
    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    alpha_mask = layer.split()[-1]
    sh = Image.new("RGBA", layer.size, (0, 0, 0, alpha))
    shadow.paste(sh, (0, offset_y), alpha_mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    return Image.alpha_composite(shadow, layer)


def render_full_icon() -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_sky_background(img)

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
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    bird_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(bird_layer)
    r = int(SIZE * 0.22)
    cx = SIZE // 2 - int(SIZE * 0.02)
    cy = SIZE // 2 + int(SIZE * 0.01)
    draw_bird(draw, cx, cy, r)
    bird_layer = with_shadow(bird_layer, offset_y=int(SIZE * 0.012),
                             blur=int(SIZE * 0.012), alpha=110)
    img = Image.alpha_composite(img, bird_layer)
    return img.resize((FINAL, FINAL), Image.LANCZOS)


def save_sized(img: Image.Image, path: str, size: int) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    resized = img.resize((size, size), Image.LANCZOS)
    if resized.mode == "RGBA":
        # iOS marketing and launcher icons should be opaque.
        if path.endswith("Icon-App-1024x1024@1x.png"):
            bg = Image.new("RGB", resized.size, (78, 192, 202))
            bg.paste(resized, mask=resized.split()[-1])
            bg.save(path, optimize=True)
            return
    resized.save(path, optimize=True)


def write_android(master: Image.Image, foreground: Image.Image) -> None:
    if not os.path.isdir(os.path.dirname(ANDROID_RES)):
        print(f"[skip] android project not found at {ANDROID_RES}")
        return

    # Legacy square-ish icon (shown on Android <= 7).
    for folder, size in ANDROID_LEGACY.items():
        save_sized(
            master,
            os.path.join(ANDROID_RES, folder, "ic_launcher.png"),
            size,
        )

    # Adaptive icon foreground (API 26+).
    for folder, size in ANDROID_ADAPTIVE_FG.items():
        save_sized(
            foreground,
            os.path.join(ANDROID_RES, folder, "ic_launcher_foreground.png"),
            size,
        )

    # Adaptive icon XML + background color.
    anydpi = os.path.join(ANDROID_RES, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, "ic_launcher.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background" />\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
            '</adaptive-icon>\n'
        )

    values = os.path.join(ANDROID_RES, "values")
    os.makedirs(values, exist_ok=True)
    with open(os.path.join(values, "ic_launcher_background.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<resources>\n'
            '    <color name="ic_launcher_background">#4EC0CA</color>\n'
            '</resources>\n'
        )
    print(f"[ok] android icons written under {ANDROID_RES}")


def write_ios(master: Image.Image) -> None:
    if not os.path.isdir(os.path.dirname(os.path.dirname(IOS_APPICON))):
        print(f"[skip] ios project not found at {IOS_APPICON}")
        return

    os.makedirs(IOS_APPICON, exist_ok=True)
    images = []
    for fname, size, spec, idiom, scale in IOS_ICONS:
        save_sized(master, os.path.join(IOS_APPICON, fname), size)
        images.append({
            "size": spec,
            "idiom": idiom,
            "filename": fname,
            "scale": scale,
        })

    contents = {
        "images": images,
        "info": {"version": 1, "author": "xcode"},
    }
    with open(os.path.join(IOS_APPICON, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    print(f"[ok] ios icons written under {IOS_APPICON}")


def main() -> None:
    os.makedirs(ASSET_DIR, exist_ok=True)
    master = render_full_icon()
    foreground = render_foreground_icon()

    master.save(os.path.join(ASSET_DIR, "app_icon.png"), optimize=True)
    foreground.save(os.path.join(ASSET_DIR, "app_icon_foreground.png"), optimize=True)
    print(f"[ok] master art written under {ASSET_DIR}")

    write_android(master, foreground)
    write_ios(master)


if __name__ == "__main__":
    main()
