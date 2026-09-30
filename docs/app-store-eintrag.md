# App-Store-Eintrag: Entwurf und Prüfliste

**Stand:** 30. September 2026. **Nur relevant, wenn die Problemvalidierung (Phase 0) und der Prototypentest (Phase 1) positiv ausfallen.**
Kennzeichnung wie im Konzept: **[Belegt]** an der Apple-Seite geprüft, **[Einschätzung]** fachliche Einschätzung, **[Offen]** noch zu prüfen.

## 1. Texte

Die Texte stehen in `docs/app-store/listing.de.json`. Der Prüfer kontrolliert Längen, Fremdmarken und nicht belegbare Werbeaussagen:

```bash
python3 docs/app-store/check-listing.py
```

| Feld | Limit | Status |
|---|---|---|
| Name, Untertitel | je 30 Zeichen | [Belegt] |
| Werbetext | 170 Zeichen | [Belegt] |
| Beschreibung | 4000 Zeichen | [Belegt] |
| Schlüsselwörter | 100 **Byte** (Umlaute zählen doppelt) | [Belegt] |
| Neuerungen | 4000 Zeichen | [Belegt] |
| Hinweise für die Prüfung | 4000 Byte | [Belegt] |

Jede Aussage in der Beschreibung entspricht einer vorhandenen Funktion. Bewusst **nicht** enthalten: «in unter einer Minute» (noch nicht gemessen), «sicher», «garantiert fair», Namen von Chat-Diensten. Wird eine Funktion geändert, muss der Text mitgeändert werden (Apple 2.3 [Belegt]).

## 2. Weitere Angaben

| Angabe | Vorschlag | Status |
|---|---|---|
| Kategorie | primär Produktivität, sekundär Dienstprogramme | [Einschätzung] |
| Altersfreigabe | Fragebogen wahrheitsgemäss beantworten: keine Inhalte, kein Web-Zugriff, keine nutzergenerierten Inhalte, keine Nachrichten, keine Werbung, keine Käufe. Erwartet: 4+. Stufen 4+, 9+, 13+, 16+, 18+ [Belegt]; der Fragebogen wurde 2025 erneuert, die Fragen also in App Store Connect neu lesen | [Einschätzung] |
| App-Datenschutz | «Daten werden nicht erfasst». Auf dem Gerät verarbeitete Daten gelten nicht als erhoben [Belegt]. Gilt nur, solange die App keinen Netzwerkcode enthält und keine Drittanbieter-SDKs | [Belegt], Voraussetzung prüfbar |
| Datenschutz-URL | Seite `site/datenschutz.html` unter einer eigenen Adresse. Pflicht in App Store Connect und in der App [Belegt] | [Offen]: Adresse fehlt |
| Support-URL | Seite `site/index.html`. Pflicht, muss zu Kontaktinformationen führen [Belegt] | [Offen]: Adresse fehlt |
| Kontakt für die App-Prüfung | Name, E-Mail und Telefonnummer im internationalen Format (+41 …) sind Pflichtfelder [Belegt]. Ob und wo sie sichtbar sind, in App Store Connect prüfen | [Offen] |
| Preis, Verfügbarkeit | kostenlos, nur Schweiz (Annahme A3) | Entscheid liegt vor |
| Exportvorschriften | Info.plist-Schlüssel `ITSAppUsesNonExemptEncryption` auf `NO`, weil die App keine eigene Verschlüsselung und keine Netzwerkverbindung hat. Die Apple-Seite liess sich nicht auslesen | [Offen] |
| Copyright | «2026 Vorname Nachname» | Platzhalter |

## 3. Symbol und Screenshots

**Symbol:** `app/Reihum/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`, 1024 × 1024, RGB ohne Alpha, eigene Gestaltung (Quelle `design/app-icon.svg`, erzeugt mit `design/render-icon.mjs`). Keine Rundung einzeichnen, iOS maskiert selbst. Die Anforderungen der Apple-Seite liessen sich nicht auslesen, die Ausführung folgt der üblichen Vorgabe. [Offen]

**Screenshots** [Belegt]: mindestens 1, höchstens 10, PNG oder JPEG, **ohne Alpha-Kanal**. Pflicht ist entweder 6.9 Zoll (1260 × 2736 hochkant) oder 6.5 Zoll (1284 × 2778 oder 1242 × 2688).
Das iPhone 11 Pro liefert 1125 × 2436 und passt damit **nicht** direkt [Einschätzung, aus den Pflichtgrössen abgeleitet]. Screenshots deshalb im Xcode-Simulator mit einem 6.9-Zoll-Gerät aufnehmen.

Vorschlag für fünf Bilder, jeweils mit erfundenen Beispielnamen, ohne Fremdmarken:
1. Fertiger Plan mit Fairness-Zeile.
2. Teilen als Bild.
3. Abwesenheit eintragen.
4. Rhythmen zur Auswahl.
5. Kalenderexport.

## 4. Ablauf vor «Zur Prüfung einreichen»

1. `python3 docs/app-store/check-listing.py` läuft ohne Fehler.
2. Alle Platzhalter ersetzt: Copyright, Datenschutz- und Impressumstexte, URLs, Kontaktdaten.
3. Datenschutz-Label und Altersfragebogen ausgefüllt.
4. Netzwerkmitschnitt und Code-Suche bestätigen: keine Verbindung (Konzept 10.2).
5. Namens- und Markenprüfung abgeschlossen (Konzept O3).
6. App Review Guidelines am Einreichungstag erneut gelesen (Konzept O6).
7. Juristische Kurzprüfung der Texte erfolgt (Konzept O2).
