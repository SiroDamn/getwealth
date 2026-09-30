# Reihum: Prototyp einrichten (Xcode)

**Stand:** 29. September 2026. **Teststand:** Das Paket `ReihumCore` wurde mit Swift 6.1.3 unter Linux gebaut; alle 70 Unit-Tests bestehen (`swift test`). Die SwiftUI-Dateien in `app/Reihum/Sources` konnten unter Linux **nicht kompiliert** werden (SwiftUI und UIKit gibt es nur auf Apple-Plattformen); sie sind nur syntaktisch geprüft (`PlanStore` zusätzlich gegen das Kernmodul typgeprüft). Rechne beim ersten Öffnen in Xcode mit kleineren Korrekturen und melde Fehlermeldungen wörtlich zurück.

## Was hier liegt

| Ordner | Inhalt |
|---|---|
| `app/ReihumCore/` | Swift-Paket ohne UI: Kalendertage (`DayDate`), Rhythmen, Fairness-Engine, Kalender- und Text-Export, lokale Speicherung (`PlanStore`), Validierung und Sicherungsformat, Unit-Tests. Läuft auf macOS, iOS und Linux. |
| `app/Reihum/Sources/` | SwiftUI-Screens der App (S1 bis S11 aus dem Konzept), lokale JSON-Speicherung, Erinnerungen, Teilen. |
| `app/Reihum/Resources/PrivacyInfo.xcprivacy` | Privacy Manifest: kein Tracking, keine Datenerhebung. |

## Voraussetzungen

- Mac mit aktuellem Xcode aus dem Mac App Store (iOS-18-SDK oder neuer).
- iPhone 11 Pro mit iOS 18 oder neuer, Entwicklermodus aktiviert (Einstellungen → Datenschutz & Sicherheit → Entwicklermodus).
- Ein Apple-Account. Für Tests auf dem eigenen Gerät genügt das kostenlose «Personal Team» (Apps laufen dann 7 Tage, danach neu installieren). Das kostenpflichtige Developer Program ist erst für TestFlight und App Store nötig.

## 1. Tests des Kerns ausführen (5 Minuten, ohne Xcode-Projekt)

```bash
cd app/ReihumCore
swift test
```

Erwartung: Alle Tests grün. Falls nicht, Ausgabe kopieren und zurückmelden.

## 2. Xcode-Projekt anlegen (10 Minuten)

1. Xcode → **File → New → Project → iOS → App**.
   - Product Name: `Reihum`
   - Team: dein Personal Team
   - Organization Identifier: z. B. `ch.deinname` (ergibt die Bundle-ID `ch.deinname.Reihum`; später änderbar)
   - Interface: **SwiftUI**, Language: **Swift**, Storage: **None**, Tests: optional
   - Speicherort: **ausserhalb** dieses Repositories oder in `app/ReihumXcode/` (dann in `.gitignore` aufnehmen, falls du das Projekt nicht versionieren willst; die Quellen bleiben ohnehin in `app/Reihum/Sources`).
2. Im Projekt-Navigator die automatisch erzeugten Dateien `ContentView.swift` und `ReihumApp.swift` **löschen** (Move to Trash).
3. **Quellen hinzufügen:** Ordner `app/Reihum/Sources` aus dem Finder in den Projekt-Navigator ziehen. Im Dialog: «Copy items if needed» **aus**, «Create groups», Target `Reihum` **angehakt**. So bleiben die Dateien im Repository und Änderungen sind versionierbar.
4. **Privacy Manifest hinzufügen:** `app/Reihum/Resources/PrivacyInfo.xcprivacy` ebenso hineinziehen, Target `Reihum` angehakt.
5. **Kern-Paket einbinden:** Projekt auswählen → Target `Reihum` → Tab **General** → **Frameworks, Libraries, and Embedded Content** → «+» → **Add Other… → Add Package Dependency… → Add Local…** → Ordner `app/ReihumCore` wählen → Produkt `ReihumCore` dem Target hinzufügen.
6. **Deployment Target:** Target `Reihum` → General → Minimum Deployments → **iOS 18.0**.
7. **Signing:** Tab Signing & Capabilities → «Automatically manage signing» an, Team wählen.
8. iPhone per Kabel verbinden, als Ziel wählen, **Run** (⌘R). Beim ersten Start auf dem iPhone: Einstellungen → Allgemein → VPN & Geräteverwaltung → Entwickler-App vertrauen.

## 3. Was du im Prototyp prüfen kannst

- Plan anlegen (4 Schritte), Plan-Ansicht, Fairness-Zeile, offene Termine.
- Personen bearbeiten, Abwesenheiten, Anteil ½/1/2, deaktivieren.
- Termin bearbeiten: manuelle Zuweisung, überspringen, Notiz, Tausch.
- Neu berechnen (mit und ohne manuelle Termine).
- Teilen: Bild (hell/dunkel), Text, Kalenderdatei gesamt oder pro Person. Kalenderdatei in Apple Kalender, Google Kalender und Outlook importieren und prüfen.
- Einstellungen: Erinnerungen (Berechtigung erlauben und verweigern), Export/Import JSON, Alle Daten löschen.
- Beispielplan aus dem leeren Zustand.
- Flugmodus einschalten: Alles muss weiterhin funktionieren.

## 4. Bekannte Platzhalter und Grenzen des Prototyps

- Datenschutz- und Impressumstexte sind **Entwürfe** mit eckigen Klammern; in der App sichtbar als «Entwurf» markiert. Vor jeder Weitergabe an Dritte (auch TestFlight) mindestens Name und Kontakt eintragen.
- Kein App-Icon enthalten. Ein eigenes Icon muss gestaltet werden; **kein SF Symbol** als Icon verwenden.
- Nur Deutsch. Texte liegen als Literale im Code; für FR/IT/EN später in einen String-Katalog überführen.
- Persistenz: eine JSON-Datei mit Schema-Version, atomar geschrieben, im Kernpaket getestet. Eine unlesbare oder neuere Datei wird beiseitegelegt statt überschrieben, Import ist alles-oder-nichts mit Grössen- und Inhaltsprüfung. Empfehlung: für das MVP dabei bleiben (einfach, testbar, portabel).
- Keine Widgets, keine Feiertage, kein Sync, keine Käufe (bewusst, siehe Konzept 5.6).
- Der `CA92.1`-Begründungscode im Privacy Manifest muss vor der Einreichung gegen die aktuelle Apple-Dokumentation geprüft werden.

## 5. Wenn etwas nicht baut

**Bekannte Stelle bei neuen Xcode-Projekten:** Je nach Xcode-Version steht im Build Setting *Default Actor Isolation* der Wert *MainActor*. Dann können Meldungen zu «main actor-isolated» bei `ReminderManager` und `Fmt` erscheinen. Abhilfe: Build Setting auf *nonisolated* stellen, oder die Meldung wörtlich zurückmelden.

Xcode-Fehlermeldung (Datei, Zeile, Text) wörtlich zurückmelden. Häufige Ursachen bei ungetestetem Code: fehlende `import`-Zeile, ein veralteter API-Name, ein Typ, der `Identifiable` oder `Hashable` sein muss. Diese Korrekturen sind klein.
