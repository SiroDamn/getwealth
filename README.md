# getwealth

Arbeitsverzeichnis für Produkt- und Risikokonzepte.

## Inhalt

- `docs/iphone-app-konzept-reihum.md` – Vollständiges, prüfbares Konzept für eine risikoarme iPhone-App («Reihum – Wer ist dran?», Arbeitstitel): Ideenvergleich, Auswahl, Produktkonzept, Screens, Architektur, Risikoanalyse, Entwicklungsphasen, App-Store-Checkliste und Go-/No-Go-Einschätzung. Stand 29.09.2026. Keine Rechtsberatung, keine Veröffentlichung.
- `docs/leitfaden-problemvalidierung.md` – Gesprächsleitfaden für Phase 0 (5 bis 8 Gespräche mit Organisierenden) inkl. Auswertungsraster und Entscheidungsregel.
- `app/` – Prototyp-Code: Swift-Paket `ReihumCore` (Fairness-Engine, Rhythmen, Kalender-Export, Tests) und SwiftUI-Screens in `app/Reihum/Sources`. Einrichtung in `app/SETUP.md`. Der Kern ist unter Linux gebaut und getestet (69 Tests bestanden); die SwiftUI-Screens sind nur syntaktisch geprüft und müssen auf einem Mac gebaut werden.
