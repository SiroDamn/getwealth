import SwiftUI

/// PLATZHALTER: Diese Texte sind Entwürfe für die juristische Prüfung (Konzept, Anhang B).
/// Vor einer Veröffentlichung müssen sie geprüft und die eckigen Klammern ersetzt werden.
struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DraftBanner()
                Text("Datenschutzhinweise").font(.title2.bold())
                Text("Stand: [Datum]")

                LegalSection("Kurz gesagt", "Reihum erhebt keine Daten. Alles, was du eingibst, bleibt auf deinem iPhone. Es gibt keine Konten, keine Server des Anbieters, keine Werbung und keine Analysewerkzeuge.")

                LegalSection("Verantwortliche Person", "[Vorname Name]\n[Strasse Nr.]\n[PLZ Ort], Schweiz\n[E-Mail-Adresse]")

                LegalSection("Welche Daten die App auf deinem Gerät speichert", "Plannamen, Vornamen oder Kürzel der eingetragenen Personen, deren Anteil und Abwesenheiten, die berechneten Termine sowie deine Einstellungen. Diese Daten dienen ausschliesslich der Funktion der App und werden nur lokal gespeichert.")

                LegalSection("Was die App nicht tut", "Die App überträgt keine Daten an den Anbieter oder an Dritte. Sie verwendet keine Analyse- oder Werbe-SDKs, kein Tracking und keine Konten. Sie greift nicht auf Standort, Kontakte, Fotos, Kamera oder Mikrofon zu.")

                LegalSection("Teilen", "Wenn du einen Plan als Bild, Text oder Kalenderdatei teilst, geschieht das über die Teilen-Funktion von iOS und ausschliesslich auf deine Veranlassung. Du entscheidest, an wen der Plan geht. Geteilte Pläne enthalten die eingetragenen Namen; teile sie nur mit den betroffenen Personen.")

                LegalSection("Erinnerungen", "Erinnerungen sind optional und werden nur auf deinem Gerät geplant. Du kannst sie in den Einstellungen der App jederzeit ausschalten.")

                LegalSection("Backups", "Die Daten der App sind Teil des Geräte-Backups, das du selbst in iOS konfigurierst (iCloud oder Computer). Der Anbieter hat darauf keinen Zugriff.")

                LegalSection("Apple als Plattform", "Der Bezug der App über den App Store sowie allfällige Absturzberichte oder Nutzungsstatistiken, die du in den iOS-Einstellungen freigegeben hast, unterliegen den Datenschutzbestimmungen von Apple. Der Anbieter erhält davon höchstens aggregierte, nicht personenbezogene Auswertungen.")

                LegalSection("Deine Rechte", "Da keine Daten beim Anbieter liegen, kannst du Auskunft, Berichtigung und Löschung direkt in der App vornehmen. «Alle Daten löschen» in den Einstellungen entfernt sämtliche Daten der App von deinem Gerät. Bei Fragen erreichst du die verantwortliche Person unter der oben genannten Adresse.")

                LegalSection("Änderungen", "Änderungen dieser Hinweise werden in der App und unter [URL] veröffentlicht.")
            }
            .padding()
        }
        .navigationTitle("Datenschutz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ImpressumView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DraftBanner()
                Text("Impressum").font(.title2.bold())
                LegalSection("Anbieter", "[Vorname Name]\n[Strasse Nr.]\n[PLZ Ort]\nSchweiz")
                LegalSection("Kontakt", "[E-Mail-Adresse]")
                LegalSection("Support", "Fragen und Fehlermeldungen an die oben genannte E-Mail-Adresse. Antwort in der Regel innerhalb einiger Tage.")
                LegalSection("Sicherheitsmeldungen", "Hinweise auf Sicherheitsprobleme bitte an dieselbe Adresse mit dem Betreff «Sicherheit».")
            }
            .padding()
        }
        .navigationTitle("Impressum & Kontakt")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LicensesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Lizenzen").font(.title2.bold())
                Text("Reihum verwendet keine Bibliotheken von Drittanbietern. Die App besteht ausschliesslich aus eigenem Code und den Systembibliotheken von Apple.")
                Text("Symbole in der App: SF Symbols von Apple, verwendet gemäss den Lizenzbedingungen von Apple für Apps auf Apple-Plattformen.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Lizenzen")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LegalSection: View {
    let title: String
    let text: String
    init(_ title: String, _ text: String) {
        self.title = title
        self.text = text
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(text)
        }
    }
}

private struct DraftBanner: View {
    var body: some View {
        Label("Entwurf. Vor der Veröffentlichung juristisch prüfen und Platzhalter ersetzen.", systemImage: "exclamationmark.triangle")
            .font(.footnote)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
    }
}
