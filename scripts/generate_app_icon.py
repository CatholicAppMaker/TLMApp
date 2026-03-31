#!/usr/bin/env python3

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
APPICON_DIR = ROOT / "LatinMassCompanion/Resources/Assets.xcassets/AppIcon.appiconset"
ASSET_CATALOG_DIR = APPICON_DIR.parent
PREVIEW_DIR = ROOT / "output"

BACKGROUND = "#5A1724"
BACKGROUND_DARK = "#3C0E17"
GOLD = "#D4AF63"
GOLD_LIGHT = "#E7C98A"
PARCHMENT = "#F4E8CE"
PARCHMENT_SHADOW = "#D8C6A1"
BURGUNDY_INK = "#6A2230"


def font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/NewYork.ttf",
        "/System/Library/Fonts/Supplemental/Georgia Bold.ttf",
        "/System/Library/Fonts/Supplemental/Times New Roman Bold.ttf",
        "/System/Library/Fonts/Supplemental/Times New Roman.ttf",
    ]

    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)

    return ImageFont.load_default()


def lerp_channel(start: int, end: int, ratio: float) -> int:
    return round(start + (end - start) * ratio)


def lerp_color(start: tuple[int, int, int], end: tuple[int, int, int], ratio: float) -> tuple[int, int, int]:
    return tuple(lerp_channel(start[index], end[index], ratio) for index in range(3))


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index : index + 2], 16) for index in (0, 2, 4))


def create_background(size: int) -> Image.Image:
    image = Image.new("RGB", (size, size), BACKGROUND)
    draw = ImageDraw.Draw(image)
    top = hex_to_rgb(BACKGROUND)
    bottom = hex_to_rgb(BACKGROUND_DARK)

    for y in range(size):
        ratio = y / max(size - 1, 1)
        draw.line([(0, y), (size, y)], fill=lerp_color(top, bottom, ratio))

    vignette = Image.new("L", (size, size), 0)
    vignette_draw = ImageDraw.Draw(vignette)
    vignette_draw.ellipse(
        (-size * 0.15, -size * 0.08, size * 1.15, size * 1.08),
        fill=170,
    )
    vignette = vignette.filter(ImageFilter.GaussianBlur(radius=size * 0.09))

    dark_overlay = Image.new("RGB", (size, size), BACKGROUND_DARK)
    image = Image.composite(image, dark_overlay, Image.eval(vignette, lambda value: 255 - value))

    return image


def draw_corner_ornaments(draw: ImageDraw.ImageDraw, size: int) -> None:
    margin = size * 0.1
    ornament = size * 0.11
    width = max(6, size // 120)

    corners = [
        (margin, margin, margin + ornament, margin + ornament, 180, 270),
        (size - margin - ornament, margin, size - margin, margin + ornament, 270, 360),
        (margin, size - margin - ornament, margin + ornament, size - margin, 90, 180),
        (size - margin - ornament, size - margin - ornament, size - margin, size - margin, 0, 90),
    ]

    for left, top, right, bottom, start, end in corners:
        draw.arc((left, top, right, bottom), start=start, end=end, fill=GOLD, width=width)


def draw_cross(draw: ImageDraw.ImageDraw, size: int) -> None:
    center_x = size / 2
    top = size * 0.235
    cross_height = size * 0.21
    vertical_width = size * 0.052
    horizontal_width = size * 0.17
    horizontal_height = size * 0.045
    horizontal_y = top + cross_height * 0.38

    draw.rounded_rectangle(
        (
            center_x - vertical_width / 2,
            top,
            center_x + vertical_width / 2,
            top + cross_height,
        ),
        radius=vertical_width / 2,
        fill=GOLD,
    )
    draw.rounded_rectangle(
        (
            center_x - horizontal_width / 2,
            horizontal_y,
            center_x + horizontal_width / 2,
            horizontal_y + horizontal_height,
        ),
        radius=horizontal_height / 2,
        fill=GOLD,
    )

    jewel = size * 0.026
    draw.ellipse(
        (
            center_x - jewel,
            horizontal_y + horizontal_height / 2 - jewel,
            center_x + jewel,
            horizontal_y + horizontal_height / 2 + jewel,
        ),
        fill=GOLD_LIGHT,
        outline=BURGUNDY_INK,
        width=max(2, size // 256),
    )


def draw_monogram(base: Image.Image, draw: ImageDraw.ImageDraw, size: int) -> None:
    monogram_font = font(round(size * 0.25))
    text = "TLM"
    bbox = draw.textbbox((0, 0), text, font=monogram_font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) / 2
    y = size * 0.49

    shadow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_draw.text((x, y + size * 0.008), text, font=monogram_font, fill=PARCHMENT_SHADOW)
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=size * 0.006))
    base.alpha_composite(shadow_layer)

    draw.text((x, y), text, font=monogram_font, fill=BURGUNDY_INK)

    subtitle_font = font(round(size * 0.052))
    subtitle = "Traditional Latin Mass"
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (size - subtitle_width) / 2
    subtitle_y = size * 0.765
    draw.text((subtitle_x, subtitle_y), subtitle, font=subtitle_font, fill=BURGUNDY_INK)


