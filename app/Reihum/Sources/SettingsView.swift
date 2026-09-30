import SwiftUI
import UniformTypeIdentifiers
import ReihumCore

struct SettingsView: View {
    @Environment(PlanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("attributionDefault") private var attributionDefault = true

    @State private var exportDocument: JSONFileDocument?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var confirmDeleteAll = false
    @State private var confirmDeleteAllAgain = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Mich am Vortag erinnern", isOn: $remindersEnabled)
                } header: {
                    Text("Erinnerungen")
                } footer: {
                    Text("Eine Mitteilung um 18 Uhr am Vortag jedes Termins, nur an dich, nur auf diesem Gerät. Die anderen erhalten nichts.")
                }

                Section {
                    Toggle("Hinweiszeile bei neuen Plänen anzeigen", isOn: $attributionDefault)
                } header: {
                    Text("Teilen")
                } footer: {
                    Text("Die Zeile «Erstellt mit Reihum» kann pro Plan beim Teilen ausgeschaltet werden.")
                }

                Section("Daten") {
                    Button("Alle Pläne exportieren (JSON)") {
                        do {
                            exportDocument = JSONFileDocument(data: try store.exportJSON())
                            showingExporter = true
                        } catch {
                            message = "Export fehlgeschlagen: \(error.localizedDescription)"
                        }
                    }
                    Button("Pläne importieren") { showingImporter = true }
                    Button("Alle Daten löschen", role: .destructive) { confirmDeleteAll = true }
                }

                Section("Rechtliches") {
                    NavigationLink("Datenschutz") { PrivacyView() }
                    NavigationLink("Impressum & Kontakt") { ImpressumView() }
                    NavigationLink("Lizenzen") { LicensesView() }
                }

                Section("Über") {
                    LabeledContent("Version", value: appVersion)
                    Text("Reihum speichert alles nur auf diesem iPhone. Keine Konten, keine Cloud, keine Auswertung.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Fertig") { dismiss() } }
            }
            .onChange(of: remindersEnabled) { _, enabled in
                ReminderManager.shared.setEnabled(enabled, plans: store.plans) { granted in
                    if enabled && !granted {
                        remindersEnabled = false
                        message = "Mitteilungen sind für Reihum nicht erlaubt. Du kannst sie in den iOS-Einstellungen unter «Reihum» einschalten."
                    }
                }
            }
            .fileExporter(isPresented: $showingExporter, document: exportDocument, contentType: .json, defaultFilename: "Reihum-Export") { result in
                if case .failure(let error) = result { message = error.localizedDescription }
            }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
                    let accessed = url.startAccessingSecurityScopedResource()
                    defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                    do {
                        let data = try Data(contentsOf: url)
                        let count = try store.importJSON(data)
                        message = count == 1 ? "1 Plan importiert." : "\(count) Pläne importiert."
                    } catch {
                        message = "Import fehlgeschlagen. \(error.localizedDescription)"
                    }
                case .failure(let error):
                    message = error.localizedDescription
                }
            }
            .confirmationDialog("Alle Pläne und Personen löschen?", isPresented: $confirmDeleteAll, titleVisibility: .visible) {
                Button("Weiter", role: .destructive) { confirmDeleteAllAgain = true }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Du kannst vorher einen Export erstellen.")
            }
            .alert("Wirklich alles löschen?", isPresented: $confirmDeleteAllAgain) {
                Button("Alles löschen", role: .destructive) { store.deleteAll() }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Das kann nicht rückgängig gemacht werden.")
            }
            .alert("Hinweis", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
                Button("OK") { message = nil }
            } message: {
                Text(message ?? "")
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? version : "\(version) (\(build))"
    }
}

struct JSONFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
