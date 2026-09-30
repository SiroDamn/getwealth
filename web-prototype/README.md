# Reihum: Browser-Prototyp

Ein Prototyp zum Ausprobieren im Browser, damit sich der Ablauf schon vor dem ersten Xcode-Build testen und zeigen lässt (Phase 1 im Konzept). Er ersetzt die App nicht.

**Was er ist:** dieselbe Fairness-Logik wie in der App (`app/ReihumCore`), als JavaScript portiert, mit derselben Bedienung: Plan anlegen in vier Schritten, Abwesenheiten, Tausch, Teilen als Bild oder Text. Die Daten bleiben im Browser und werden nirgends hin gesendet.

**Was er nicht kann:** keine Kalenderdatei (.ics), keine lokalen Erinnerungen, kein Export/Import, keine Widgets. Das braucht die App.

## Dateien

| Pfad | Inhalt |
|---|---|
| `src/engine.js` | Datums-, Rhythmus- und Fairness-Logik, Zeile für Zeile aus Swift übernommen |
| `src/app.js`, `src/style.css`, `src/dark-tokens.css` | Oberfläche (Hell- und Dunkelmodus) |
| `build.mjs` | Baut `dist/artifact.html` (Fragment zum Veröffentlichen) und `dist/standalone.html` (zum lokalen Öffnen) |
| `test/scenarios.json`, `test/golden.json` | 13 gemeinsame Szenarien und die Referenzergebnisse, die **Swift** erzeugt hat |
| `test/engine.test.js` | Prüft, dass die JavaScript-Version alle Referenzergebnisse exakt trifft, plus Invarianten |
| `test/e2e.mjs` | Ablauftest im echten Browser (Chromium, iPhone-11-Pro-Grösse, Hell und Dunkel, gesperrter Speicher) |

## Befehle

```bash
node build.mjs                      # Seite bauen
node --test test/engine.test.js     # Logik gegen die Swift-Referenz prüfen
PLAYWRIGHT_MODULE=/pfad/zu/playwright node test/e2e.mjs [screenshot-ordner]
```

Referenzergebnisse neu erzeugen (nur, wenn sich die Swift-Logik absichtlich ändert):

```bash
cd ../app/ReihumCore && REIHUM_WRITE_GOLDEN=1 swift test --filter GoldenTests
```

Der Swift-Test `GoldenTests` und der JavaScript-Test lesen dieselben Dateien. Weicht eine Seite ab, schlägt der jeweilige Test fehl.
