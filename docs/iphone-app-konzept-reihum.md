# iPhone-App-Konzept: «Reihum – Wer ist dran?» (Arbeitstitel)

**Stand:** 29. September 2026
**Status:** Vollständig prüfbares Konzept. Keine Veröffentlichung, keine kostenpflichtigen Verpflichtungen, keine Rechtsfreigabe.
**Erstellt von:** Konzeptteam (iOS-Entwicklung, Produktdesign, App-Store, Sicherheit, Datenschutz, Wachstum, juristische Risikoanalyse) im Auftrag des Projektinhabers
**Zielmarkt der ersten Version:** ausschliesslich Schweiz

> **Wichtigster Hinweis vorab:** Dieses Dokument ist eine Risiko- und Produktanalyse, keine Rechtsberatung. Kein App-Design kann eine unbegründete Beschwerde, Abmahnung oder Klage ausschliessen. Alle als **[Offen]** markierten Punkte müssen vor einer Veröffentlichung durch dich selbst an der Primärquelle oder durch eine qualifizierte Fachperson geprüft werden.

---

## Kurzfassung

- **Gewählte Idee:** eine lokale iPhone-App, die faire Turnuspläne («Wer ist dran?») für kleine Gruppen erstellt: Znüni-Dienst im Team, Putzplan in der WG, Elterndienst in Kita und Schule, Ämtli in der Familie, Kuchen- oder Fahrdienst im Verein. Der Plan wird als Bild, Text oder Kalenderdatei (.ics) geteilt. Empfangende brauchen die App nicht.
- **Warum diese Idee:** Sie kommt ohne Konto, ohne Server, ohne Standort, ohne Kamera, ohne fremde Inhalte und ohne nutzergenerierte öffentliche Inhalte aus. Damit entfallen die Risikoklassen, die bei einem Einzelprojekt am gefährlichsten sind (Datenpannen, Moderation, Haftung für Inhalte Dritter, regulierte Tätigkeiten). Gleichzeitig entsteht bei jeder Nutzung ein Artefakt, das freiwillig an mehrere Personen geht.
- **Ehrliche Einordnung des Wachstumspotenzials:** Alle Mechanismen mit «eingebauter» Viralität (geteilter Zustand, soziale Graphen, öffentliche Inhalte) bringen genau die Risiken, die du ausschliessen willst. Die gewählte Idee hat ein gutes, aber kein garantiertes Wachstumspotenzial. Ein «sicher viral» gibt es nicht.
- **Go-/No-Go:** **Go** für Prototyp und MVP. **No-Go für die Veröffentlichung**, bis die in Abschnitt 12 genannten offenen Punkte geklärt sind (insbesondere Namens- und Markenprüfung, Primärquellen-Prüfung der Schweizer Gesetzestexte, juristische Kurzprüfung von Datenschutzerklärung und Impressum).

---

## 1. Annahmen und überprüfte Quellen mit Datum

### 1.1 Annahmen (konservativ, ausdrücklich gekennzeichnet)

| Nr. | Annahme | Begründung / Konsequenz |
|---|---|---|
| A1 | Du veröffentlichst als **Einzelperson** im Apple Developer Program, ohne Firma, Versicherung oder Rechtsabteilung. **Bestätigt am 29.09.2026.** | Dein bürgerlicher Name erscheint als Anbietername im App Store. Es gibt keine Haftungsabschirmung durch eine juristische Person. |
| A2 | Budget: klein. Vorhanden oder beschaffbar: ein Mac mit aktuellem Xcode, ein iPhone zum Testen. **Stand 29.09.2026: Testgerät iPhone 11 Pro vorhanden; Mac noch offen.** | Wenn kein Mac vorhanden ist, entstehen zusätzliche Kosten; Cloud-Macs sind möglich, aber nicht eingeplant. |
| A3 | Erste Veröffentlichung nur im **Schweizer App Store**. EU, USA und weitere Länder werden separat geprüft (Abschnitt 11). | Vermeidet vorerst EU-DSA-Händlerpflichten, DSGVO-Vertretungsfragen und US-Verbraucherrecht. |
| A4 | **Keine Datenerhebung** durch dich: kein Backend, keine Analyse-SDKs, keine Werbung, keine Konten. | Die App kann im App Store mit «Daten werden nicht erfasst» deklariert werden, sofern das im Code tatsächlich so umgesetzt wird. |
| A5 | Erste Version **kostenlos ohne Käufe**. Monetarisierung wird erst nach der Validierung entschieden. | Reduziert Verbraucherschutz- und Steuerfragen in der ersten Phase. Wenn du später Käufe einbaust, gelten die in Abschnitt 5.11 genannten Auflagen. |
| A6 | Sprache der ersten Version: Deutsch, mit vorbereiteter Lokalisierung für Französisch, Italienisch und Englisch. **Entschieden am 29.09.2026: nur Deutsch zum Start.** | Die Schweiz ist mehrsprachig; eine Nur-Deutsch-Version schliesst rund einen Viertel der Bevölkerung aus. Lokalisierung ist eine Aufwands-, keine Rechtsfrage. |
| A7 | Du bist in der Schweiz steuerpflichtig. Einnahmen aus einer App (falls später) sind Einkommen. | Steuerliche Beurteilung durch eine Fachperson, sobald Einnahmen geplant sind. |
| A8 | Du hast keine bestehende Marke, Domain oder Firma für die App. | Namenswahl unter Vorbehalt einer Markenrecherche (Swissreg, EUIPO, WIPO) und Verfügbarkeitsprüfung. |

### 1.2 Überprüfte Quellen (Prüfdatum: 29.09.2026)

Kennzeichnung: **[Belegt]** = Originalseite abgerufen und Inhalt geprüft. **[Sekundär]** = nur über Suchergebnisse oder Drittseiten belegt, Primärquelle noch nicht abgerufen. **[Offen]** = Prüfung nicht möglich, muss vor Veröffentlichung nachgeholt werden.

| Quelle | Was geprüft wurde | Ergebnis (Kurzfassung) | Status |
|---|---|---|---|
| Apple App Review Guidelines, developer.apple.com/app-store/review/guidelines | Abschnitte 2.1 (Vollständigkeit), 2.3/2.3.1 (Metadaten), 3.1.1 (In-App-Kauf), 4.2 (Minimalfunktion), 4.2.6 (Template-Apps), 4.3(b) (Spam/Klone), 5.1.1 (i)–(v) (Datenschutzerklärung, Einwilligung, Datenminimierung, Konten), 5.1.2 (i) (Datennutzung), 1.4.1 (physischer Schaden) | Jede App braucht einen Link zur Datenschutzerklärung in App Store Connect **und** in der App. Funktionen freischalten nur via In-App-Kauf. Apps sollen nur Daten anfordern, die für die Kernfunktion nötig sind, und wo möglich Picker oder Share Sheet statt Vollzugriff nutzen. Konten dürfen nicht verlangt werden, wenn keine kontobasierten Funktionen bestehen. Apps, die «indistinguishable from what's already widely available» sind, gelten als Spam. Kein «zuletzt aktualisiert»-Datum auf der Seite sichtbar. | [Belegt] |
| Apple Developer Program Enrollment, developer.apple.com/programs/enroll | Einzelpersonen vs. Organisationen, Gebühr, Anzeigename | Einzelpersonen können sich anmelden (volljährig, Apple-Account mit Zwei-Faktor-Authentifizierung, bürgerlicher Name, Adresse ohne Postfach). Gebühr 99 USD pro Mitgliedsjahr, regional in Landeswährung. Bei Einzelpersonen wird der **bürgerliche Name als Verkäufername** angezeigt. Keine D-U-N-S-Nummer nötig. | [Belegt] |
| Apple App Privacy Details, developer.apple.com/app-store/app-privacy-details | Datenschutz-Label («Nutrition Label») | Alle vom Entwickler oder von Drittanbieter-SDKs erhobenen Daten sind zu deklarieren. **Daten, die nur auf dem Gerät verarbeitet werden, gelten nicht als «erhoben»** und müssen nicht deklariert werden. Der Entwickler trägt die Verantwortung für die Richtigkeit; Antworten können ohne App-Update geändert werden. | [Belegt] |
| Apple App Store Connect Hilfe, Altersfreigaben | Aktuelle Stufen und Verfahren | Stufen 4+, 9+, 13+, 16+, 18+. Ermittlung per Fragebogen (u. a. In-App-Kontrollen, Fähigkeiten wie Web-Zugriff/UGC/Messaging/Werbung, Medizin/Wellness, Glücksspiel). | [Belegt] |
| Apple Developer News «Updated age ratings in App Store Connect» (24.07.2025) | Übergangsfrist | Neue Stufen 13+/16+/18+; erweiterter Fragebogen; Antworten für bestehende Apps waren bis 31.01.2026 fällig. Für eine neue App ist der neue Fragebogen ohnehin Pflicht. | [Belegt] |
| Apple App Store Connect Hilfe, EU Digital Services Act Händlerpflichten | Was bei EU-Vertrieb gilt | Gilt nur für Vertrieb in EU-Storefronts. Wer «Händler» ist (u. a. Einnahmen aus Käufen), muss Adresse (oder Postfach), Telefonnummer und E-Mail hinterlegen; diese werden **öffentlich auf der Produktseite** angezeigt. Verifizierung per Dokumenten-Upload. Nicht-Händler: Konsumenten werden informiert, dass Verbraucherrechte nicht gelten. | [Belegt] |
| Apple App Store Small Business Program | Provision | 15 % statt 30 % Provision für Entwickler mit bis zu 1 Mio. USD Erlös im Vorjahr; neue Entwickler sind berechtigt; Anmeldung in App Store Connect nach Annahme des Paid Apps Agreement. | [Belegt] |
| Apple Developer Support «Changes for apps in the European Union» | EU-Geschäftsbedingungen 2026 | Aktualisiertes Lizenzabkommen vom 18.08.2026, neue einheitliche Bedingungen ab 01.10.2026. Entwickler, die **ausschliesslich den App Store mit Apple In-App-Kauf** nutzen, sind laut Apple nicht betroffen. EU-Provision für In-App-Kauf 26 % Standard, 15 % im Small Business Program. Core Technology Commission 5 % nur bei alternativer Distribution. | [Belegt] |
| Apple Developer Documentation, Privacy Manifest / Required Reason API | Pflichtangaben in PrivacyInfo.xcprivacy | Das Werkzeug konnte den vollständigen Seiteninhalt nicht laden; die Zusammenfassung basiert teilweise auf Vorwissen: Apps müssen für bestimmte APIs (u. a. UserDefaults, Datei-Zeitstempel, Boot-Zeit, Speicherplatz, aktive Tastaturen) einen Begründungscode angeben, Tracking-Domains deklarieren und erhobene Datentypen auflisten. | [Sekundär] – vor Einreichung direkt in der Apple-Dokumentation prüfen |
| SF Symbols Lizenzbedingungen | Nutzung von SF Symbols als App-Icon | Die öffentliche SF-Symbols-Seite enthält die Beschränkungen nicht. Aus dem Lizenztext (Xcode/SF Symbols Agreement) ist bekannt, dass Symbole nur in Apps für Apple-Plattformen und **nicht als App-Icon, Logo oder Marke** verwendet werden dürfen. | [Sekundär] – Lizenztext in Xcode prüfen |
| iOS-Versionsstand | Aktuelle iOS-Version für Zielplattform | Laut Medienberichten (MacRumors, AppleInsider) wurde iOS 27 am 14.09.2026 veröffentlicht; unterstützt werden dieselben Geräte wie iOS 26 (ab iPhone 11). | [Sekundär] |
| Bundesgesetz über den Datenschutz (DSG, SR 235.1), fedlex.admin.ch | Art. 2 Abs. 2 lit. a (persönlicher Gebrauch), Art. 7 (Datenschutz durch Technik), Art. 19 (Informationspflicht), Art. 25 (Auskunft), Art. 60 ff. (Strafbestimmungen) | **Fedlex war aus dieser Umgebung nicht erreichbar (Netzwerk-Sperre).** Über Sekundärquellen (onlinekommentar.ch, datenschutz.law, activemind.ch, EDÖB-Seiten in Suchergebnissen) belegt: Das DSG gilt nicht für Personendaten, die eine natürliche Person ausschliesslich zum persönlichen Gebrauch bearbeitet. Die Informationspflicht verlangt Angaben zu Identität/Kontakt des Verantwortlichen, Bearbeitungszweck, Datenkategorien, Empfängerkategorien, Auslandbekanntgabe. Vorsätzliche Verletzung der Informationspflicht kann mit Busse bis CHF 250 000 bestraft werden (gegen die verantwortliche natürliche Person). | [Sekundär] / Primärprüfung [Offen] |
| Bundesgesetz gegen den unlauteren Wettbewerb (UWG, SR 241), Art. 3 Abs. 1 lit. s | Impressumspflicht im elektronischen Geschäftsverkehr | Fedlex nicht erreichbar. Sekundärquellen (cyon.ch, steigerlegal.ch, activemind.ch, it-recht-kanzlei.de): Wer im elektronischen Geschäftsverkehr Angaben zu Identität und Kontaktadresse unterlässt oder unvollständig macht, handelt unlauter. Mindestangaben: Name, Postadresse, E-Mail. Ob eine **kostenlose App ohne Werbung** darunter fällt, ist umstritten; konservative Annahme: Impressum trotzdem bereitstellen. | [Sekundär] / Primärprüfung [Offen] |
| EDÖB (Eidgenössischer Datenschutz- und Öffentlichkeitsbeauftragter), edoeb.admin.ch | Merkblätter zur Informationspflicht und zu Datenschutzerklärungen | Seite nicht erreichbar (Netzwerk-Sperre). Die Suchergebnisse nennen die Seiten «Informationspflicht» und «Datenschutzerklärungen im Internet» auf edoeb.admin.ch. | [Offen] |
| App-Store-Wettbewerbsprüfung (apps.apple.com, Websuche) | Bestehende Apps zu den Kandidatenideen | Wohnungsübergabe: mehrere Schweizer Apps (wohnungsapp.ch, «Wohnungsübergabe», HEV-Wohnungsprotokoll-App, wwimmo Abnahme-App) und eine deutsche App mit dem Namen «Übergabe». Kündigungsfristen: «Contract – Verträge & Abos» (im CH-Store), aboalarm, Volders (DE-Dienste). Turnus-/Dienstpläne: vor allem B2B-Dienstplan-Apps (Papershift Plan, MeinDienstplan) und Haushalts-Putzplan-Apps mit Konten und Sync. Eine kontofreie, organisatorzentrierte Turnusplan-App mit Kalenderexport wurde nicht gefunden (keine Garantie auf Vollständigkeit). | [Belegt] für die gefundenen Treffer; Vollständigkeit [Offen] |
| Bundesamt für Statistik (Umzugsstatistik), Mieterinnen- und Mieterverband | Marktgrössen, Empfehlungen zur Wohnungsübergabe | Nicht erreichbar. Wurden nach der Herabstufung der Übergabe-Idee nicht mehr benötigt. | [Offen], nicht mehr relevant |

