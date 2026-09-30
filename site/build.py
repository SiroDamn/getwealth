#!/usr/bin/env python3
"""Generates site/datenschutz.html and site/impressum.html from the texts inside the app (LegalViews.swift),
so the website and the in-app screens can never drift apart. site/index.html (support) is written by hand.

  python3 site/build.py            draft build: placeholders in [square brackets] stay, a draft banner is shown
  python3 site/build.py --publish  refuses to build while any [placeholder] is left; no banner
"""
import html, pathlib, re, sys

root = pathlib.Path(__file__).resolve().parent
swift = (root.parent / "app/Reihum/Sources/LegalViews.swift").read_text(encoding="utf-8")
publish = "--publish" in sys.argv

SECTION = re.compile(r'LegalSection\("((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)')
TITLE = re.compile(r'Text\("((?:[^"\\]|\\.)*)"\)\.font\(\.title2\.bold\(\)\)')
STAND = re.compile(r'Text\("(Stand: [^"]*)"\)')

def unescape(s: str) -> str:
    return s.replace("\\n", "\n").replace('\\"', '"').replace("\\\\", "\\")

def segment(name: str, next_name: str) -> str:
    start = swift.index(f"struct {name}: View")
    end = swift.index(f"struct {next_name}", start)
    return swift[start:end]

def page(title: str, body: str) -> str:
    banner = "" if publish else '<p class="draft">Entwurf. Platzhalter in [eckigen Klammern] vor der Veröffentlichung ersetzen und Text juristisch prüfen lassen.</p>'
    return f"""<!doctype html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)} – Reihum</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<main>
{banner}
{body}
<nav class="foot"><a href="index.html">Support</a> · <a href="datenschutz.html">Datenschutz</a> · <a href="impressum.html">Impressum</a></nav>
</main>
</body>
</html>
"""

def render(view: str, following: str, minimum: int) -> tuple[str, str]:
    seg = segment(view, following)
    title = unescape(TITLE.search(seg).group(1))
    sections = [(unescape(a), unescape(b)) for a, b in SECTION.findall(seg)]
    if len(sections) < minimum:
        sys.exit(f"{view}: found only {len(sections)} sections, expected at least {minimum}; did LegalViews.swift change shape?")
    stand = STAND.search(seg)
    parts = [f"<h1>{html.escape(title)}</h1>"]
    if stand:
        parts.append(f'<p class="meta">{html.escape(unescape(stand.group(1)))}</p>')
    for heading, text in sections:
        parts.append(f"<h2>{html.escape(heading)}</h2>\n<p>{html.escape(text).replace(chr(10), '<br>')}</p>")
    return title, "\n".join(parts)

outputs = {
    "datenschutz.html": render("PrivacyView", "ImpressumView", 9),
    "impressum.html": render("ImpressumView", "LicensesView", 4),
}
left = []
for name, (title, body) in outputs.items():
    left += [f"{name}: {p}" for p in re.findall(r"\[[^\]]+\]", body)]
if publish and left:
    sys.exit("Placeholders left, not publishing:\n  " + "\n  ".join(sorted(set(left))))
for name, (title, body) in outputs.items():
    (root / name).write_text(page(title, body), encoding="utf-8")
    print("wrote", name)
if left:
    print("open placeholders:", ", ".join(sorted({p.split(': ', 1)[1] for p in left})))
