import json, sys
from pathlib import Path
from PIL import Image
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).parent
STK = ROOT / "stk"
OUT = ROOT / "out"
OUT.mkdir(exist_ok=True)

COPY = {
    "en": ("Learn bartending &amp; mixology", '100+ classics.<br><span class="hl"><span>Made right.</span></span>'),
    "it": ("Impara bartending e mixology", '100+ classici.<br><span class="hl"><span>Fatti bene.</span></span>'),
    "fr": ("Apprenez bar et mixologie", '100+ classiques.<br><span class="hl"><span>Bien faits.</span></span>'),
    "de": ("Barwissen und Mixology lernen", '100+ Klassiker.<br><span class="hl"><span>Richtig gemixt.</span></span>'),
    "es": ("Aprende bartending y mixología", '100+ clásicos.<br><span class="hl"><span>Bien hechos.</span></span>'),
}

# (sticker, x offset as fraction of H, target height as fraction of H, rotation, z)
LINEUP = [
    ("mojito",           -0.86, .37, -5, 1),
    ("margarita",        -0.45, .36, -2, 2),
    ("negroni",           0.00, .40,  0, 3),
    ("espresso-martini",  0.45, .36,  2, 2),
    ("aperol-spritz",     0.86, .40,  5, 1),
]

def drinks(H, scale=1.0, spread=1.0):
    out = []
    for name, x, h, rot, z in LINEUP:
        p = STK / f"drinko-{name}.png"
        iw, ih = Image.open(p).size
        th = h * H * scale
        out.append({"src": p.as_uri(), "x": x * H * spread * scale, "w": th * iw / ih, "rot": rot, "z": z})
    return out

def render(page, w, h, lang, layout, name):
    eyebrow, title = COPY[lang]
    if layout == "21x9":
        css = {"w": f"{w}px", "h": f"{h}px", "headTop": f"{h*.085}px", "eyebrow": f"{h*.026}px",
               "title": f"{h*.112}px", "stageBottom": f"{h*.10}px", "shelfW": f"{h*2.3}px"}
        d = drinks(h, scale=1.04, spread=.82)
    elif layout == "3x2":
        css = {"w": f"{w}px", "h": f"{h}px", "headTop": f"{h*.10}px", "eyebrow": f"{h*.026}px",
               "title": f"{h*.125}px", "stageBottom": f"{h*.10}px", "shelfW": f"{h*1.4}px"}
        d = drinks(h, scale=.92, spread=.66)
    else:  # 16:9
        css = {"w": f"{w}px", "h": f"{h}px", "headTop": f"{h*.11}px", "eyebrow": f"{h*.024}px",
               "title": f"{h*.11}px", "stageBottom": f"{h*.11}px", "shelfW": f"{h*2.0}px"}
        d = drinks(h, scale=1.05, spread=.78)
    params = {"w": w, "h": h, "css": css, "eyebrow": eyebrow, "title": title, "drinks": d,
              "bubbles": int(70 * w / 3840)}
    page.set_viewport_size({"width": w, "height": h})
    page.add_init_script(f"window.PARAMS = {json.dumps(params)};")
    page.goto((ROOT / "header.html").as_uri())
    page.wait_for_load_state("networkidle")
    page.evaluate("document.fonts.ready")
    tmp = OUT / "_tmp.png"
    page.screenshot(path=str(tmp), full_page=False)
    Image.open(tmp).convert("RGB").save(OUT / name, optimize=True)  # strip alpha per App Store spec
    tmp.unlink()

LAYOUTS = {"21x9": (3840, 1646), "16x9": (5244, 2950), "3x2": (3840, 2560)}

if __name__ == "__main__":
    import os
    if os.environ.get("LAYOUT"):
        LAYOUTS = {os.environ["LAYOUT"]: LAYOUTS[os.environ["LAYOUT"]]}
    langs = sys.argv[1:] or list(COPY)
    with sync_playwright() as p:
        b = p.chromium.launch()
        for lang in langs:
            for layout, (w, h) in LAYOUTS.items():
                pg = b.new_page()
                render(pg, w, h, lang, layout, f"drinko-header-{layout}-{lang}.png")
                pg.close()
                print("ok", lang, layout)
        b.close()