### 1.3 Nicht verifizierbare Punkte und Umgang damit

- Alle **Schweizer Gesetzestexte** konnten nicht an der Primärquelle geprüft werden. Ich stütze mich auf Sekundärquellen und kennzeichne dies. Vor einer Veröffentlichung musst du DSG Art. 2, 7, 19, 25 und UWG Art. 3 Abs. 1 lit. s selbst auf fedlex.admin.ch nachlesen oder prüfen lassen.
- **Marktrecherche:** Ich habe keine Nutzerzahlen erfunden. Wo ich Marktgrössen nicht belegen kann, schreibe ich «unbekannt» und formuliere eine Testhypothese.
- **Apple-Regeln ändern sich.** Alle Apple-Angaben gelten für den 29.09.2026 und sind unmittelbar vor der Einreichung erneut zu prüfen.

### 1.4 Kennzeichnung im Text

- **[Belegt]** Anforderung an der Quelle geprüft.
- **[Einschätzung]** Fachliche Einschätzung des Teams, keine Rechtsauskunft.
- **[Offen]** Rechtsfrage oder Prüfung, die eine qualifizierte Fachperson für den Einzelfall beurteilen muss oder die aus technischen Gründen nicht abgeschlossen werden konnte.

---

## 2. Sechzehn Ideen im Vergleich

### 2.1 Vorgehen

Ich habe bewusst Ideen aus verschiedenen Lebensbereichen gesammelt (Koordination, Konsum, Wohnen, Verträge, Freizeit, Energie, Mobilität, Soziales, Gesundheit, Familie, Kreativität, Sharing Economy) und darunter auch Ideen, die wegen ihrer Risiken ausscheiden. So ist der Ausschlussgrund sichtbar und nachvollziehbar.

Bewertung 1 (schlecht) bis 5 (sehr gut). Bei den Risikokriterien bedeutet 5 «sehr geringes Risiko». Gewichtung: Rechtsrisiko für dich ×3, Risiko für Nutzer und Dritte ×2, alle anderen ×1. Maximal 70 Punkte. **Ein hoher Gesamtwert hebt einen Ausschlussgrund nicht auf.** Ausschluss- und Warnrisiken stehen separat in der letzten Spalte.

Kürzel: N = Nutzen und Verständlichkeit · Z = Zielgruppe (Grösse, Erreichbarkeit) · E = natürlicher Empfehlungsanlass · W = Wiederkehr ohne künstliche Bindung · M = technische Machbarkeit und Kosten der ersten Version · B = Betrieb, Support, Sicherheit durch eine Einzelperson · D = Datensparsamkeit (5 = fast keine Daten nötig) · A = Unabhängigkeit von fremden Plattformen, Inhalten, Lizenzen · S = Sicherheit für Nutzer und Dritte (×2) · R = straf-, zivil-, regulierungs- und vertragsrechtliches Risiko für dich (×3) · P = Wahrscheinlichkeit der Apple-Zulassung.

### 2.2 Vergleichstabelle

| # | Idee (Bereich) | N | Z | E | W | M | B | D | A | S×2 | R×3 | P | **Total /70** | Ausschluss- und Warnrisiken (separat) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | **Reihum – faire Turnuspläne** für Team, WG, Familie, Verein; Export als Bild/Text/.ics (Koordination) | 4 | 4 | 4 | 4 | 5 | 5 | 5 | 5 | 10 | 15 | 5 | **66** | Warn: Vornamen Dritter im geteilten Bild (Verantwortung der teilenden Person; Hinweis in der App). Kein Ausschlussgrund. |
| 2 | **Garantie- und Belegtresor**: Kaufbeleg fotografieren, Garantieende erinnern (Konsum) | 4 | 5 | 2 | 4 | 5 | 4 | 4 | 5 | 10 | 15 | 5 | **63** | Warn: Belegfotos sind Kaufdaten (lokal); Datenverlust bei Gerätewechsel ohne Backup; Rechtsinfo zu Gewährleistungsfristen nur neutral. |
| 3 | **Spielabend-Punktetafel** (inkl. Jass) (Freizeit) | 3 | 4 | 4 | 4 | 5 | 5 | 5 | 5 | 10 | 15 | 3 | **63** | Warn: Marktsättigung, Apple 4.3(b) Klon-Risiko; jede Geld-/Einsatzfunktion strikt vermeiden (Glücksspielnähe). |
| 4 | **Ausgeliehen** – Leihregister mit freundlicher Erinnerung (Alltag) | 3 | 4 | 3 | 3 | 5 | 5 | 4 | 5 | 10 | 15 | 4 | **61** | Warn: Namen Dritter lokal; geringer Empfehlungsanlass. |
| 5 | **Zählerstand und Verbrauch** (Strom, Wasser, Gas) mit Foto und Diagramm (Energie) | 3 | 3 | 2 | 4 | 5 | 5 | 4 | 5 | 10 | 15 | 5 | **61** | Warn: Kostenrechnung nur mit vom Nutzer eingegebenem Tarif (keine Tarifdatenbank, keine Beratung). |
| 6 | **Kündigungsfristen-Wächter** für Abos und Verträge (Verträge) | 5 | 5 | 3 | 4 | 5 | 4 | 4 | 5 | 8 | 9 | 5 | **57** | Warn: verpasste Frist durch Fehler oder abgeschaltete Mitteilungen führt zu Schadenersatzvorwürfen; Schweizer Kündigungstermine (Mietrecht, Krankenkasse) sind Rechtsinformation; bestehende Apps («Contract», aboalarm). |
| 7 | **Sonnen-Check** für Balkon und Wohnung (Wohnen/Garten) | 3 | 3 | 3 | 2 | 4 | 5 | 4 | 4 | 10 | 12 | 5 | **55** | Warn: Genauigkeitserwartung (Verschattung nicht berechenbar); Kartendienst-Abhängigkeit; Standort optional halten. |
| 8 | **Vorher/Nachher-Fotovergleich** (Kreativ/Alltag) | 3 | 4 | 4 | 3 | 5 | 5 | 3 | 5 | 8 | 12 | 3 | **55** | Warn: Körperbilder und Fitness-/Gesundheitsnähe; Marktsättigung. |
| 9 | **Rechnung teilen am Tisch** mit On-Device-Texterkennung (Alltag) | 3 | 4 | 4 | 3 | 4 | 4 | 4 | 5 | 8 | 12 | 3 | **54** | Warn: In der Schweiz ist getrennt Zahlen im Restaurant üblich (geringerer Bedarf); starke Sättigung; Finanznähe (nur Rechnen, kein Zahlungsverkehr). |
| 10 | **Zustandsprotokoll für Übergaben** (Wohnung, Mietauto, Ferienwohnung) mit PDF (Wohnen/Mobilität) | 5 | 4 | 4 | 2 | 4 | 4 | 4 | 5 | 8 | 9 | 4 | **53** | Warn: Erwartung an Beweiswert, Datenverlust vor Streitfall, Nähe zu mietrechtlicher Information; **mehrere bestehende CH-Apps**, darunter der Name «Übergabe» (DE). |
| 11 | **Parkzeit-Wecker** mit Standortmerker (Mobilität) | 4 | 4 | 3 | 4 | 4 | 4 | 2 | 5 | 6 | 9 | 4 | **49** | Warn: Standortdaten; Bussenvorwürfe bei Fehlalarm; Mitteilungen können vom System verzögert werden. |
| 12 | **Wer bringt was?** Apéro-/Potluck-Planer mit geteiltem Stand über Link (Soziales) | 4 | 4 | 5 | 3 | 3 | 2 | 2 | 3 | 8 | 9 | 4 | **47** | Warn: braucht Backend mit Personendaten Dritter; Allergieangaben sind Gesundheitsdaten; Link-Missbrauch und Moderation; laufende Kosten. |
| 13 | **Medikamenten- und Symptomtagebuch** (Gesundheit) | 4 | 4 | 2 | 5 | 4 | 3 | 1 | 5 | 4 | 3 | 3 | **38** | **Ausschluss:** besonders schützenswerte Gesundheitsdaten, Medizinprodukte-Abgrenzung (MepV), Apple 1.4.1 erhöhte Prüfung, Schadenpotenzial bei Fehlern. |
| 14 | **Sackgeld-App für Kinder** (Familie/Finanzen) | 3 | 3 | 3 | 4 | 4 | 3 | 2 | 4 | 4 | 6 | 2 | **38** | **Ausschluss:** Minderjährige als Nutzer (Kids-Kategorie, Einwilligungsfragen), Geldbezug, erhöhte Apple-Anforderungen. |
| 15 | **Nachbarschafts-Werkzeugverleih** als Marktplatz (Sharing) | 4 | 3 | 4 | 3 | 2 | 1 | 1 | 3 | 2 | 3 | 2 | **28** | **Ausschluss:** Fremde treffen sich, UGC, Profile, Nachrichten, Haftung bei Schäden, Moderation, Betrug, Standort. |
| 16 | **Pendler-Mitfahrbörse** (Mobilität) | 4 | 3 | 4 | 4 | 2 | 1 | 1 | 3 | 2 | 3 | 2 | **28** | **Ausschluss:** Fremde im Fahrzeug, Standortverfolgung, Personenbeförderungs- und Versicherungsfragen, Moderation. |

### 2.3 Lesehilfe zur Tabelle

- **Ideen 13 bis 16** scheiden unabhängig vom Punktwert aus. Sie erfordern Moderation, regulierte Tätigkeiten, Gesundheits- oder Standortdaten oder betreffen Minderjährige.
- **Idee 12** ist die einzige mit «eingebauter» Viralität, scheitert aber daran, dass sie ohne Backend nicht funktioniert und damit Personendaten Dritter auf deinem Server landen würden. Das ist für ein Einzelprojekt ohne Rechtsberatung nicht angemessen.
- **Ideen 6 und 10** haben den höchsten unmittelbaren Nutzen, aber ein spürbar höheres Rechts- und Erwartungsrisiko (verpasste Fristen, Beweiswert) und bestehende Konkurrenz im Schweizer Store.
- **Ideen 1 bis 5** liegen im Bereich «sehr geringes Risiko». Unter ihnen hat **Idee 1** den klarsten natürlichen Empfehlungsanlass, weil jede Nutzung ein Artefakt erzeugt, das an mehrere Personen geht.

---

## 3. Vertiefung der drei besten Ideen

### 3.1 Idee 1: Reihum – faire Turnuspläne

**Problem.** In jeder kleinen Gruppe gibt es wiederkehrende Aufgaben, die abwechselnd erledigt werden: Znüni oder Gipfeli im Team, Putzen in der WG, Elterndienst in Kita, Spielgruppe und Schule, Kuchen backen, Fahrdienst oder Trikots waschen im Verein, Ämtli in der Familie, Pflanzen giessen im Büro. Heute wird das in Excel, auf Zetteln oder im Gruppenchat geregelt. Ergebnisse: Unfairness («immer ich»), Verwirrung bei Abwesenheiten, niemand erinnert sich, wer dran ist.

**Lösung.** Eine Person (die Organisatorin, der Organisator) erfasst Namen, Rhythmus und Abwesenheiten. Die App berechnet einen fairen Plan über einen wählbaren Zeitraum, zeigt «Heute/Nächste Woche ist … dran», erlaubt Tausch und Neuberechnung ohne Verlust der Historie und exportiert den Plan als Bild für den Chat, als Text oder als Kalenderdatei (.ics), wahlweise pro Person. Empfangende brauchen die App nicht: Sie sehen das Bild oder importieren ihre Termine in den eigenen Kalender.

**Zielgruppe.** Organisierende in Gruppen von etwa 3 bis 30 Personen: Teamleitende und Assistenzen, WG-Mitglieder, Elternräte, Vereinsvorstände, Familien. Alter 18+. Marktgrösse: unbekannt, keine Zahlen erfunden. Testhypothese: In der Schweiz gibt es sehr viele Vereine, Elternvertretungen und WGs; das ist plausibel, aber ohne belegte Zahl.

**Empfehlungsanlass.** Jeder geteilte Plan erreicht die ganze Gruppe. Wer selbst irgendwo organisiert (das trifft in Vereinen und Elternräten häufig zu), fragt nach der App. Zusätzlich ist der Rhythmus wiederkehrend, also gibt es mehrere Kontaktpunkte pro Gruppe.

**Wiederkehr.** Jeder Zyklus (wöchentlich, monatlich), jede Abwesenheit, jeder Tausch, jede neue Periode.

**Risiken.** Nahezu keine regulierten Berührungspunkte. Es werden Vornamen Dritter lokal gespeichert und von der teilenden Person selbst weitergegeben; das entspricht einer Chatnachricht mit Namen. Kein Backend, keine Konten, kein Standort, keine Kamera, keine Kontakte-Berechtigung. Hauptrisiken: Unzufriedenheit über als unfair empfundene Pläne (Reputationsrisiko), Kalenderimport-Probleme (Support), Namens- und Markenkonflikt (prüfbar).

**Wettbewerb.** Gefunden wurden B2B-Dienstplan-Apps (komplex, Konten, kostenpflichtig) und Haushalts-Putzplan-Apps (alle Mitglieder müssen sich registrieren, Sync). Der organisatorzentrierte, kontofreie Ansatz mit Fairness-Logik und .ics-Export ist eine klar unterscheidbare Variante, nicht ein Klon. Apple 4.3(b) [Einschätzung]: geringe Gefahr, sofern Fairness-Engine und Export sichtbar den Kern bilden.

**Schwächen, ehrlich benannt.** Der Nutzen ist «Koordination», nicht «Geld sparen» oder «Recht sichern». Der Empfehlungsanlass ist real, aber die Empfangenden müssen nicht installieren, um zu profitieren. Das bremst die Adoption. Kein geteilter Zustand: Tauschwünsche kommen weiterhin per Chat zur organisierenden Person zurück (so ist es heute auch).

### 3.2 Idee 2: Garantie- und Belegtresor