def generate_master_icon(size: int = 1024) -> Image.Image:
    background = create_background(size).convert("RGBA")
    draw = ImageDraw.Draw(background)

    outer_margin = size * 0.065
    draw.rounded_rectangle(
        (outer_margin, outer_margin, size - outer_margin, size - outer_margin),
        radius=size * 0.13,
        outline=GOLD,
        width=max(8, size // 96),
    )

    inner_margin = size * 0.14
    parchment_box = (
        inner_margin,
        inner_margin,
        size - inner_margin,
        size - inner_margin,
    )

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        (
            parchment_box[0],
            parchment_box[1] + size * 0.012,
            parchment_box[2],
            parchment_box[3] + size * 0.012,
        ),
        radius=size * 0.1,
        fill=(27, 8, 12, 95),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=size * 0.018))
    background.alpha_composite(shadow)

    draw.rounded_rectangle(
        parchment_box,
        radius=size * 0.1,
        fill=PARCHMENT,
        outline=GOLD,
        width=max(8, size // 96),
    )

    inner_rule_margin = size * 0.03
    draw.rounded_rectangle(
        (
            parchment_box[0] + inner_rule_margin,
            parchment_box[1] + inner_rule_margin,
            parchment_box[2] - inner_rule_margin,
            parchment_box[3] - inner_rule_margin,
        ),
        radius=size * 0.078,
        outline=BURGUNDY_INK,
        width=max(4, size // 180),
    )

    draw_corner_ornaments(draw, size)
    draw_cross(draw, size)
    draw_monogram(background, draw, size)

    return background.convert("RGB")


def write_contents_json() -> None:
    contents = {
        "images": [
            {"filename": "Icon-40.png", "idiom": "iphone", "scale": "2x", "size": "20x20"},
            {"filename": "Icon-60.png", "idiom": "iphone", "scale": "3x", "size": "20x20"},
            {"filename": "Icon-58.png", "idiom": "iphone", "scale": "2x", "size": "29x29"},
            {"filename": "Icon-87.png", "idiom": "iphone", "scale": "3x", "size": "29x29"},
            {"filename": "Icon-80.png", "idiom": "iphone", "scale": "2x", "size": "40x40"},
            {"filename": "Icon-120.png", "idiom": "iphone", "scale": "3x", "size": "40x40"},
            {"filename": "Icon-120@60.png", "idiom": "iphone", "scale": "2x", "size": "60x60"},
            {"filename": "Icon-180.png", "idiom": "iphone", "scale": "3x", "size": "60x60"},
            {"filename": "Icon-1024.png", "idiom": "ios-marketing", "scale": "1x", "size": "1024x1024"},
        ],
        "info": {"author": "xcode", "version": 1},
    }
    (APPICON_DIR / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def main() -> None:
    APPICON_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_CATALOG_DIR.mkdir(parents=True, exist_ok=True)
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)

    (ASSET_CATALOG_DIR / "Contents.json").write_text(
        json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n"
    )

    master = generate_master_icon(1024)
    master.save(APPICON_DIR / "Icon-1024.png")
    master.save(PREVIEW_DIR / "latin-mass-app-icon-preview.png")

    sizes = {
        "Icon-40.png": 40,
        "Icon-60.png": 60,
        "Icon-58.png": 58,
        "Icon-87.png": 87,
        "Icon-80.png": 80,
        "Icon-120.png": 120,
        "Icon-120@60.png": 120,
        "Icon-180.png": 180,
    }

    for filename, target_size in sizes.items():
        master.resize((target_size, target_size), Image.Resampling.LANCZOS).save(APPICON_DIR / filename)

    write_contents_json()
    print(f"Wrote app icon set to {APPICON_DIR}")


if __name__ == "__main__":
    main()
