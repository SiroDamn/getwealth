import SwiftUI
import ReihumCore

struct PlanListView: View {
    @Environment(PlanStore.self) private var store
    @State private var showingNew = false
    @State private var showingSettings = false
    @State private var pendingDelete: Plan?

    var body: some View {
        NavigationStack {
            Group {
                if store.plans.isEmpty {
                    EmptyStateView(createAction: { showingNew = true }, sampleAction: addSample)
                } else {
                    List {
                        if let today = todaySummary {
                            Section("Heute") { Text(today) }
                        }
                        Section("Pläne") {
                            ForEach(store.plans) { plan in
                                NavigationLink(value: plan.id) { PlanRow(plan: plan) }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) { pendingDelete = plan } label: {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reihum")
            .navigationDestination(for: UUID.self) { id in PlanDetailView(planID: id) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingSettings = true } label: { Label("Einstellungen", systemImage: "gearshape") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNew = true } label: { Label("Neuer Plan", systemImage: "plus") }
                }
            }
            .sheet(isPresented: $showingNew) { NewPlanFlow() }
            .sheet(isPresented: $showingSettings) { SettingsView() }
            .confirmationDialog("Plan «\(pendingDelete?.name ?? "")» löschen?", isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }), titleVisibility: .visible) {
                Button("Löschen", role: .destructive) {
                    if let plan = pendingDelete { store.delete(id: plan.id) }
                    pendingDelete = nil
                }
                Button("Abbrechen", role: .cancel) { pendingDelete = nil }
            } message: {
                Text("Alle Termine dieses Plans werden entfernt. Das kann nicht rückgängig gemacht werden.")
            }
            .alert("Fehler", isPresented: Binding(get: { store.lastError != nil }, set: { _ in store.lastError = nil })) {
                Button("OK") {}
            } message: {
                Text(store.lastError ?? "")
            }
        }
    }

    private var todaySummary: String? {
        let today = DayDate.today()
        let lines = store.plans.compactMap { plan -> String? in
            guard let slot = plan.slots.first(where: { $0.date == today && !$0.isSkipped }) else { return nil }
            let names = plan.names(for: slot)
            return "\(plan.name): \(names.isEmpty ? "offen" : names.joined(separator: " und "))"
        }
        return lines.isEmpty ? nil : lines.joined(separator: "\n")
    }

    private func addSample() {
        store.add(store.regenerate(SampleData.plan()))
    }
}

struct PlanRow: View {
    let plan: Plan

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: plan.symbolName)
                .font(.title3)
                .foregroundStyle(Palette.color(plan.colorIndex))
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.name).font(.headline)
                Text(nextText).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var nextText: String {
        guard let slot = plan.nextSlot(onOrAfter: DayDate.today()) else { return "Keine anstehenden Termine" }
        let names = plan.names(for: slot)
        return "Nächster Termin: \(Fmt.short(slot.date)) – \(names.isEmpty ? "offen" : names.joined(separator: " & "))"
    }
}

struct EmptyStateView: View {
    let createAction: () -> Void
    let sampleAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Wer ist dran?")
                .font(.title2.bold())
            Text("Erstelle einen fairen Plan für alles, was ihr euch abwechselnd teilt: Znüni, Putzen, Elterndienst, Kuchen. Alles bleibt auf deinem iPhone.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Ersten Plan erstellen", action: createAction)
                .buttonStyle(.borderedProminent)
            Button("Beispielplan anlegen", action: sampleAction)
                .buttonStyle(.bordered)
        }
        .padding(32)
    }
}