**Problem.** Kaufbelege gehen verloren; Garantieansprüche scheitern daran. Nutzer wollen wissen: Wann läuft die Garantie für Kaffeemaschine, Velo, Kopfhörer ab?

**Lösung.** Foto des Belegs, Kaufdatum, Dauer (Standardvorschlag 24 Monate, frei änderbar), optionaler Hinweis vor Ablauf, Suche, Export. Alles lokal, Backup über iCloud-Gerätebackup.

**Stärken.** Universell verständlich, sehr geringes Rechtsrisiko, hohe Wiederkehr (jeder Kauf), kein Backend.

**Schwächen.** Der Empfehlungsanlass ist schwach: Die App wird selten in Gegenwart anderer benutzt, und das Artefakt (ein Beleg) geht nur an einen Händler. Wettbewerb existiert in mittlerer Dichte. Rechtsinformationen zu Gewährleistungsfristen (OR Art. 210) dürfen nur neutral und mit Quelle erscheinen [Offen: Primärquelle]. Zudem sind Belegdaten sensibler als Vornamen (Kaufverhalten, teilweise Kartenendziffern), was den Datenschutzbedarf leicht erhöht, auch wenn alles lokal bleibt.

**Fazit.** Sehr sichere Idee mit solider Wiederkehr, aber ohne natürlichen Verteilmechanismus. Bleibt eine gute Rückfalloption.

### 3.3 Idee 3: Spielabend-Punktetafel

**Problem.** Punkte zählen bei Jass, Kartenspielen und Brettspielen; Historie, Fairness der Startreihenfolge, Statistik.

**Stärken.** Wird am Tisch vor allen benutzt («Was ist das für eine App?»), sehr hohe Wiederkehr für die Zielgruppe, kein Rechtsrisiko, keine Personendaten ausser Vornamen.

**Schwächen.** Der Schweizer Store ist mit Jasstafel-Apps gut besetzt, und generische Punktezähler sind zahlreich. Apple 4.3(b) (Klone) ist ein reales Zulassungsrisiko, wenn die App nicht deutlich mehr bietet. Der Nutzen wirkt weniger «professionell» im Sinn deiner Vorgabe. Jede Funktion mit Geld oder Einsätzen wäre ein Glücksspiel-Risiko und wird ausgeschlossen; das begrenzt die Differenzierung.

**Fazit.** Ebenso sicher wie Idee 1, aber mit höherem Klon-Risiko und geringerer Professionalität. Nicht gewählt.

### 3.4 Knapp dahinter: Kündigungsfristen-Wächter und Zustandsprotokoll

Beide haben den stärksten unmittelbaren Nutzen. Beide wurden aus Risikogründen zurückgestuft: Beim Fristen-Wächter kann ein Fehler oder eine vom Nutzer deaktivierte Mitteilung zu einem konkreten Geldschaden führen, der dir zugeschrieben würde; Schweizer Kündigungstermine (Mietrecht, Krankenkasse) sind Rechtsinformation, die aktuell gehalten werden müsste. Beim Zustandsprotokoll besteht die Erwartung an Beweiswert, und im Schweizer Store existieren bereits mehrere Apps für genau diesen Zweck. Beide Ideen bleiben als spätere, separat zu prüfende Produkte denkbar.

---

## 4. Begründete Auswahl

**Gewählt wird Idee 1: Reihum – faire Turnuspläne.**

Begründung entlang deiner Prioritäten:

1. **Risiko für dich.** Keine regulierte Tätigkeit, keine Zahlungsabwicklung, keine Gesundheits- oder Standortdaten, keine Minderjährigen als Zielgruppe, keine fremden Inhalte, keine Automatisierung fremder Dienste, kein Backend und damit keine Datenpanne auf deiner Seite. Die verbleibenden Rechtsfragen (Impressum, Datenschutzerklärung, Name/Marke) sind Standardfragen, die mit wenigen Stunden Fachberatung abschliessbar sind.
2. **Sicherheit für Nutzer und Dritte.** Die einzigen Personendaten sind Vornamen und Abwesenheitsdaten, die die organisierende Person ohnehin kennt und heute schon im Chat teilt. Die App fügt keine neue Öffentlichkeit hinzu.
3. **Nutzen und Professionalität.** Das Problem ist in einem Satz verständlich, der Nutzen ist sofort sichtbar (fertiger Plan in unter einer Minute), und die Fairness-Logik leistet etwas, das Excel und Chat nicht leisten.
4. **Wachstum aus dem Nutzen.** Jede Nutzung erzeugt ein Artefakt, das freiwillig an mehrere Personen geht. Das ist der risikoärmste Verteilmechanismus, den es gibt: keine Einladungen, kein Kontaktbuch-Upload, keine Benachrichtigungen an Dritte.
5. **Betrieb.** Eine Person kann Support, Updates und Store-Pflege bewältigen. Es gibt nichts, das ständig überwacht werden müsste.

**Was du mit dieser Wahl bewusst aufgibst:** ein «eingebautes» Netzwerk (geteilter Zustand, gegenseitige Benachrichtigungen) und die stärkeren Nutzenversprechen der Fristen- oder Protokoll-Ideen. Beides wäre nur mit Backend, Rechtsinformation oder höherer Erwartungshaftung zu haben. Nach deiner Vorgabe ist die weniger spektakuläre, deutlich sicherere Idee zu bevorzugen.

---

## 5. Vollständiges Produktkonzept und Nutzerablauf

### 5.1 Ein-Satz-Pitch

**Reihum erstellt in unter einer Minute einen fairen Plan, wer wann dran ist, und teilt ihn als Bild oder Kalenderdatei mit der Gruppe, ohne Konto, ohne Cloud, ohne dass die anderen die App brauchen.**

### 5.2 Das konkrete Problem und die wichtigste Zielgruppe

**Problem.** Wiederkehrende Aufgaben in kleinen Gruppen werden heute in Excel, auf Papier oder im Gruppenchat verteilt. Das ist mühsam (Abwesenheiten, Ferien, Neuzugänge), oft unfair (wer den Plan macht, vergisst die Historie) und nicht erinnerbar (niemand weiss am Freitagmorgen, wer die Gipfeli bringt).

**Primäre Zielgruppe.** Die Person, die in einer Gruppe organisiert: Teamleitende und Assistenzen (Znüni, Sitzungsleitung, Pflanzen), WG-Mitglieder (Putzen, Einkauf, Abfall), Eltern in Kita- und Schulgremien (Elterndienst, Fahrdienst), Vereinsvorstände (Kuchen, Trikots, Kasse, Fahrdienst), Familien (Ämtli für Erwachsene und ältere Kinder; die App richtet sich an die Eltern, nicht an Kinder).

**Sekundäre Zielgruppe.** Alle Empfangenden eines Plans. Sie profitieren ohne Installation.

### 5.3 Kernnutzen und Abgrenzung zu naheliegenden Alternativen

| Alternative | Was sie kann | Was Reihum anders macht |
|---|---|---|
| Excel / Google Sheets | Freie Tabelle, überall verfügbar | Kein Rechnen von Fairness über Zyklen, keine Abwesenheitslogik, kein Kalenderexport pro Person, unhandlich am Handy |
| Gruppenchat | Sofort, alle sind da | Nichts wird nachgehalten; der Plan verschwindet im Verlauf. Reihum liefert das Bild für genau diesen Chat. |
| Putzplan-/Haushalts-Apps mit Konten | Erinnerungen an alle, Gamification | Alle müssen installieren und ein Konto anlegen; Daten liegen bei einem Anbieter. Reihum: nur eine Person braucht die App, keine Konten, keine Cloud. |
| Dienstplan-Apps (B2B) | Schichten, Arbeitsrecht, Abrechnung | Für kleine, informelle Gruppen überdimensioniert und kostenpflichtig. |
| Apple Erinnerungen / Kalender | Termine, geteilte Listen | Kein Fairness-Algorithmus, keine Rotation mit Abwesenheiten. Reihum exportiert **in** den Kalender, statt ihn zu ersetzen. |

**Kernnutzen in drei Worten:** fair, schnell, teilbar.

### 5.4 Erstes Nutzungserlebnis: vom App-Store-Eintrag bis zum ersten Erfolgsmoment

1. **App-Store-Eintrag.** Titel «Reihum – Wer ist dran?». Untertitel «Faire Turnuspläne für Team, WG und Verein». Erster Screenshot zeigt einen fertigen Plan, zweiter das Teilen als Bild im Chat, dritter den Kalenderexport, vierter die Abwesenheitslogik. Datenschutz-Label: «Daten werden nicht erfasst». Altersfreigabe 4+ (voraussichtlich, gemäss Fragebogen).
2. **Erster Start.** Kein Onboarding mit mehreren Seiten, keine Berechtigungsabfrage, kein Konto. Ein leerer Zustand mit einer Zeile Erklärung und dem Knopf «Ersten Plan erstellen». Optional «Beispiel ansehen» mit erfundenen Beispielnamen (keine realen Personen).
3. **Plan erstellen (vier kurze Schritte, ein Bildschirm pro Schritt, jederzeit zurück).**
   - Name und Symbol: «Znüni-Dienst», Symbol aus einer kleinen Auswahl.
   - Personen: Vornamen tippen, Return für die nächste Person. Optional Gewicht (z. B. Teilzeit = 0.5). Keine Kontakte-Berechtigung.
   - Rhythmus: jeden Freitag / jeden Werktag / alle zwei Wochen / monatlich am ersten Montag. Personen pro Termin: 1 oder 2.
   - Zeitraum: Startdatum, Dauer (z. B. 12 Wochen). Optional: Daten überspringen (Ferien, Feiertage manuell).
4. **Erfolgsmoment 1 (unter 60 Sekunden).** Der fertige Plan erscheint: nach Monat gruppiert, nächster Termin hervorgehoben, unten eine kleine Fairness-Anzeige («Jede Person 3×»).
5. **Erfolgsmoment 2.** Knopf «Teilen»: Vorschau des Bildes, Auswahl Bild / Text / Kalender (alle) / Kalender (pro Person). Das System-Share-Sheet öffnet sich; der Plan geht in den Gruppenchat. Zurück in der App erscheint der Hinweis «Geteilt. Wenn sich etwas ändert: Tauschen oder neu berechnen und erneut teilen.»
6. **Wiederkehr.** Vor dem nächsten Termin (optional, nur lokal) erinnert die App die organisierende Person: «Morgen: Anna ist dran.» Kein Zwang, keine Standardaktivierung ohne Frage.

### 5.5 Funktionen der ersten Version mit Begründung

| Funktion | Begründung | Risiko-Check |
|---|---|---|
| Pläne anlegen, bearbeiten, löschen | Kern | Keine |
| Personen mit Vorname, optionalem Gewicht, Farbe (Initialen-Avatar) | Fairness bei Teilzeit oder Doppelrollen; Avatare ohne Fotos halten die App datensparsam | Vornamen Dritter lokal; Hinweis «Teile Pläne nur mit den betroffenen Personen» |
| Abwesenheiten pro Person (Datumsbereiche) | Häufigster Grund, weshalb Pläne heute scheitern | Keine |
| Rhythmen: täglich, Werktage, wöchentlich (Wochentag), zweiwöchentlich, monatlich (n-ter Wochentag oder Tag des Monats) | Deckt Team, WG, Familie, Verein ab | Kalenderarithmetik testen (Zeitumstellung, Schaltjahr) |
| 1 oder 2 Personen pro Termin | Kuchen zu zweit, Fahrdienst zu zweit | Keine |
| Termine überspringen (manuell) | Ferien, Feiertage; **keine eingebaute Feiertagsdatenbank** in Version 1 | Vermeidet falsche kantonale Feiertagsdaten und Lizenzfragen |
| Fairness-Engine (deterministisch, erklärbar) | Der eigentliche Mehrwert gegenüber Excel | Unit-Tests mit Invarianten (Abschnitt 8.4) |
| Historie einfrieren, Zukunft neu berechnen | Änderungen dürfen Vergangenes nicht umschreiben | Keine |
| Tausch zweier Termine, manuelle Zuweisung | Realität: «Ich kann am 14. nicht» | Manuelle Zuweisungen werden bei Neuberechnung geschützt |
| Teilen als Bild (hell/dunkel), Text, .ics (gesamt oder pro Person) | Der Verteilmechanismus; Empfangende brauchen keine App | Hinweiszeile «Erstellt mit Reihum» standardmässig an, in den Einstellungen kostenlos abschaltbar; keine Links mit Tracking-Parametern pro Person |
| Lokale Erinnerung an die organisierende Person (optional, Opt-in) | Wiederkehr ohne Druck | Berechtigung wird erst gefragt, wenn der Nutzer die Funktion aktiviert; Ablehnung wird respektiert |
| Datenexport (JSON) und Import über die Dateien-App | Datenportabilität, Backup, Gerätewechsel ohne Cloud-Konto beim Entwickler | Reduziert Datenverlust-Risiko |
| «Alle Daten löschen» in den Einstellungen | Kontrolle, Transparenz | Bestätigung mit zweitem Schritt |
| In-App: Datenschutzhinweise, Impressum, Kontakt, Lizenzhinweise | Apple 5.1.1 (i) verlangt Datenschutz-Link in der App; UWG Impressum [Sekundär] | Texte durch Fachperson prüfen [Offen] |
| Vollständige Lokalisierung DE, vorbereitet FR/IT/EN | Schweizer Markt | Übersetzungen prüfen lassen (Verständlichkeit) |
| Dynamic Type, VoiceOver, Kontrast, Reduce Motion | Pflicht für eine professionelle App; Grundlage für spätere EU-Barrierefreiheitsanforderungen | Keine |

### 5.6 Funktionen, die bewusst erst später geprüft werden

