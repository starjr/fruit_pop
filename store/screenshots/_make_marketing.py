"""
Generate marketing-style Play Store screenshots by overlaying a caption
banner on top of the existing 1080x1920 in-app screenshots.

Output: store/screenshots/marketing/01_home_mkt.png ... 04_intense_mkt.png
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "marketing"
OUT.mkdir(exist_ok=True)

# (input_filename, line1, line2, palette_top, palette_bot)
JOBS = [
    (
        "01_home.png",
        "한 번 잡으면 멈출 수 없는",
        "수박 만들기 퍼즐",
        (255, 138, 162),  # candy pink
        (255, 107, 107),  # accent coral
    ),
    (
        "03_game_play.png",
        "같은 과일을 톡! 합쳐서",
        "더 큰 과일로 진화",
        (255, 175, 110),  # candy peach
        (255, 138, 162),  # candy pink
    ),
    (
        "04_game_full.png",
        "끊임없는 콤보의 짜릿함",
        "점수 폭발 x6!",
        (155, 123, 216),  # candy lilac
        (255, 138, 162),  # candy pink
    ),
    (
        "05_game_intense.png",
        "체리부터 수박까지",
        "11단계 진화 체인",
        (143, 227, 200),  # candy mint
        (123, 200, 230),  # darker sky for contrast
    ),
]

FONT_CANDIDATES = [
    "/System/Library/Fonts/AppleSDGothicNeo.ttc",
    "/System/Library/Fonts/Supplemental/AppleGothic.ttf",
]

W, H = 1080, 1920
BANNER_H = 400  # top caption banner area in px


def load_font(size: int, bold: bool = True):
    for path in FONT_CANDIDATES:
        try:
            if path.endswith(".ttc"):
                # AppleSDGothicNeo.ttc has multiple faces; try Bold-ish indices.
                for face_idx in (8, 4, 2, 0) if bold else (4, 2, 0):
                    try:
                        return ImageFont.truetype(path, size, index=face_idx)
                    except Exception:
                        continue
            return ImageFont.truetype(path, size)
        except Exception:
            continue
    return ImageFont.load_default()


def draw_gradient_banner(img: Image.Image, top: tuple, bot: tuple, height: int):
    """Draw a vertical gradient banner over the top `height` px of img."""
    grad = Image.new("RGBA", (W, height), (0, 0, 0, 0))
    px = grad.load()
    for y in range(height):
        t = y / max(1, height - 1)
        r = int(top[0] * (1 - t) + bot[0] * t)
        g = int(top[1] * (1 - t) + bot[1] * t)
        b = int(top[2] * (1 - t) + bot[2] * t)
        # slight alpha fade at bottom edge for soft blend with screenshot
        a = 255 if y < height - 24 else int(255 * (height - y) / 24)
        for x in range(W):
            px[x, y] = (r, g, b, a)
    img.alpha_composite(grad, (0, 0))


def draw_text_centered(draw: ImageDraw.ImageDraw, y: int, text: str, font, fill, shadow):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    x = (W - tw) // 2 - bbox[0]
    # soft drop shadow (multi-layer for smoother look)
    for dx, dy, alpha in [(0, 6, 80), (4, 8, 60), (-3, 7, 60)]:
        draw.text((x + dx, y + dy), text, font=font,
                  fill=(shadow[0], shadow[1], shadow[2], alpha))
    draw.text((x, y), text, font=font, fill=fill)


def process(job):
    src_name, line1, line2, top, bot = job
    src = Image.open(ROOT / src_name).convert("RGBA")
    if src.size != (W, H):
        src = src.resize((W, H), Image.LANCZOS)
    out = src.copy()
    draw_gradient_banner(out, top, bot, BANNER_H)
    draw = ImageDraw.Draw(out)
    f1 = load_font(72, bold=True)
    f2 = load_font(120, bold=True)
    shadow = tuple(max(0, c - 90) for c in bot)
    # subtitle (small) above, headline (big) below
    draw_text_centered(draw, 110, line1, f1, (255, 255, 255, 255), shadow)
    draw_text_centered(draw, 215, line2, f2, (255, 255, 255, 255), shadow)
    out_path = OUT / src_name.replace(".png", "_mkt.png")
    out.convert("RGB").save(out_path, "PNG", optimize=True)
    print(f"✓ {out_path.name}  ({out_path.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    for job in JOBS:
        process(job)
    print("\nDone. Output dir:", OUT)
