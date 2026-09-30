#!/usr/bin/env python3
"""Checks docs/app-store/listing.de.json against Apple's limits and this project's rules.

Limits (App Store Connect Help, checked 30.09.2026): name and subtitle 30 characters, promotional text 170 characters,
description 4000 characters, keywords 100 BYTES (umlauts count twice), what's new 4000 characters, notes for review 4000 bytes.
Exit code 1 on a violation. Open placeholders are reported but do not fail the check.
"""
import json, re, sys, pathlib

path = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).with_name("listing.de.json")
data = json.loads(path.read_text(encoding="utf-8"))

LIMITS = {
    "name": ("chars", 30), "subtitle": ("chars", 30), "promotionalText": ("chars", 170), "description": ("chars", 4000),
    "keywords": ("bytes", 100), "whatsNew": ("chars", 4000), "notesForReview": ("bytes", 4000),
}
# Third-party brands must not appear in store metadata (Apple names such as iPhone or iCloud are fine).
BRANDS = ["whatsapp", "telegram", "signal", "threema", "google", "microsoft", "outlook", "excel", "facebook", "instagram", "slack", "teams", "doodle"]
# Claims this project cannot prove; also checked as whole words only.
CLAIMS = ["garantiert", "100 %", "100%", "nr. 1", "beste", "bester", "bestes", "sicher", "kostenlos", "gratis", "in unter"]

problems, notes = [], []
for field, (unit, limit) in LIMITS.items():
    value = data.get(field, "")
    size = len(value) if unit == "chars" else len(value.encode("utf-8"))
    status = "ok " if size <= limit else "TOO LONG"
    print(f"{status:9} {field:16} {size:5} / {limit} {unit}")
    if size > limit:
        problems.append(f"{field}: {size} {unit} > {limit}")
if len(data["name"]) < 2:
    problems.append("name shorter than 2 characters")

visible = " ".join(data[k] for k in ("name", "subtitle", "promotionalText", "description", "keywords", "whatsNew")).lower()
for word in BRANDS:
    if re.search(rf"\b{re.escape(word)}\b", visible):
        problems.append(f"third-party brand in metadata: {word}")
for claim in CLAIMS:
    if re.search(rf"(?<!\w){re.escape(claim)}(?!\w)", visible):
        problems.append(f"unverifiable or risky claim: '{claim}'")

kw = data["keywords"]
if ", " in kw or kw.startswith(",") or kw.endswith(","):
    problems.append("keywords: separate with commas only, no spaces")
used = set(re.findall(r"\w+", (data["name"] + " " + data["subtitle"]).lower()))
repeated = sorted({w for w in re.findall(r"\w+", kw.lower()) if w in used})
if repeated:
    problems.append("keywords repeat words from name or subtitle: " + ", ".join(repeated))
if len(set(k.lower() for k in kw.split(","))) != len(kw.split(",")):
    problems.append("keywords contain duplicates")

for field, value in data.items():
    if "[" in value:
        notes.append(f"OFFEN (placeholder): {field}")

for n in notes:
    print(n)
if problems:
    print("\nPROBLEMS:")
    for p in problems:
        print(" -", p)
    sys.exit(1)
print("\nlisting ok" + (" (with open placeholders)" if notes else ""))