| Funktion | Grund der Zurückstellung | Was vor Einführung erneut geprüft werden muss |
|---|---|---|
| Widget «Heute ist … dran» und Sperrbildschirm-Widget | Nicht nötig für den ersten Erfolgsmoment; sinnvoll für Wiederkehr | Kein Risiko, nur Aufwand |
| Siri-Kurzbefehle («Wer ist heute dran?») | Nice-to-have | App-Intents-Datenschutz (Daten bleiben lokal) |
| Zweiter Plantyp «Mitbringliste» (Wer bringt was, ohne geteilten Zustand) | Erst prüfen, ob Turnuspläne allein tragen | Allergie-/Ernährungsangaben strikt weglassen (Gesundheitsdaten) |
| Feiertage (Schweiz, kantonal) | Datenquelle, Aktualität und Korrektheit müssen gesichert sein | Lizenz der Datenquelle; Haftung für falsche Daten; Wartung |
| iCloud-Sync zwischen eigenen Geräten (CloudKit, private Datenbank) | Daten verlassen erst dann das Gerät; Apple-Infrastruktur, aber neuer Prüfaufwand | Datenschutzerklärung und App-Privacy-Label anpassen; Fehlerfälle Sync |
| Gemeinsames Bearbeiten durch mehrere Personen | Benötigt Backend oder CloudKit-Sharing (alle brauchen iCloud und die App). Widerspricht dem Grundsatz «keine Personendaten Dritter auf fremden Servern». | Vermutlich nie; nur mit Rechtsberatung, Kostenmodell und Missbrauchsschutz |
| PDF-Export, eigenes Logo im Bild | Nachfrage abwarten | Keine |
| Statistik über Zyklen («Anna hat 12× übernommen») | Fairness-Anzeige reicht zunächst | Keine |
| Kontakte-Picker zum Übernehmen von Namen | Bequemlichkeit; Apple empfiehlt Picker statt Vollzugriff | Kein Berechtigungsdialog beim Picker; trotzdem erst nach Bedarf |
| Bezahlfunktion (Pro-Freischaltung) | Erst nach Validierung; siehe 5.8 | In-App-Kauf nach Apple 3.1.1, Preisangaben, Steuern, Widerruf/Erstattung über Apple |

### 5.7 Vorschlag für App-Name und Positionierung (vorbehaltlich Marken- und Verfügbarkeitsprüfung)

**Primärvorschlag:** **Reihum** (Untertitel: «Wer ist dran?»). Ein alltagsnahes deutsches Wort, kurz, aussprechbar, bildlich («der Reihe nach»), für FR/IT/EN als Eigenname tragbar.

**Alternativen:** «Dran!», «Turnus», «Ämtli» (stark schweizerisch, ausserhalb der Deutschschweiz schwer), «Abwechselnd».

**Positionierung:** «Der faire Plan für alles, was man sich abwechselnd teilt. Ohne Konto. Ohne Cloud. Ohne dass die anderen eine App brauchen.»

**Pflichtprüfungen vor Festlegung [Offen]:**
- Markenrecherche Schweiz (Swissreg, IGE), EU (EUIPO) und international (WIPO Global Brand Database) in den Klassen 9 und 42, auch auf ähnliche Zeichen.
- App-Store-Namensverfügbarkeit (App Store Connect erlaubt nur eindeutige Namen; generische Wörter sind oft belegt).
- Domain (z. B. reihum.app oder reihum.ch) für Datenschutzerklärung, Impressum und Support.
- Prüfung, ob «Reihum» in FR/IT/EN unbeabsichtigte Bedeutungen hat.
- Optionale Markenanmeldung erst nach Validierung (Kosten gegen Nutzen abwägen).

### 5.8 Monetarisierungsmodell

**Entscheid für Version 1: keine Monetarisierung, keine Werbung.**

Begründung: Werbung würde Drittanbieter-SDKs, Tracking-Fragen und ein anderes Datenschutz-Label mit sich bringen; das widerspricht dem Kernversprechen. Käufe in Version 1 würden Verbraucherschutz-, Preisangabe- und Steuerfragen vorziehen, bevor der Nutzen belegt ist. Die Kosten der ersten Version sind gering (Abschnitt 8.10).

**Später plausibel (nur nach Validierung und erneuter Risikoprüfung):**
- Ein **einmaliger In-App-Kauf** («Reihum Pro»), zum Beispiel für mehr als drei aktive Pläne, Widgets, PDF-Export. Einmalkauf statt Abonnement, weil ein Abo bei einem lokalen Werkzeug schwer zu rechtfertigen ist und Kündigungs-/Verlängerungsfragen erzeugt.
- Pflichten dann: In-App-Kauf über Apple (Guideline 3.1.1 [Belegt]); Preis wird vom App Store inkl. MwSt. angezeigt; «Käufe wiederherstellen»-Knopf; klare Beschreibung, was freigeschaltet wird; keine irreführenden Vergleiche; Erstattungen laufen über Apple; Small Business Program für 15 % Provision [Belegt]; steuerliche Behandlung der Einnahmen in der Schweiz [Offen]; bei EU-Vertrieb Händlerstatus nach DSA [Belegt]; Impressumspflicht wird dann eindeutig [Sekundär].
- **Nicht vorgesehen:** Abonnemente, Werbung, Verkauf von Daten, «Freunde einladen»-Belohnungen.

### 5.9 Messgrössen für Nutzen, Wiederkehr und Empfehlungen, ohne personenbezogenes Tracking

Grundsatz: Die App sendet nichts. Alle Messgrössen kommen aus aggregierten Apple-Berichten (App Store Connect App Analytics, nur von Nutzern, die der Weitergabe zugestimmt haben), aus qualitativen Gesprächen und aus TestFlight-Feedback.

| Frage | Messgrösse | Quelle | Bemerkung |
|---|---|---|---|
| Wird der Nutzen verstanden? | Verhältnis Produktseiten-Aufrufe zu Downloads (Conversion) | App Store Connect (aggregiert) | Vergleich zwischen Screenshot-Varianten über Produktseiten-Optimierung |
| Kommen Nutzer wieder? | Aktive Geräte nach 7/28 Tagen, Sitzungen pro aktivem Gerät | App Store Connect (aggregiert, Opt-in) | Keine eigene Erfassung |
| Entstehen Empfehlungen? | Downloads über Quelle «App-Verweis/Web-Verweis», Anteil «Suche» vs. «Verweis» | App Store Connect Quellen | Die Hinweiszeile im geteilten Bild enthält nur den App-Namen, keinen personalisierten Link |
| Ist der Plan fair und brauchbar? | Anteil Testpersonen, die nach einem vollen Zyklus einen zweiten Zyklus oder Plan erstellen | Interviews, TestFlight-Feedback | Qualitativ, kleine Zahl, ehrlich berichten |
| Wo hakt es? | Support-Anfragen nach Thema (Kalenderimport, Rhythmus, Tausch) | Support-Postfach | Manuell kategorisieren |
| Zufriedenheit | App-Store-Bewertungen; Aufforderung nur über die System-Bewertungsabfrage nach einem Erfolgsmoment, maximal gemäss Apple-Limit | App Store | Keine gekauften oder gelenkten Bewertungen |

**Nicht eingesetzt:** Analyse-SDKs, Werbe-IDs, Fingerprinting, eigene Server-Logs, Kohorten pro Person. Eine spätere freiwillige, anonyme Nutzungsstatistik ist möglich, aber nur mit Opt-in, eigener Datenschutzprüfung und angepasstem Label.

---

## 6. Viralitätsmechanismus und risikoarmer Plan für die ersten Nutzer

### 6.1 Warum jemand die App nach der ersten Nutzung behält

- Der Plan lebt: Abwesenheiten, Tausch, nächste Periode. Die App ist der Ort, an dem der Plan gepflegt wird.
- Die Erinnerung «Morgen: Anna ist dran» (Opt-in) löst ein reales Problem der organisierenden Person.
- Beim zweiten Zyklus zahlt sich die Historie aus: Wer im letzten Quartal oft übernommen hat, ist jetzt seltener dran. Das kann kein Chat.

### 6.2 In welcher natürlichen Situation jemand die App zeigt oder empfiehlt

- **Der geteilte Plan selbst.** Er landet in einem Chat mit 5 bis 30 Personen. Am unteren Rand steht dezent «Erstellt mit Reihum». Das ist die Hauptsituation und sie wiederholt sich jeden Zyklus.
- **Die Übergabe der Organisation.** In Vereinen und Elternräten wechselt die organisierende Person regelmässig. Die Nachfolge fragt: «Wie hast du das gemacht?»
- **Das Gespräch über Unfairness.** «Bei uns ist immer dieselbe Person dran» ist ein alltägliches Gesprächsthema in Teams und WGs.
- **Der Kalendereintrag.** Wer die .ics-Datei importiert, sieht die Termine im eigenen Kalender; bei Rückfragen erklärt die organisierende Person die Herkunft.

### 6.3 Welchen eigenständigen Nutzen die empfangende Person hat

- Sie sieht sofort, wann sie dran ist, ohne die App zu installieren.
- Mit der persönlichen Kalenderdatei bekommt sie Termine mit optionaler Erinnerung in ihrem eigenen Kalender.
- Sie hat einen nachvollziehbaren, fairen Plan statt eines Zurufs im Chat.

### 6.4 Wie Teilen freiwillig, verständlich und datensparsam funktioniert

- Teilen geschieht ausschliesslich über das **System-Share-Sheet**. Die App weiss nicht, wohin geteilt wurde und mit wem.
- Das Bild enthält nur, was auf dem Bildschirm steht: Planname, Zeitraum, Termine, Vornamen. Keine Metadaten über Gerät oder Nutzer.
- Die Hinweiszeile «Erstellt mit Reihum» ist **standardmässig an**, klar sichtbar in der Vorschau und **kostenlos abschaltbar**. Sie enthält keinen personalisierten Link; falls ein Link, dann höchstens die allgemeine App-Store-Seite. Kein Tracking der Empfänger.
- Die .ics-Datei enthält als Herkunft eine technische PRODID («Reihum»), wie jede Kalenderdatei. Keine Nutzer-Kennungen.
- Vor dem ersten Teilen erscheint ein kurzer Hinweis: «Der Plan enthält Namen. Teile ihn nur mit den Personen, die dazugehören.» (einmalig, wegklickbar).
- **Kein** Kontaktbuch-Upload, **keine** Einladungen aus der App, **keine** Mitteilungen an Dritte, **keine** Belohnungen fürs Weiterempfehlen.

### 6.5 Wie die App erste Nutzer ohne grosses Werbebudget gewinnt

1. **Eigenes Umfeld (Woche 1 bis 4).** Fünf bis zehn Personen, die heute einen Plan organisieren (Team, WG, Elternrat, Verein), erhalten die TestFlight-Version. Ziel: echte Pläne, echte Zyklen.
2. **Die Pläne dieser Personen** erreichen ihre Gruppen. Das ist der erste organische Kreis.
3. **App-Store-Optimierung.** Präzise Schlüsselwörter in DE/FR/IT (Putzplan, Ämtliplan, Turnus, Dienstplan Verein, Elterndienst, Znüni-Plan). Screenshots, die den fertigen Plan und das Teilen zeigen. Kein Budget nötig.
4. **Einfache Landingpage** (statisch, kostenlos hostbar) mit Datenschutzversprechen, Impressum, Support-Adresse und FAQ zum Kalenderimport. Dient gleichzeitig als Pflichtseite für Apple.
5. **Zielgruppen-Kanäle, mit Erlaubnis und ohne Spam.** Schweizer Vereinsverbände, Elternvereinigungen, WG-Portale und Communities, jeweils mit einer ehrlichen Vorstellung und der Bitte um Feedback; Regeln der jeweiligen Community beachten; keine Mehrfachpostings.
6. **Bewertungen** nur über die System-Abfrage nach einem Erfolgsmoment.
7. **Presse/Blogs** (Schweizer Tech- und Familienmedien) erst, wenn die App stabil ist und ein bis zwei Zyklen bei Testgruppen gelaufen sind.

### 6.6 Annahmen, die zuerst mit echten Nutzern getestet werden müssen

| Annahme | Test | Abbruch-/Anpassungskriterium |
|---|---|---|
| Organisierende empfinden das heutige Vorgehen als Problem | 5 bis 8 Gespräche vor dem Prototyp | Weniger als die Hälfte nennt das Problem ungefragt oder bestätigt es klar |
| Ein Plan ist in unter zwei Minuten erstellt | Beobachtete Nutzung des klickbaren Prototyps | Median über 3 Minuten oder Abbruch bei mehr als einer Person |
| Das Bild wird tatsächlich in die Gruppe geteilt | TestFlight, Selbstauskunft | Weniger als die Hälfte der Testpersonen teilt innerhalb einer Woche |
| Empfangende nehmen die App wahr und fragen nach | Selbstauskunft der Testpersonen, App-Store-Quelle «Verweis» | Null Rückfragen nach zwei Zyklen in allen Gruppen |
| Die Fairness wird als fair empfunden | Gespräche nach einem vollen Zyklus | Wiederholte Beschwerden über dieselbe Regel |
| Der Kalenderexport funktioniert bei den verbreiteten Kalendern | Import in Apple Kalender, Google Kalender, Outlook, Android-Standardkalender | Ein Hauptkalender importiert fehlerhaft |

### 6.7 Was bewusst nicht gemacht wird

Keine gekauften Bewertungen, keine Fake-Accounts, keine irreführenden Einladungen, keine Kontaktbuch-Uploads, keine aggressiven Mitteilungen, keine künstliche Verknappung, keine Belohnungen für Einladungen, keine Versprechen, dass die App «sicher viral» werde.

---

## 7. Screens, Design und MVP-Funktionsumfang

### 7.1 Navigationsstruktur

Eine Tab-freie, listenbasierte Struktur: **Übersicht → Plan → (Bearbeiten | Teilen | Tausch)**, dazu **Einstellungen** über ein Zahnradsymbol. Der Erstell-Assistent ist ein modaler Ablauf mit vier Schritten. Alles ist mit einer Hand bedienbar; Hauptaktionen sitzen unten.

### 7.2 Vollständige Liste der Screens

