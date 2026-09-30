# getwealth

Arbeitsverzeichnis für Produkt- und Risikokonzepte.

## Inhalt

- `docs/iphone-app-konzept-reihum.md` – Vollständiges, prüfbares Konzept für eine risikoarme iPhone-App («Reihum – Wer ist dran?», Arbeitstitel): Ideenvergleich, Auswahl, Produktkonzept, Screens, Architektur, Risikoanalyse, Entwicklungsphasen, App-Store-Checkliste und Go-/No-Go-Einschätzung. Stand 29.09.2026. Keine Rechtsberatung, keine Veröffentlichung.
- `docs/leitfaden-problemvalidierung.md` – Gesprächsleitfaden für Phase 0 (5 bis 8 Gespräche mit Organisierenden) inkl. Auswertungsraster und Entscheidungsregel.
- `app/` – Prototyp-Code: Swift-Paket `ReihumCore` (Fairness-Engine, Rhythmen, Kalender-Export, Tests) und SwiftUI-Screens in `app/Reihum/Sources`. Einrichtung in `app/SETUP.md`. Der Kern ist unter Linux gebaut und getestet (70 Tests bestanden); die SwiftUI-Screens sind nur syntaktisch geprüft und müssen auf einem Mac gebaut werden.
- `docs/app-store-eintrag.md`, `docs/app-store/` – Entwurf des App-Store-Eintrags (Texte mit Prüfskript für Limits, Fremdmarken und nicht belegbare Aussagen) und Prüfliste vor der Einreichung.
- `site/` – Support-, Datenschutz- und Impressumsseite (Entwurf). Datenschutz und Impressum werden mit `python3 site/build.py` aus den Texten der App erzeugt; `--publish` verweigert den Bau, solange Platzhalter offen sind.
- `design/` – Quelle des App-Symbols (SVG) und Skript, das daraus ein PNG ohne Alpha-Kanal erzeugt.
- `web-prototype/` – Browser-Prototyp zum Ausprobieren ohne Mac: gleiche Fairness-Logik (gegen die Swift-Referenz geprüft), gleicher Ablauf, Hell- und Dunkelmodus. Anleitung in `web-prototype/README.md`.
