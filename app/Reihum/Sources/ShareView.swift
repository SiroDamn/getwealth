import SwiftUI
import ReihumCore
#if canImport(UIKit)
import UIKit
#endif

enum ShareFormat: String, CaseIterable, Identifiable {
    case image, text, calendar
    var id: String { rawValue }
    var label: String {
        switch self {
        case .image: return "Bild"
        case .text: return "Text"
        case .calendar: return "Kalender"
        }
    }
}

struct ShareView: View {
    @Environment(PlanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @AppStorage("didShowShareHint") private var didShowShareHint = false
    let planID: UUID

    @State private var format: ShareFormat = .image
    @State private var darkCard = false
    @State private var memberFilter: UUID?
    @State private var renderedImage: Image?
    @State private var icsURL: URL?
    @State private var showHint = false

    var body: some View {
        NavigationStack {
            if let plan = store.plan(id: planID) {
                VStack(spacing: 16) {
                    Picker("Format", selection: $format) {
                        ForEach(ShareFormat.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    ScrollView {
                        preview(plan).padding()
                    }

                    VStack(spacing: 8) {
                        controls(plan)
                    }
                    .padding(.horizontal)

                    shareButton(plan)
                        .padding()
                }
                .navigationTitle("Teilen")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Fertig") { dismiss() } }
                }
                .task(id: renderKey(plan)) { await prepare(plan) }
                .onAppear { if !didShowShareHint { showHint = true } }
                .alert("Der Plan enthält Namen", isPresented: $showHint) {
                    Button("Verstanden") { didShowShareHint = true }
                } message: {
                    Text("Teile ihn nur mit den Personen, die dazugehören.")
                }
            } else {
                ContentUnavailableView("Plan nicht gefunden", systemImage: "questionmark.folder")
            }
        }
    }

    private func renderKey(_ plan: Plan) -> String {
        "\(format.rawValue)|\(darkCard)|\(memberFilter?.uuidString ?? "all")|\(plan.updatedAt.timeIntervalSince1970)|\(plan.showAttribution)"
    }

    @ViewBuilder
    private func preview(_ plan: Plan) -> some View {
        switch format {
        case .image:
            PlanCardView(plan: plan, dark: darkCard)
                .frame(width: 340)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 4)
        case .text:
            Text(TextExporter.export(plan, memberID: memberFilter))
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        case .calendar:
            VStack(alignment: .leading, spacing: 8) {
                Label("Kalenderdatei (.ics)", systemImage: "calendar.badge.plus").font(.headline)
                Text("Empfangende öffnen die Datei und fügen die Termine ihrem Kalender hinzu. Ganztägige Termine mit Erinnerung am Vortag um 18 Uhr. Eine App wird dafür nicht benötigt.")
                    .foregroundStyle(.secondary)
                Text(memberFilter == nil ? "Enthält alle Termine des Plans." : "Enthält nur die Termine der gewählten Person.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func controls(_ plan: Plan) -> some View {
        if format == .image {
            Toggle("Dunkle Karte", isOn: $darkCard)
        } else {
            Picker("Für", selection: $memberFilter) {
                Text("Alle").tag(UUID?.none)
                ForEach(plan.members) { Text($0.name).tag(Optional($0.id)) }
            }
        }
        Toggle("Hinweis «Erstellt mit Reihum» anzeigen", isOn: Binding(
            get: { plan.showAttribution },
            set: { value in
                var updated = plan
                updated.showAttribution = value
                store.update(updated)
            }
        ))
    }

    @ViewBuilder
    private func shareButton(_ plan: Plan) -> some View {
        switch format {
        case .image:
            if let image = renderedImage {
                ShareLink(item: image, preview: SharePreview(plan.name, image: image)) {
                    Label("Bild teilen", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
            } else {
                ProgressView()
            }
        case .text:
            ShareLink(item: TextExporter.export(plan, memberID: memberFilter)) {
                Label("Text teilen", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        case .calendar:
            if let url = icsURL {
                ShareLink(item: url) {
                    Label("Kalenderdatei teilen", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
            } else {
                ProgressView()
            }
        }
    }

    @MainActor
    private func prepare(_ plan: Plan) async {
        switch format {
        case .image:
            #if canImport(UIKit)
            let renderer = ImageRenderer(content: PlanCardView(plan: plan, dark: darkCard).frame(width: 540))
            renderer.scale = 3
            if let uiImage = renderer.uiImage {
                renderedImage = Image(uiImage: uiImage)
            }
            #endif
        case .calendar:
            let text = ICSExporter.export(plan, options: ICSExporter.Options(memberID: memberFilter))
            let safeName = plan.name.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }.joined(separator: "-")
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName.isEmpty ? "Reihum" : safeName).ics")
            do {
                try text.write(to: url, atomically: true, encoding: .utf8)
                icsURL = url
            } catch {
                icsURL = nil
            }
        case .text:
            break
        }
    }
}

/// The shareable card. Uses explicit colours so it renders identically on screen and via ImageRenderer.
struct PlanCardView: View {
    let plan: Plan
    var dark: Bool = false
    var maxRows = 30

    private var rows: [Slot] {
        let today = DayDate.today()
        return plan.sortedSlots.filter { !$0.isSkipped && $0.date >= today }
    }

    var body: some View {
        let foreground: Color = dark ? .white : .black
        let secondary: Color = dark ? Color.white.opacity(0.7) : Color.black.opacity(0.6)
        let visible = Array(rows.prefix(maxRows))
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: plan.symbolName).foregroundStyle(Palette.color(plan.colorIndex))
                Text(plan.name).font(.title2.bold())
            }
            if let first = visible.first, let last = visible.last {
                Text("\(Fmt.short(first.date)) bis \(Fmt.short(last.date))")
                    .font(.subheadline)
                    .foregroundStyle(secondary)
            }
            Rectangle().fill(secondary.opacity(0.4)).frame(height: 1)
            if visible.isEmpty {
                Text("Keine anstehenden Termine").foregroundStyle(secondary)
            }
            ForEach(visible) { slot in
                HStack(alignment: .firstTextBaseline) {
                    Text(Fmt.short(slot.date))
                        .frame(width: 120, alignment: .leading)
                        .foregroundStyle(secondary)
                    Text(who(slot)).fontWeight(.medium)
                    Spacer(minLength: 0)
                }
            }
            if rows.count > maxRows {
                Text("… und \(rows.count - maxRows) weitere Termine")
                    .font(.footnote)
                    .foregroundStyle(secondary)
            }
            if plan.showAttribution {
                Rectangle().fill(secondary.opacity(0.4)).frame(height: 1)
                Text("Erstellt mit Reihum")
                    .font(.footnote)
                    .foregroundStyle(secondary)
            }
        }
        .foregroundStyle(foreground)
        .padding(24)
        .background(dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.white)
    }

    private func who(_ slot: Slot) -> String {
        let names = plan.names(for: slot)
        return names.isEmpty ? "offen" : names.joined(separator: " & ")
    }
}