| Nr. | Screen | Inhalt | Bedienelemente | Navigation |
|---|---|---|---|---|
| S1 | **Übersicht** | Liste aller Pläne (Name, Symbol, «Nächster Termin: Fr 3.10. – Anna»). Oben Zusammenfassung «Heute: Anna (Znüni)». Leerer Zustand mit Erklärung. | «+» (neuer Plan), Zahnrad (Einstellungen), Wischen zum Löschen (mit Bestätigung), «Beispiel ansehen» im leeren Zustand | Tippen → S3 |
| S2a | **Neuer Plan: Name** | Textfeld Name, Symbol-Auswahl (eigene Symbole), Farbakzent | Textfeld, Symbolraster, «Weiter», «Abbrechen» | Modal, → S2b |
| S2b | **Neuer Plan: Personen** | Liste der Vornamen, Hinzufügen per Return, optional Gewicht (Stepper 0.5/1/2), Avatar mit Initialen | Textfeld, Liste mit Löschen, Gewicht-Stepper, «Weiter», «Zurück» | → S2c; Mindestens 2 Personen sonst Hinweis |
| S2c | **Neuer Plan: Rhythmus** | Auswahl: täglich, Werktage, wöchentlich (Wochentag), alle zwei Wochen, monatlich (n-ter Wochentag oder Datum). Personen pro Termin 1/2. | Segmentierte Steuerung, Wochentag-Auswahl, Stepper | → S2d |
| S2d | **Neuer Plan: Zeitraum** | Startdatum, Dauer (Wochen/Monate) oder Enddatum, Vorschau «ergibt 12 Termine» | Datumswähler, Stepper, «Plan erstellen» | → S3 |
| S3 | **Plan-Detail** | Termine nach Monat gruppiert, nächster Termin hervorgehoben, Zuweisungen als Avatare, Markierungen «manuell», «übersprungen», «offen». Fairness-Zeile «Anna 3×, Ben 3×, Cara 2×». | «Teilen» (primär, unten), Menü: Personen & Abwesenheiten, Rhythmus & Zeitraum, Neu berechnen, Termin überspringen, Plan umbenennen, Löschen; Tippen auf Termin → S6 | ← S1; → S4, S5, S6, S7 |
| S4 | **Personen & Abwesenheiten** | Personenliste mit Gewicht und aktiv/inaktiv; pro Person Liste der Abwesenheiten | Hinzufügen, Bearbeiten, Deaktivieren (statt Löschen, um Historie zu wahren), «Abwesenheit hinzufügen» | → S5 |
| S5 | **Abwesenheit hinzufügen** | Von/Bis, optionaler Hinweis («Ferien») | Zwei Datumswähler, Speichern | ← S4; Nach Speichern Hinweis «Zukünftige Termine neu berechnen?» |
| S6 | **Termin bearbeiten / Tausch** | Datum, aktuelle Zuweisung, Aktionen: mit anderem Termin tauschen (Auswahl aus Liste), Person manuell setzen, Termin überspringen, Notiz | Auswahlliste, Schalter, Speichern | ← S3 |
| S7 | **Teilen** | Grosse Vorschau des Bildes (hell/dunkel), Formatwahl: Bild, Text, Kalender (alle), Kalender (pro Person mit Personenauswahl), Schalter «Hinweiszeile anzeigen» (Standard an) | Segmentierte Steuerung, Personenauswahl, «Teilen» öffnet System-Share-Sheet | ← S3 |
| S8 | **Einstellungen** | Erinnerungen an mich (aus/an, Zeitpunkt), Hinweiszeile beim Teilen, Erscheinungsbild (System/hell/dunkel), Sprache (Systemhinweis), Daten exportieren/importieren, Alle Daten löschen, Datenschutz, Impressum, Kontakt/Support, Lizenzen, Version | Schalter, Listen, destruktive Aktion mit Bestätigung | → S9, S10 |
| S9 | **Datenschutzhinweise** | Vollständiger Text in der App (zusätzlich zur Webseite), verständlich, kurz: Was gespeichert wird (nur lokal), was nicht, Teilen, Erinnerungen, Kontakt, Rechte | Scrollansicht, Link zur Webversion | ← S8 |
| S10 | **Impressum & Kontakt** | Name, Postadresse, E-Mail (UWG-Mindestangaben [Sekundär]), Support-Hinweis | Kopieren, Mail-Link | ← S8 |
| S11 | **Beispielplan** (aus leerem Zustand) | Vorgefertigter Plan mit erfundenen Namen, alle Funktionen ausprobierbar, klar als Beispiel markiert | «Als Vorlage übernehmen», «Schliessen» | ← S1 |

### 7.3 Wichtige Zustände und Sonderfälle

| Situation | Verhalten |
|---|---|
| Keine Pläne | Leerer Zustand mit einem Satz, Knopf «Ersten Plan erstellen», Link «Beispiel ansehen» |
| Weniger als zwei Personen | «Weiter» deaktiviert, Hinweis «Mindestens zwei Personen» |
| Enddatum vor Startdatum, Dauer 0 | Eingabe wird abgefangen, klare Meldung, kein Absturz |
| Alle Personen an einem Termin abwesend | Termin wird als **«offen»** markiert (orange), Plan bleibt gültig, Hinweis oben im Plan |
| Neuberechnung nach Änderung | Vergangene Termine bleiben unverändert; manuelle Zuweisungen bleiben geschützt, ausser der Nutzer wählt «auch manuelle überschreiben» |
| Person deaktiviert | Zukünftige Zuweisungen werden neu berechnet; Historie bleibt; Person kann reaktiviert werden |
| Sehr viele Personen oder langer Zeitraum (z. B. 50 Personen, 365 Termine) | Berechnung bleibt unter einer Sekunde; Liste ist lazy geladen; Bild wird ab einer Grenze automatisch in mehrere Seiten geteilt |
| Teilen abgebrochen | Keine Änderung, kein Fehler |
| Mitteilungsberechtigung verweigert | Funktion bleibt aus, Erklärung mit Sprung in die System-Einstellungen; keine wiederholten Nachfragen |
| Schlechte oder keine Verbindung | Irrelevant: Die App braucht kein Netz. Einzig die Links auf Webseiten in den Einstellungen zeigen bei Fehlern die Systemmeldung. |
| Speicher voll / Datenbankfehler | Fehlermeldung in verständlicher Sprache, letzte Eingabe bleibt im Speicher, Vorschlag «Export erstellen» |
| App-Update mit Datenmodell-Änderung | Versionierte Migration mit Tests; vor Migration automatischer lokaler Export |
| Zeitumstellung, Schaltjahr, Monate mit 28 bis 31 Tagen | Termine sind Kalendertage (keine Uhrzeiten); Berechnung über Kalenderkomponenten; Tests decken März/Oktober und den 29. Februar ab |
| Löschung eines Plans | Bestätigungsdialog mit Nennung des Namens; Löschung sofort und vollständig; kein Papierkorb (Einfachheit), aber vorheriger Export möglich |
| Alle Daten löschen | Zwei Schritte, danach leerer Zustand; keine Daten irgendwo sonst, weil nichts übertragen wurde |
| Import einer beschädigten JSON-Datei | Validierung, verständliche Fehlermeldung, kein Teilimport |
| Kalenderimport beim Empfänger schlägt fehl | FAQ auf der Webseite; .ics folgt RFC 5545, Ganztages-Termine, stabile UIDs |

### 7.4 Designrichtung

- **Typografie:** Systemschrift (SF Pro) mit Dynamic Type bis zu den Barrierefreiheits-Grössen; klare Hierarchie (Titel, Termin-Datum, Namen). Keine Fremdschriften, keine Lizenzfragen.
- **Farben:** ein ruhiger Primärakzent (Vorschlag: ein tiefes Blaugrün), semantische Systemfarben für Zustände (offen = Orange, übersprungen = Grau, manuell = kleines Symbol statt nur Farbe, damit Farbenblindheit kein Problem ist). Hell- und Dunkelmodus von Anfang an. Kontrast mindestens WCAG AA.
- **Bildsprache:** keine Fotos, keine Illustrationen von realen Personen. Initialen-Avatare mit Farbe. Das geteilte Bild ist eine saubere «Karte»: Titel, Zeitraum, Zeilen mit Datum und Namen, Fusszeile. Eigenes App-Icon (selbst gestaltet oder beauftragt; **keine SF Symbols als Icon** [Sekundär]).
- **Bedienung:** grosse Trefferflächen (mindestens 44 pt), Hauptaktion unten erreichbar, keine Gesten ohne sichtbare Alternative, VoiceOver-Labels für alle Avatare und Zustände («Anna, dran am Freitag 3. Oktober, manuell zugewiesen»), Reduce Motion respektiert, keine reinen Farbkodierungen.
- **Ton:** knapp, freundlich, ohne Ausrufezeichen-Inflation. Schweizer Schreibweise (ss), FR/IT/EN vorbereitet.

### 7.5 MVP-Funktionsumfang als Abnahmeliste

- [ ] Plan erstellen mit Name, Symbol, Personen (Gewicht), Rhythmus, Zeitraum
- [ ] Abwesenheiten pro Person; Termine überspringen
- [ ] Fairness-Engine mit dokumentierten Invarianten und Unit-Tests
- [ ] Historie eingefroren, Zukunft neu berechenbar, manuelle Zuweisungen geschützt
- [ ] Tausch zweier Termine
- [ ] Teilen: Bild (hell/dunkel), Text, .ics gesamt und pro Person, Hinweiszeile schaltbar
- [ ] Optionale lokale Erinnerung an die organisierende Person
- [ ] Export/Import JSON über Dateien-App; «Alle Daten löschen»
- [ ] Datenschutzhinweise, Impressum, Kontakt, Lizenzen in der App
- [ ] Deutsch vollständig; FR/IT/EN als Strings vorbereitet
- [ ] Dynamic Type, VoiceOver, Kontrast, Reduce Motion geprüft
- [ ] Keine Netzwerkaufrufe (nachgewiesen), keine Drittanbieter-SDKs

---

## 8. Technische Architektur, Aufwand und laufende Kosten

### 8.1 Grundsatzentscheid: lokale App ohne Backend

Der gesamte Funktionsumfang (Pläne berechnen, anzeigen, exportieren) benötigt keine Server. Ein Backend wäre nur für gemeinsames Bearbeiten nötig, das bewusst nicht Teil des Konzepts ist. Konsequenzen:

- Keine Personendaten bei dir. Keine Datenpanne auf deiner Seite möglich, keine Auskunfts- oder Löschprozesse für Serverdaten, keine Hosting-Kosten, keine Verfügbarkeitspflicht.
- Das App-Privacy-Label kann «Daten werden nicht erfasst» lauten, sofern kein Netzwerkcode existiert [Belegt: On-Device-Verarbeitung gilt nicht als Erhebung].
- Die App funktioniert offline und im Flugmodus vollständig.

### 8.2 Plattform und Technologie

| Baustein | Wahl | Begründung |
|---|---|---|
| Sprache / UI | Swift, SwiftUI | Apple-Standard, kleinste Abhängigkeitsfläche, gute Barrierefreiheit von Haus aus |
| Persistenz | SwiftData (lokaler Store) | Apple-Framework, keine Drittbibliothek; Migrationen versionierbar |
| Mindestversion | iOS 18; Zielversion iOS 27 [Sekundär: iOS 27 seit 14.09.2026] | Reduziert die Testmatrix; SwiftData ist ab iOS 17 verfügbar, ab iOS 18 ausgereift. Vor Start prüfen, welche Versionen die Zielgruppe nutzt. |
| Geräte | iPhone (Hochformat, alle aktuellen Grössen); iPad-Unterstützung optional als «iPhone-App auf iPad» | Fokus |
| Drittanbieter-SDKs | **Keine** | Kein Datenschutz-, Lizenz- oder Sicherheitsrisiko durch Fremdcode |
| Netzwerk | **Kein** Netzwerkcode in der App; nur System-Links (Safari) zu Datenschutz/Impressum | Prüfbar: Suche nach URLSession im Code muss leer bleiben; Netzwerkmitschnitt beim Test |
| Export | ShareLink / UIActivityViewController, ImageRenderer für das Bild, eigener .ics-Generator | Systembordmittel |
| Mitteilungen | UserNotifications (lokal) | Kein Push-Server |
| Tests | XCTest (Unit, UI), Swift Testing | Fairness-Engine ist vollständig testbar |

### 8.3 Datenmodell

```
Plan
  id: UUID
  name: String
  symbol: String (eigener Symbolname)
  colorIndex: Int
  rhythm: Rhythm (enum: daily, weekdays, weekly(weekday), biweekly(weekday, anchorDate), monthlyNthWeekday(n, weekday), monthlyDay(day))
  startDate: DateComponents (Kalendertag)
  endDate: DateComponents
  slotSize: Int (1 oder 2)
  showAttribution: Bool
  createdAt, updatedAt: Date
  members: [Member]
  slots: [Slot]

Member
  id: UUID
  name: String (Vorname oder Kürzel)
  weight: Double (0.5 / 1 / 2)
  colorIndex: Int
  isActive: Bool
  absences: [Absence]

Absence
  id: UUID
  start: DateComponents
  end: DateComponents
  note: String?

Slot
  id: UUID
  date: DateComponents
  assignedMemberIDs: [UUID]   // Reihenfolge = Anzeige
  isManual: Bool
  isSkipped: Bool
  note: String?
```

Alle Datumswerte sind **Kalendertage ohne Uhrzeit**, damit Zeitzonen und Zeitumstellungen keine Verschiebungen erzeugen.

### 8.4 Fairness-Engine (deterministisch, erklärbar, testbar)

**Eingaben:** aktive Personen mit Gewicht, Abwesenheiten, Terminliste aus dem Rhythmus, Historie (vergangene und manuelle Termine mit Zuweisungen), Personen pro Termin.

**Verfahren:** Für jeden zukünftigen, nicht manuellen, nicht übersprungenen Termin in Datumsreihenfolge:
1. Kandidatinnen und Kandidaten = aktive Personen, die an diesem Tag nicht abwesend sind.
2. Wähle die benötigte Anzahl Personen mit der **niedrigsten normierten Last** (Anzahl bisheriger Zuweisungen geteilt durch Gewicht).
3. Bei Gleichstand: die Person, deren letzte Zuweisung am längsten zurückliegt; bei weiterem Gleichstand: stabile Ausgangsreihenfolge.
4. Zuweisung speichern, Zähler erhöhen.
5. Keine Kandidaten: Termin als «offen» markieren.

**Invarianten (werden als Unit-Tests festgeschrieben):**
- Bei gleichen Gewichten und ohne Abwesenheiten unterscheiden sich die Zuweisungszahlen aller Personen nach jedem Präfix höchstens um 1.
- Niemand wird an einem Tag zugewiesen, an dem er oder sie abwesend ist.
- Die Berechnung ist deterministisch: gleiche Eingaben ergeben denselben Plan.
- Vergangene und manuelle Termine werden nie verändert, es sei denn, der Nutzer verlangt es ausdrücklich.
- Zwei Personen pro Termin sind immer verschieden.
- Gewichte wirken proportional (Gewicht 0.5 ergibt über lange Zeiträume ungefähr halb so viele Zuweisungen).

**Erklärbarkeit:** Im Plan zeigt eine Zeile die Zuweisungszahlen. Auf Tippen wird erklärt: «Cara ist seltener dran, weil sie zwei Wochen abwesend war. Das gleicht sich im nächsten Zyklus aus.»

### 8.5 Export

- **Bild:** Rendering der Plan-Karte in fester Breite (z. B. 1080 px), hell oder dunkel, mit automatischer Seitenteilung ab etwa 25 Terminen. PNG ohne Metadaten über Nutzer oder Gerät.
- **Text:** einfache Liste «Fr 03.10. – Anna», geeignet für Chats.
- **Kalender (.ics):** RFC 5545; ein VEVENT pro Termin; **Ganztages-Termine** (`DTSTART;VALUE=DATE`), stabile `UID` pro Termin (Plan-ID plus Datum), `SEQUENCE` wird bei Änderung erhöht, `PRODID` als Herkunft, optionaler `VALARM` (z. B. Vortag 18:00). Pro-Person-Export filtert die Termine der gewählten Person. Textfelder werden gemäss RFC escaped (Komma, Semikolon, Zeilenumbruch).
- Prüfung mit Apple Kalender, Google Kalender, Outlook und einem Android-Standardkalender ist Teil der Abnahme.

### 8.6 Apple-Berechtigungen, Privacy Manifest, App-Privacy-Label

| Bereich | Angabe |
|---|---|
| Berechtigungen | **Keine erforderlich.** Optional: Mitteilungen (nur nach ausdrücklicher Aktivierung durch den Nutzer). Kein Standort, keine Kamera, keine Fotos, keine Kontakte, kein Mikrofon, kein Tracking. |
| Purpose Strings | Nur für Mitteilungen wird kein Purpose String benötigt (Systemdialog); dennoch erklärt die App vorab, wofür die Erinnerung dient. |
| Privacy Manifest (PrivacyInfo.xcprivacy) | `NSPrivacyTracking = false`; keine Tracking-Domains; keine erhobenen Datentypen; Required-Reason-API für UserDefaults (Einstellungen) mit dem zutreffenden Begründungscode; weitere Codes nur, wenn tatsächlich verwendet [Sekundär: Codes vor Einreichung in der Apple-Dokumentation prüfen] |
| App-Privacy-Label | «Daten werden nicht erfasst», sofern der Code keine Übertragung enthält [Belegt: Kriterium] |
| App Tracking Transparency | Nicht anwendbar (kein Tracking) |
| Konto/Anmeldung | Keine; damit entfällt auch die Pflicht zur Kontolöschung (5.1.1 (v)) [Belegt] |

### 8.7 Technische Sicherheit

| Thema | Massnahme |
|---|---|
| Datenschutz auf dem Gerät | Standard-Dateischutz von iOS (verschlüsselt, an Gerätecode gebunden); Schutzklasse «vollständig bis zur ersten Entsperrung», damit lokale Erinnerungen funktionieren. Die Daten sind nicht hochsensibel (Vornamen, Daten). |
| Angriffsfläche | Kein Netzwerk, kein Server, keine Konten, keine URL-Schemata mit Nutzlast in Version 1. Import nur über die Dateien-App mit strikter Validierung (Schema, Grössenlimit, keine Code-Ausführung). |
| Abhängigkeiten | Keine Drittbibliotheken. Damit keine Lieferketten-Risiken durch Fremdcode; Xcode und iOS-SDK aktuell halten. |
| Eingaben | Längenbegrenzung für Namen und Notizen; Escaping in .ics und im Text-Export; keine Interpretation von Eingaben. |
| Ausfall und Datenverlust | Daten liegen im App-Container und sind Teil des iCloud- oder Computer-Backups des Nutzers (Systemfunktion). Zusätzlich manueller JSON-Export. Vor Migrationen automatischer Export. |
| Fehlerbehandlung | Alle Speicher- und Exportfehler werden abgefangen und verständlich angezeigt; kein Datenverlust der aktuellen Eingabe; kein stilles Verschlucken. |
| Absturzberichte | Nur Apples systemeigene, vom Nutzer freigegebene Berichte über Xcode Organizer; kein Crash-SDK. |
| Vorgehen bei Sicherheitsvorfällen | Kontaktadresse für Meldungen auf Webseite und in der App; Ziel: Bestätigung innerhalb weniger Tage, Fix als App-Update; da keine Serverdaten existieren, ist ein «Leak» auf deiner Seite ausgeschlossen, aber Fehler in der App (z. B. Export falscher Daten) werden wie Vorfälle behandelt und dokumentiert. |
| Updates | Jährlich mit neuem iOS testen und bauen; Deprecations beheben; Datenschutztexte jährlich prüfen. |

### 8.8 Wartung durch eine Einzelperson

- Support über ein E-Mail-Postfach; FAQ auf der Webseite (Kalenderimport, Rhythmus, Tausch).
- Erwarteter Aufwand nach Veröffentlichung: wenige Stunden pro Monat, plus ein grösseres Update pro Jahr (iOS-Release) [Einschätzung].
- Kein Bereitschaftsdienst nötig, weil nichts «ausfallen» kann, was Dritte betrifft.

### 8.9 Kosten

| Posten | Betrag | Status |
|---|---|---|
| Apple Developer Program | 99 USD pro Jahr (regional in Landeswährung) | [Belegt] |
| Mac mit Xcode, iPhone zum Testen | Vorausgesetzt (Annahme A2); sonst Anschaffung | Annahme |
| Domain für Datenschutz/Impressum/Support | Grössenordnung wenige Dutzend Franken pro Jahr; Hosting einer statischen Seite ist kostenlos möglich | [Einschätzung] |
| App-Icon (falls beauftragt) | Wenige hundert Franken; alternativ selbst gestaltet | [Einschätzung] |
| Juristische Kurzprüfung (Datenschutzerklärung, Impressum, Name) | Einige Stunden Anwaltszeit; Tarif erfragen | [Offen] |
| Markenrecherche / optionale Markenanmeldung | Recherche selbst möglich (kostenlos); Anmeldung optional, Gebühren beim IGE erfragen | [Offen] |
| Laufende Betriebskosten (Server, Datenbanken, Push) | **Keine** | Architekturentscheid |
| Übersetzungen FR/IT/EN | Selbst oder Freelancer; Grössenordnung kleiner Betrag pro Sprache | [Einschätzung] |

### 8.10 Aufwand (Schätzung, abhängig von Erfahrung; keine Zusage)

| Phase | Aufwand (Teilzeit, eine Person) |
|---|---|
| Gespräche und klickbarer Prototyp | 1 bis 2 Wochen |
| MVP inkl. Fairness-Engine, Export, Tests | 4 bis 8 Wochen |
| TestFlight mit Gruppen über zwei Zyklen | 3 bis 6 Wochen Kalenderzeit (wenig Arbeitszeit) |
| Sicherheits- und Datenschutzprüfung, Rechtstexte | 1 bis 2 Wochen |
| App-Store-Vorbereitung und Einreichung | 1 Woche |
| **Gesamt** | **etwa 3 bis 4 Monate Kalenderzeit** [Einschätzung] |

---

## 9. Risikoanalyse

Skala: Wahrscheinlichkeit und Schwere jeweils gering / mittel / hoch. Die Einschätzungen sind fachliche Bewertungen [Einschätzung], keine Rechtsauskunft. «Externe Prüfung» nennt, was eine qualifizierte Fachperson für den Einzelfall beurteilen muss.

| Risiko | Mögliche Folge | Wahrscheinlichkeit | Schwere | Gegenmassnahme | Restrisiko | Erforderliche externe Prüfung |
|---|---|---|---|---|---|---|
| **Unvollständige oder fehlende Datenschutzerklärung** (DSG Art. 19 [Sekundär]; Apple 5.1.1 (i) [Belegt]) | Apple-Ablehnung; theoretisch Busse bei vorsätzlicher Verletzung der Informationspflicht | gering | mittel | Kurze, wahre Datenschutzerklärung in der App und auf der Webseite: keine Erhebung, lokale Speicherung, Teilen über System, Erinnerungen lokal, Apple als Plattform, Kontakt, Rechte; jährliche Prüfung | gering | Juristische Kurzprüfung des Textes; Primärquelle DSG lesen |
| **Fehlendes Impressum** (UWG Art. 3 Abs. 1 lit. s [Sekundär]) | Unlauterkeitsvorwurf, Abmahnung durch Mitbewerber | gering | gering bis mittel | Name, Postadresse, E-Mail in App und Webseite bereitstellen, auch wenn Anwendbarkeit auf eine kostenlose App umstritten ist | sehr gering | Bestätigung der Anwendbarkeit; Prüfung, ob eine c/o-Adresse zulässig ist, falls du deine Privatadresse nicht zeigen willst |
| **Namens- oder Markenkonflikt** («Reihum» oder Alternative) | Abmahnung, Umbenennung, App-Entfernung | mittel | mittel | Markenrecherche vor Festlegung; kein Bezug zu fremden Marken; Alternativnamen bereithalten | gering | Markenrecherche durch Fachperson, falls Eigenrecherche Treffer zeigt |
| **Apple-Ablehnung** (4.2 Minimalfunktion, 4.3(b) Klon, 2.1 Vollständigkeit, 2.3 Metadaten) [Belegt] | Verzögerung; bei wiederholten Verstössen Kontoentzug | gering bis mittel | mittel | Fairness-Engine und Export als sichtbarer Kern; ehrliche Metadaten; vollständige, getestete Einreichung; Notes for Review mit Beschreibung | gering | Keine; Guidelines unmittelbar vor Einreichung erneut lesen |
| **Falsche App-Privacy-Angaben** | Entfernung, Vertrauensverlust | gering | hoch | Code enthält keinen Netzwerkzugriff; Label «Daten werden nicht erfasst» nur, wenn das nachgewiesen ist; bei jeder Änderung Label prüfen | sehr gering | Keine |
| **Datenverlust beim Nutzer** (Gerätewechsel ohne Backup, versehentliches Löschen) | Ärger, negative Bewertung; kein rechtlicher Anspruch erkennbar, aber Beschwerden möglich | mittel | gering | Systembackup, JSON-Export, Bestätigungsdialoge, klare Hinweise; keine Versprechen zur Aufbewahrung | gering | Keine |
| **Als unfair empfundene Pläne, Fehler in der Engine** | Beschwerden, schlechte Bewertungen | mittel | gering | Invarianten-Tests, Erklärbarkeit, Tausch und manuelle Zuweisung, Feedback-Kanal | gering | Keine |
| **Fehler in der Kalenderarithmetik** (Zeitumstellung, Schaltjahr, Monatsenden) | Falsche Daten im geteilten Plan | gering | mittel | Kalendertage statt Zeitstempel; Tests für März/Oktober, 29. Februar, 31. eines Monats | gering | Keine |
| **Kalenderimport-Probleme bei Empfängern** | Support-Last, Vertrauensverlust | mittel | gering | RFC-konforme .ics, Ganztages-Termine, Tests mit vier Kalendern, FAQ | gering | Keine |
| **Weitergabe von Namen Dritter durch den Nutzer** (Kolleginnen, Vereinsmitglieder) | Beschwerde einer genannten Person gegen den Nutzer; Reputationsrisiko für die App | gering | gering | Nur Vornamen empfohlen; Hinweis vor dem ersten Teilen; keine Veröffentlichung durch die App; keine Server | sehr gering | Keine; Hinweistext juristisch mitlesen lassen |
| **Missbrauch der App zu belästigenden Zwecken** (z. B. «Pläne» über Personen ohne deren Wissen) | Theoretisch Vorwurf der Beihilfe | sehr gering | gering | Die App hat keine Verbreitungsfunktion; sie ist ein Werkzeug wie eine Notiz-App; keine Sonderfunktionen, die Missbrauch erleichtern | sehr gering | Keine |
| **Geistiges Eigentum**: App-Icon, Symbole, Schriften, Beispielinhalte | Abmahnung, Apple-Ablehnung | gering | mittel | Eigenes Icon; SF Symbols nur in der App, nicht als Icon oder Logo [Sekundär]; Systemschriften; erfundene Beispielnamen ohne Bezug zu realen Personen; keine fremden Bilder | sehr gering | Lizenztext SF Symbols in Xcode lesen |
| **Open-Source-Lizenzpflichten** | Verstoss gegen Lizenzbedingungen | sehr gering | gering | Keine Drittbibliotheken in Version 1; falls später doch, Lizenzhinweise-Screen pflegen | sehr gering | Keine |
| **Sicherheitslücke in der App** (z. B. Import) | Absturz, Datenkorruption | gering | gering | Strikte Validierung; kein Netzwerk; Fuzz-Tests für Import und .ics | sehr gering | Keine |
| **Persönliche Exposition**: bürgerlicher Name im App Store [Belegt]; bei EU-Vertrieb Adresse/Telefon/E-Mail öffentlich [Belegt] | Unerwünschte Kontaktaufnahme, Spam | mittel (Name), hoch (bei EU) | gering bis mittel | Separates Support-Postfach; vorerst kein EU-Vertrieb; Prüfung von Postfach- oder c/o-Lösungen; später Firma als Anbieter denkbar | mittel | Bei EU-Expansion: Zulässigkeit von Postfach-Adressen prüfen (Apple akzeptiert laut Hilfe eine P.O. Box mit Nachweis) |
| **Spätere Monetarisierung**: Verbraucherschutz, Preisangabe, In-App-Kauf-Regeln, Steuern | Apple-Ablehnung, Beanstandung, Steuernachforderung | gering | mittel | Erst nach Validierung; Einmalkauf; Apple-Regeln 3.1.1 [Belegt]; klare Beschreibung; Steuerberatung | gering | Steuer- und Verbraucherschutzberatung vor Einführung |
| **Barrierefreiheitsanforderungen bei Expansion** (EU European Accessibility Act) | Beanstandung in EU-Ländern | gering | gering | Barrierefreiheit von Anfang an; Kleinstunternehmen-Ausnahmen prüfen | gering | Prüfung vor EU-Vertrieb [Offen] |
| **Übersetzungsfehler FR/IT** | Missverständnisse, negative Bewertungen | mittel | gering | Muttersprachliche Prüfung vor Freigabe der Sprache; Sprache erst freischalten, wenn geprüft | gering | Keine |
| **Support-Last und Überlastung der Einzelperson** | Verzögerte Antworten, Qualitätsverlust | gering | gering | FAQ, klare Erwartungssetzung («Antwort innerhalb einiger Tage»), keine Verfügbarkeitszusagen | gering | Keine |
| **Unbegründete Beschwerde, Abmahnung oder Klage trotz allem** | Zeit, Kosten, Stress | gering | mittel | Saubere Dokumentation aller Entscheidungen (dieses Dokument), Rechtstexte, keine Versprechen; Rechtsschutzversicherung prüfen | **bleibt bestehen** | Beratung im Einzelfall |
| **Änderung der Apple-Regeln oder Gesetze** | Nachbesserungsbedarf | mittel | gering | Vor jeder Einreichung Guidelines prüfen; jährliche Prüfung der Rechtstexte | gering | Keine |

**Zusammenfassung:** Kein identifiziertes Risiko liegt in der Kombination «hohe Wahrscheinlichkeit und hohe Schwere». Die höchsten verbleibenden Risiken sind der Namens-/Markenkonflikt (vermeidbar durch Recherche) und die persönliche Exposition als Einzelanbieter (mindern, nicht beseitigen). Das allgemeine Restrisiko einer unbegründeten Beschwerde bleibt bestehen und kann durch keine Massnahme auf null gebracht werden.

---

## 10. Entwicklungsphasen und konkrete Tests

### 10.1 Phasen mit Ergebnis und Abbruchkriterium

| Phase | Inhalt | Ergebnis | Abbruch- oder Anpassungskriterium |
|---|---|---|---|
| **0 Problemvalidierung** | 5 bis 8 Gespräche mit Personen, die heute einen Turnus organisieren (Team, WG, Elternrat, Verein). Fragen: Wie machst du es heute? Was nervt? Was passiert bei Abwesenheiten? | Notizen, bestätigte oder verworfene Problemhypothese | Weniger als die Hälfte bestätigt das Problem klar → Idee 2 (Garantie-Tresor) als Rückfall prüfen |
| **1 Klickbarer Prototyp** | SwiftUI-Prototyp mit statischen Daten: Erstell-Assistent, Plan-Ansicht, Teilen-Vorschau. Keine Persistenz nötig. | Getesteter Ablauf mit 3 bis 5 Personen; Zeit bis zum ersten Plan gemessen | Median über 3 Minuten oder wiederholte Verwirrung im Assistenten → Ablauf vereinfachen, bevor MVP startet |
| **2 MVP** | Fairness-Engine mit Tests, Persistenz, Abwesenheiten, Tausch, Export (Bild/Text/.ics), Erinnerung, Export/Import, Rechtstexte-Platzhalter, Barrierefreiheit | Lauffähige App auf eigenem Gerät, alle Abnahmepunkte aus 7.5 erfüllt | Engine verletzt Invarianten oder Export scheitert in einem Hauptkalender → nicht in Phase 3 gehen |
| **3 Test mit wenigen Personen (TestFlight)** | 5 bis 10 Organisierende, mindestens zwei volle Zyklen, Feedback-Runde nach jedem Zyklus. Hinweis: externe TestFlight-Tests durchlaufen eine Apple-Vorprüfung [bekannt, nicht neu geprüft] | Fehlerliste, Priorisierung, Antworten auf die Annahmen aus 6.6 | Weniger als die Hälfte teilt den Plan oder erstellt einen zweiten Zyklus → Ursache klären; ggf. Positionierung ändern oder stoppen |
| **4 Sicherheits- und Datenschutzprüfung** | Netzwerkmitschnitt (kein Traffic), Code-Suche nach Netzwerk-APIs, Privacy Manifest, Schutzklasse, Import-Fuzzing, Rechtstexte final, Namensprüfung | Prüfprotokoll; freigegebene Rechtstexte; Name festgelegt | Offene juristische Frage → keine Einreichung |
| **5 App-Store-Vorbereitung** | Metadaten, Screenshots, Datenschutz-Label, Altersfragebogen, Support-URL, Datenschutz-URL, Notes for Review, Build | Einreichungsbereiter Stand | Checkliste (Abschnitt 11) nicht vollständig → warten |
| **6 Entscheidung über die Veröffentlichung** | Go-/No-Go anhand Abschnitt 12 | Dokumentierte Entscheidung | Jeder offene Punkt der Kategorie «wesentlich» → No-Go |

### 10.2 Konkrete Tests

**Unit-Tests (Fairness-Engine, Rhythmus, Export)**
- Gleiche Gewichte, keine Abwesenheiten: Differenz der Zuweisungszahlen ≤ 1 nach jedem Präfix (Zufallseingaben, 1000 Läufe).
- Abwesenheiten werden nie verletzt (Property-Test).
- Determinismus: zwei Läufe mit gleichen Eingaben sind identisch.
- Gewicht 0.5 und 2: Verhältnis der Zuweisungen über 200 Termine innerhalb einer Toleranz.
- Zwei Personen pro Termin: nie dieselbe Person doppelt; bei nur einer verfügbaren Person Termin teilweise offen.
- Historie bleibt unverändert nach Neuberechnung; manuelle Termine geschützt.
- Rhythmus-Generator: Werktage über Wochenenden, «erster Montag im Monat», «Tag 31» in Monaten mit 30 Tagen (Regel dokumentiert: letzter Tag des Monats), Zeitumstellung März/Oktober, 29. Februar 2028.
- .ics: gültige Struktur, Escaping von Komma/Semikolon/Zeilenumbruch in Namen und Notizen, stabile UIDs, SEQUENCE-Erhöhung nach Änderung, Pro-Person-Filter.
- JSON-Import: Ablehnung ungültiger Dateien, Grössenlimit, Schema-Versionen, keine Teilimporte.

**UI- und Gerätetests**
- iPhone-Grössen: kleinstes unterstütztes Modell (kompakte Breite), Standard, Max-Grösse; Hoch- und Querformat, falls Querformat freigegeben.
- iOS-Versionen: Mindestversion (iOS 18) und aktuelle Version (iOS 27) auf Gerät oder Simulator; ein Zwischenstand (iOS 26).
- Hell/Dunkel, Dynamic Type bis zur grössten Barrierefreiheits-Stufe (kein abgeschnittener Text, kein überlappender Avatar).
- VoiceOver: vollständige Navigation durch Assistent, Plan, Teilen; sinnvolle Labels; Reihenfolge.
- Reduce Motion, erhöhter Kontrast, Fett-Text.
- Leerer Zustand, 2 Personen, 50 Personen, 365 Termine (Leistung, Bildteilung).
- Mitteilungen: erlaubt, abgelehnt, später in Einstellungen geändert.
- Export: Teilen in Nachrichten, Mail, WhatsApp-ähnliche Apps (soweit installiert), Dateien-App; Import der .ics in Apple Kalender, Google Kalender (Web), Outlook, Android-Standardkalender.
- Datenlöschung: Plan löschen, alle Daten löschen, App löschen und neu installieren (keine Restdaten ausser Systembackup).
- Migration: Installation einer älteren Build-Version, Daten anlegen, Update einspielen.
- Netzwerk: Mitschnitt über den gesamten Testlauf zeigt keinen Traffic der App.

**Verständlichkeit**
- Fünf Personen ohne Vorwissen erklären nach 30 Sekunden auf dem App-Store-Eintrag, was die App tut.
- Texte in DE durch eine zweite Person gegengelesen; FR/IT/EN erst nach muttersprachlicher Prüfung freischalten.

---

## 11. App-Store- und Veröffentlichungs-Checkliste

### 11.1 Funktion und Qualität
- [ ] Alle Abnahmepunkte aus 7.5 erfüllt; alle Tests aus 10.2 bestanden und protokolliert
- [ ] Keine Abstürze in TestFlight über mindestens zwei Wochen
- [ ] Getestet auf Mindest- und aktueller iOS-Version sowie kleinster und grösster Gerätegrösse

### 11.2 Fehlerfälle, Berechtigungen, Löschung
- [ ] Alle Sonderfälle aus 7.3 manuell durchgespielt
- [ ] Mitteilungsberechtigung: Verweigerung wird respektiert, keine Endlosschleifen
- [ ] «Alle Daten löschen» entfernt sämtliche App-Daten; Export/Import funktioniert

### 11.3 Barrierefreiheit und Verständlichkeit
- [ ] VoiceOver, Dynamic Type, Kontrast, Reduce Motion geprüft
- [ ] Texte kurz, konsistent, Schweizer Schreibweise; keine Fachbegriffe ohne Erklärung

### 11.4 Sicherheit und Abhängigkeiten
- [ ] Keine Drittanbieter-SDKs; Abhängigkeitsliste ist leer
- [ ] Kein Netzwerkcode; Mitschnitt protokolliert
- [ ] Privacy Manifest vollständig und aktuell (Required-Reason-Codes geprüft) [Sekundär → prüfen]
- [ ] Import-Validierung und Fuzz-Tests bestanden
- [ ] Sicherheitskontakt auf Webseite und in der App

### 11.5 Texte, Screenshots, Werbeaussagen
- [ ] App-Name, Untertitel, Beschreibung, Schlüsselwörter wahrheitsgemäss; keine Versprechen wie «garantiert fair für alle Fälle»
- [ ] Screenshots zeigen reale Funktionen der eingereichten Version (Apple 2.3 [Belegt]); Beispielnamen erfunden
- [ ] Keine Erwähnung fremder Marken (z. B. Messenger-Namen) in Metadaten, ausser wo Apple es ausdrücklich zulässt
- [ ] Datenschutz-Label «Daten werden nicht erfasst» nur, wenn nachgewiesen

### 11.6 Rechte an Inhalten
- [ ] App-Icon selbst erstellt oder mit schriftlicher Lizenz; kein SF Symbol als Icon [Sekundär → Lizenz lesen]
- [ ] Schriften: nur Systemschriften
- [ ] Symbole in der App: SF Symbols gemäss Lizenz oder eigene
- [ ] Beispielinhalte frei erfunden, keine realen Personen, keine fremden Texte
- [ ] Nachweise (Rechnungen, Lizenztexte) archiviert

### 11.7 Datenschutzinformationen und Rechtstexte
- [ ] Datenschutzerklärung (DE, später FR/IT/EN) in der App und unter öffentlicher URL; Inhalt: Verantwortlicher mit Kontakt, keine Erhebung, lokale Speicherung, Teilen über Systemfunktionen, lokale Erinnerungen, App-Store-Verarbeitung durch Apple, Rechte (Auskunft/Löschung sinngemäss: alles liegt beim Nutzer), Änderungsdatum
- [ ] Impressum mit Name, Postadresse, E-Mail (UWG [Sekundär])
- [ ] Nutzungsbedingungen: Apples Standard-EULA genügt vorerst (keine Sonderregeln nötig) [Einschätzung, prüfen lassen]
- [ ] Juristische Kurzprüfung dieser Texte erfolgt und dokumentiert [Offen]

### 11.8 App-Store-Angaben
- [ ] Kategorie: Produktivität (primär), Dienstprogramme (sekundär)
- [ ] Altersfragebogen wahrheitsgemäss ausgefüllt (keine UGC-Verbreitung, keine Web-Inhalte, keine Werbung, keine Käufe); erwartete Einstufung 4+ [Belegt: Stufen]
- [ ] Support-URL, Datenschutz-URL, Marketing-URL (optional) erreichbar
- [ ] Notes for Review: Beschreibung der Funktionen, Hinweis «keine Anmeldung, kein Netzwerk», Testhinweise
- [ ] Keine In-App-Käufe in Version 1; falls später: Produkte angelegt, sichtbar, «Wiederherstellen» vorhanden (Apple 2.1 (b), 3.1.1 [Belegt])
- [ ] Verfügbarkeit: nur Schweiz; Preis: kostenlos
- [ ] Verkäufername (dein Name) geprüft; separates Support-Postfach

### 11.9 Aktuelle Apple-Regeln und Rechtslage
- [ ] App Review Guidelines am Einreichungstag erneut gelesen (insbesondere 2.1, 2.3, 4.2, 4.3, 5.1.1, 5.1.2)
- [ ] Apple Developer Program License Agreement und Paid Apps Agreement (falls Käufe) in aktueller Fassung akzeptiert
- [ ] DSG Art. 2, 7, 19, 25 und UWG Art. 3 Abs. 1 lit. s an der Primärquelle gelesen [Offen]
- [ ] EDÖB-Merkblätter zur Informationspflicht konsultiert [Offen]

### 11.10 Zusätzliche Anforderungen bei späterer Ausweitung (nicht Teil der ersten Veröffentlichung)

| Region | Zusätzliche Anforderungen (Auswahl, [Belegt] wo markiert, sonst [Offen]) |
|---|---|
| **EU (27 Staaten)** | DSA-Händlerstatus: bei Einnahmen gilt man als Händler; Adresse (oder Postfach mit Nachweis), Telefon, E-Mail werden öffentlich angezeigt [Belegt]. DSGVO-konforme Datenschutzerklärung; Frage eines EU-Vertreters nach Art. 27 DSGVO ist bei fehlender Datenverarbeitung zu klären [Offen]. Verbraucherrecht für digitale Inhalte (Widerruf läuft über Apple). European Accessibility Act: Anwendbarkeit und Kleinstunternehmen-Ausnahme prüfen [Offen]. Apple-EU-Bedingungen: bei reinem App-Store-Vertrieb mit Apple-IAP laut Apple nicht betroffen [Belegt]. Deutschland: Impressumspflicht nach DDG/§ 5 (früher TMG) [Offen]. |
| **USA** | Datenschutzgesetze der Bundesstaaten (CCPA/CPRA u. a.) greifen bei Schwellenwerten, die ein lokales Werkzeug ohne Datenerhebung kaum erreicht; trotzdem englische Datenschutzerklärung [Offen]. COPPA nicht anwendbar, sofern die App nicht an Kinder gerichtet ist; Marketing entsprechend halten [Offen]. Umsatzsteuer bei Käufen übernimmt Apple als Händler der Aufzeichnung; steuerliche Einordnung in der Schweiz prüfen [Offen]. |
| **Vereinigtes Königreich** | UK GDPR, ggf. UK-Vertreter; Online Safety Act voraussichtlich nicht anwendbar (kein UGC-Dienst) [Offen]. |
| **Weitere Länder** | Länderspezifische Datenschutz- und Verbraucherregeln, teilweise Altersfreigabe-Sonderregeln (z. B. Australien, Brasilien, Südkorea gemäss Apple-Hilfe [Belegt]); Lokalisierung; Exportkontrolle für Verschlüsselung (nur Standard-iOS-Verschlüsselung → in App Store Connect als «exempt» deklarierbar) [Offen]. |

**Regel:** Kein Land wird stillschweigend hinzugefügt. Jede Ausweitung durchläuft eine eigene, dokumentierte Kurzprüfung.

---

## 12. Offene Fragen und Go-/No-Go-Einschätzung

### 12.1 Fragen an dich (nur die, ohne die keine verantwortbare Entscheidung möglich ist)

**Entscheidungsprotokoll 29.09.2026:** Frage 1: bürgerlicher Name im App Store ist akzeptiert. Frage 2: Privatadresse im Impressum. Frage 3: erste Version nur Deutsch. Zusätzlich festgehalten: Testgerät iPhone 11 Pro vorhanden; Verfügbarkeit eines Mac mit Xcode noch zu klären.

1. **Öffentlichkeit deines Namens:** Als Einzelperson erscheint dein bürgerlicher Name im App Store [Belegt]. Ist das für dich akzeptabel? Wenn nein, wäre eine spätere Anbieterstruktur (z. B. Einzelfirma mit Firmennamen oder juristische Person) zu prüfen [Offen]; das ist eine Kosten- und Beratungsfrage, kein Grund gegen den Prototyp.
2. **Adresse im Impressum:** Bist du bereit, eine Postadresse zu nennen (UWG [Sekundär])? Alternativen (c/o, Postfach) sind juristisch zu prüfen [Offen].
3. **Sprachen der ersten Version:** Nur Deutsch zum Start (schneller) oder DE+FR+IT (Schweizer Reichweite, mehr Prüfaufwand)? Meine konservative Annahme: Deutsch zuerst, FR/IT sobald muttersprachlich geprüft.

### 12.2 Offene Prüfungen vor einer Veröffentlichung (durch dich oder Fachpersonen)

| Nr. | Punkt | Wer | Wesentlich? |
|---|---|---|---|
| O1 | Primärquellen-Prüfung DSG Art. 2, 7, 19, 25, 60 ff. und UWG Art. 3 Abs. 1 lit. s auf fedlex.admin.ch; EDÖB-Merkblätter | Du, dann Fachperson | ja |
| O2 | Juristische Kurzprüfung von Datenschutzerklärung, Impressum, Hinweistexten | Anwältin/Anwalt (Datenschutz/IT-Recht) | ja |
| O3 | Markenrecherche und App-Store-Namensverfügbarkeit für «Reihum» oder Alternative | Du (Swissreg, EUIPO, WIPO), bei Treffern Fachperson | ja |
| O4 | Apple Privacy Manifest: aktuelle Required-Reason-Codes und Pflichtangaben | Du (Apple-Dokumentation) | ja |
| O5 | SF-Symbols-Lizenz: Bestätigung, dass Symbole nicht als Icon genutzt werden | Du (Lizenztext in Xcode) | ja |
| O6 | App Review Guidelines am Einreichungstag | Du | ja |
| O7 | Rechtsschutzversicherung oder vergleichbare Absicherung sinnvoll? | Versicherungsberatung | nein (Empfehlung) |
| O8 | Steuerliche Einordnung, falls später Käufe | Steuerberatung | erst bei Monetarisierung |
| O9 | EU-/US-Anforderungen | Fachperson | erst bei Ausweitung |
| O10 | Muttersprachliche Prüfung FR/IT/EN | Übersetzende | vor Freischaltung der Sprache |

### 12.3 Go-/No-Go-Einschätzung

**Go für Konzept, Prototyp und MVP-Entwicklung.** Die gewählte Idee vermeidet alle Risikoklassen, die für ein Einzelprojekt ohne Rechtsabteilung kritisch sind, lässt sich vollständig lokal umsetzen und hat einen echten, wiederkehrenden Nutzen mit einem natürlichen, datensparsamen Verteilmechanismus.

**No-Go für die Veröffentlichung, solange O1 bis O6 offen sind.** Keiner dieser Punkte ist teuer oder langwierig, aber jeder ist wesentlich: Ohne O1/O2 fehlt die Absicherung der Pflichttexte, ohne O3 riskierst du eine Umbenennung nach dem Start, ohne O4 bis O6 riskierst du eine Ablehnung oder einen Verstoss gegen Apple-Bedingungen.

**Was diese Einschätzung nicht ist:** keine Rechtsfreigabe, keine Garantie für eine erfolgreiche App-Prüfung, kein Versprechen zum Wachstum. Eine erfolgreiche App-Store-Prüfung bedeutet nicht, dass die App rechtlich zulässig oder haftungsfrei ist. Ein Restrisiko unbegründeter Beschwerden bleibt immer bestehen.

**Empfohlener nächster Schritt:** Phase 0 (fünf bis acht Gespräche) starten und parallel O3 (Namensrecherche) selbst durchführen. Beides kostet nichts ausser Zeit und liefert die Grundlage für alles Weitere.

---

## Anhang A: Quellen mit URL und Prüfdatum (29.09.2026)

| Quelle | URL | Status |
|---|---|---|
| Apple App Review Guidelines | https://developer.apple.com/app-store/review/guidelines/ | [Belegt] |
| Apple Developer Program Enrollment | https://developer.apple.com/programs/enroll/ | [Belegt] |
| Apple App Privacy Details | https://developer.apple.com/app-store/app-privacy-details/ | [Belegt] |
| Apple App Store Connect Hilfe: Altersfreigaben | https://developer.apple.com/help/app-store-connect/reference/age-ratings | [Belegt] |
| Apple Developer News: Updated age ratings (24.07.2025) | https://developer.apple.com/news/?id=ks775ehf | [Belegt] |
| Apple App Store Connect Hilfe: EU DSA Trader Requirements | https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements | [Belegt] |
| Apple Small Business Program | https://developer.apple.com/app-store/small-business-program/ | [Belegt] |
| Apple Support: Changes for apps in the European Union | https://developer.apple.com/support/apps-in-the-eu/ | [Belegt] |
| Apple Documentation: Privacy manifest files | https://developer.apple.com/documentation/bundleresources/privacy-manifest-files | [Sekundär] (Seiteninhalt nicht vollständig geladen) |
| Apple Documentation: Describing use of required reason API | https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api | [Sekundär] |
| Apple SF Symbols | https://developer.apple.com/sf-symbols/ | [Sekundär] (Lizenzbeschränkungen nicht auf der Seite) |
| Bundesgesetz über den Datenschutz (DSG), SR 235.1 | https://www.fedlex.admin.ch/eli/cc/2022/491/de | [Offen] (nicht erreichbar) |
| Bundesgesetz gegen den unlauteren Wettbewerb (UWG), SR 241 | https://www.fedlex.admin.ch/eli/cc/1988/223_223_223/de | [Offen] (nicht erreichbar) |
| EDÖB: Informationspflicht | https://www.edoeb.admin.ch/de/informationspflicht | [Offen] (nicht erreichbar; URL aus Suchergebnis) |
| EDÖB: Datenschutzerklärungen im Internet | https://www.edoeb.admin.ch/de/datenschutzerklaerungen-im-internet | [Offen] (nicht erreichbar; URL aus Suchergebnis) |
| Sekundärquellen DSG Art. 2 / Art. 19 | https://onlinekommentar.ch/de/kommentare/dsg2 · https://onlinekommentar.ch/de/kommentare/dsg19 · https://www.activemind.ch/gesetze/dsg/artikel-19/ | [Sekundär] |
| Sekundärquellen UWG Impressum | https://www.cyon.ch/blog/impressum-websites · https://steigerlegal.ch/2012/04/01/impressumspflicht-im-e-commerce-fragen-und-antworten/ · https://www.activemind.ch/blog/impressumspflicht/ | [Sekundär] |
| iOS 27 Veröffentlichung (Medien) | https://www.macrumors.com/2026/09/09/apple-announces-ios-27-release-date/ · https://appleinsider.com/articles/26/09/09/ios-27-arrives-on-september-14-heres-what-youll-get | [Sekundär] |
| Wettbewerb Wohnungsübergabe | https://www.wohnungsapp.ch/ · https://apps.apple.com/ch/app/wohnungs%C3%BCbergabe/id956511997 · https://www.hev-schweiz.ch/vermieten/verwalten/wohnungsabgabe/hev-schweiz-wohnungsprotokoll-app · https://apps.apple.com/de/app/%C3%BCbergabe-%C3%BCbergabeprotokolle/id1550265532 | [Belegt] (Treffer) |
| Wettbewerb Kündigungsfristen | https://apps.apple.com/ch/app/contract-vertr%C3%A4ge-abos/id1425151793 · https://www.aboalarm.de/apps · https://apps.apple.com/de/app/volders-der-k%C3%BCndigungsservice/id1006663287 | [Belegt] (Treffer) |
| Wettbewerb Dienst-/Putzpläne | https://apps.apple.com/ch/app/plan-dienstplan/id1454655718 · https://apps.apple.com/de/app/meindienstplan/id1498175051 · https://apps.apple.com/de/app/putzplan-haushaltsplaner-app/id1604578415 | [Belegt] (Treffer) |

## Anhang B: Gliederung der Datenschutzerklärung (Entwurf zur juristischen Prüfung)

1. Verantwortliche Person und Kontakt (Name, Postadresse, E-Mail)
2. Kurzfassung: «Reihum erhebt keine Daten. Alles, was du eingibst, bleibt auf deinem iPhone.»
3. Welche Daten die App lokal speichert (Plannamen, Vornamen, Gewichte, Abwesenheiten, Termine, Einstellungen) und warum
4. Was die App nicht tut (keine Übertragung, keine Konten, kein Tracking, keine Werbung, keine Drittanbieter-SDKs)
5. Teilen: erfolgt ausschliesslich über Systemfunktionen auf Veranlassung des Nutzers; Verantwortung für geteilte Inhalte
6. Erinnerungen: lokal, optional, jederzeit abschaltbar
7. Backups: Teil des Geräte-Backups des Nutzers (Apple iCloud oder Computer), gesteuert durch den Nutzer
8. Apple als Plattform: App Store, App Analytics und Absturzberichte gemäss Apples Bedingungen und der Wahl des Nutzers in den iOS-Einstellungen
9. Rechte der Nutzer: Da keine Daten beim Anbieter liegen, erfolgen Auskunft, Berichtigung und Löschung direkt in der App («Alle Daten löschen»); Kontakt für Fragen
10. Datenschutz Dritter: Hinweis, Pläne nur mit den betroffenen Personen zu teilen
11. Änderungen dieser Erklärung, Datum der Fassung

## Anhang C: Beispiel einer exportierten Kalenderdatei (gekürzt)

```
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Reihum//Turnusplan//DE
CALSCALE:GREGORIAN
BEGIN:VEVENT
UID:2f1c...-20261003@reihum
DTSTAMP:20260929T120000Z
DTSTART;VALUE=DATE:20261003
DTEND;VALUE=DATE:20261004
SUMMARY:Znüni-Dienst: Anna
SEQUENCE:0
BEGIN:VALARM
TRIGGER:-PT6H
ACTION:DISPLAY
DESCRIPTION:Morgen: Znüni-Dienst
END:VALARM
END:VEVENT
END:VCALENDAR
```

*Ende des Dokuments. Dieses Konzept wurde ohne Veröffentlichung, ohne Registrierung und ohne kostenpflichtige Verpflichtungen erstellt.*

## Anhang D: Prüf- und Entscheidungsprotokoll

| Datum | Schritt | Ergebnis | Status |
|---|---|---|---|
| 29.09.2026 | Grundentscheide (12.1) | Bürgerlicher Name im App Store akzeptiert; Privatadresse im Impressum; erste Version nur Deutsch; Testgerät iPhone 11 Pro vorhanden; Mac mit Xcode noch zu klären. | erledigt |
| 29.09.2026 | Namensrecherche «Reihum», Teil 1 (Web) | Websuche nach «Reihum» als App, Marke, Firma, Verein oder Produkt: keine Treffer. Domains reihum.ch, www.reihum.ch, reihum.app, reihum.com: kein DNS-Eintrag, keine erreichbare Website. Das spricht für Verfügbarkeit, ist aber **kein Nachweis**: Eine Domain kann registriert, aber ungenutzt sein; eine Marke kann eingetragen sein, ohne im Web sichtbar zu sein. | teilweise erledigt |
| 29.09.2026 | Ausrüstung | Mac vorhanden, zurzeit ohne Zugriff. Xcode-Projekt kann vorbereitet werden; Bauen und Testen auf dem Gerät erst, wenn der Mac verfügbar ist. | erledigt |
| 29.09.2026 | Namensrecherche «Reihum», Entscheid | Registerprüfung erfolgt durch den Projektinhaber selbst (Anleitung unten). Bis dahin läuft das Projekt unter dem **Arbeitstitel «Reihum»**; Name wird erst nach der Prüfung fixiert. | offen (O3), Vorgehen festgelegt |
| 29.09.2026 | Namensrecherche «Reihum», Teil 2 (Register) | App-Store-Suche (apps.apple.com), Swissreg (swissreg.ch, IGE), .ch-WHOIS (nic.ch), EUIPO eSearch und WIPO Global Brand Database waren aus der Arbeitsumgebung netzwerkseitig gesperrt. **Muss manuell erfolgen** (Anleitung unten). | offen (O3) |

**Anleitung für die manuelle Namensprüfung (Dauer etwa 20 Minuten):**

1. **App Store:** Auf dem iPhone im App Store nach «Reihum», «Reihum Plan», «Wer ist dran» und «Turnus» suchen. Notieren, welche Apps erscheinen und ob eine davon denselben Namen oder einen sehr ähnlichen Zweck hat.
2. **Swissreg (Schweiz):** swissreg.ch → Marken → Suche nach «Reihum» und ähnlichen Schreibweisen («Reium», «Rei-hum»), alle Klassen, zusätzlich gezielt Klassen 9 (Software) und 42 (Softwaredienstleistungen). Treffer mit Status «aktiv» notieren.
3. **EUIPO eSearch plus (EU):** euipo.europa.eu → eSearch plus → Marken → «Reihum», Klassen 9 und 42. Relevant für eine spätere EU-Ausweitung.
4. **WIPO Global Brand Database:** branddb.wipo.int → «Reihum». Deckt internationale Registrierungen ab.
5. **Domain:** nic.ch → WHOIS für reihum.ch; für reihum.app ein beliebiger Registrar mit Verfügbarkeitsprüfung.
6. **Bewertung:** Kein identischer oder verwechselbarer Treffer in Klassen 9/42 → Name als Arbeitstitel bestätigen und Domain sichern (kleiner Betrag pro Jahr). Verwechselbarer Treffer → Alternativnamen aus 5.7 prüfen («Dran!», «Turnus», «Abwechselnd») oder Fachperson beiziehen.

Diese Eigenrecherche ersetzt keine professionelle Markenrecherche. Sie reicht für die Entscheidung, ob der Prototyp unter dem Arbeitstitel weiterläuft.
