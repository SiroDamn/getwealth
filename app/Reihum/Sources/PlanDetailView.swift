import SwiftUI
import ReihumCore

struct PlanDetailView: View {
    @Environment(PlanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let planID: UUID

    @State private var showingShare = false
    @State private var showingMembers = false
    @State private var showingRhythm = false
    @State private var showingRename = false
    @State private var renameText = ""
    @State private var confirmRegenerate = false
    @State private var confirmDelete = false
    @State private var editingSlot: Slot?

    var body: some View {
        if let plan = store.plan(id: planID) {
            content(plan)
        } else {
            ContentUnavailableView("Plan nicht gefunden", systemImage: "questionmark.folder")
        }
    }

    private struct SlotGroup {
        let month: DayDate
        let slots: [Slot]
    }

    private func groupedSlots(_ plan: Plan) -> [SlotGroup] {
        let grouped = Dictionary(grouping: plan.sortedSlots) { $0.date.firstOfMonth }
        return grouped.keys.sorted().map { SlotGroup(month: $0, slots: grouped[$0] ?? []) }
    }

    @ViewBuilder
    private func content(_ plan: Plan) -> some View {
        let today = DayDate.today()
        let nextID = plan.nextSlot(onOrAfter: today)?.id
        List {
            Section {
                FairnessRow(plan: plan)
                if !plan.openSlots.isEmpty {
                    Label("\(plan.openSlots.count) offene Termine: niemand verfügbar. Tippe auf den Termin, um jemanden zu wählen.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                        .font(.footnote)
                }
                Text("\(plan.rhythm.label) · \(plan.slotSize) pro Termin · \(Fmt.numeric(plan.startDate)) bis \(Fmt.numeric(plan.endDate))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            ForEach(groupedSlots(plan), id: \.month) { group in
                Section(Fmt.month(group.month)) {
                    ForEach(group.slots) { slot in
                        Button { editingSlot = slot } label: {
                            SlotRow(plan: plan, slot: slot, isNext: slot.id == nextID, isPast: slot.date < today)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingShare = true } label: { Label("Teilen", systemImage: "square.and.arrow.up") }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showingMembers = true } label: { Label("Personen & Abwesenheiten", systemImage: "person.2") }
                    Button { showingRhythm = true } label: { Label("Rhythmus & Zeitraum", systemImage: "calendar") }
                    Button { confirmRegenerate = true } label: { Label("Neu berechnen", systemImage: "arrow.triangle.2.circlepath") }
                    Button { renameText = plan.name; showingRename = true } label: { Label("Umbenennen", systemImage: "pencil") }
                    Divider()
                    Button(role: .destructive) { confirmDelete = true } label: { Label("Plan löschen", systemImage: "trash") }
                } label: {
                    Label("Mehr", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingShare) { ShareView(planID: planID) }
        .sheet(isPresented: $showingMembers) { MembersView(plan: plan) }
        .sheet(isPresented: $showingRhythm) { RhythmEditorView(plan: plan) }
        .sheet(item: $editingSlot) { slot in SlotEditorView(plan: plan, slot: slot) }
        .alert("Plan umbenennen", isPresented: $showingRename) {
            TextField("Name", text: $renameText)
            Button("Speichern") {
                var updated = plan
                let trimmed = renameText.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { updated.name = trimmed; store.update(updated) }
            }
            Button("Abbrechen", role: .cancel) {}
        }
        .confirmationDialog("Zukünftige Termine neu berechnen?", isPresented: $confirmRegenerate, titleVisibility: .visible) {
            Button("Neu berechnen, manuelle Termine behalten") { store.update(store.regenerate(plan)) }
            Button("Neu berechnen, auch manuelle Termine", role: .destructive) { store.update(store.regenerate(plan, overwriteManual: true)) }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Vergangene Termine bleiben in jedem Fall unverändert.")
        }
        .confirmationDialog("Plan «\(plan.name)» löschen?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Löschen", role: .destructive) {
                store.delete(id: plan.id)
                dismiss()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Alle Termine dieses Plans werden entfernt. Das kann nicht rückgängig gemacht werden.")
        }
    }
}

struct FairnessRow: View {
    let plan: Plan

    var body: some View {
        let counts = FairnessEngine.assignmentCounts(in: plan)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(plan.members) { member in
                    HStack(spacing: 6) {
                        AvatarView(member: member, size: 24)
                        Text("\(member.name) \(counts[member.id] ?? 0)×")
                            .font(.subheadline)
                            .foregroundStyle(member.isActive ? .primary : .secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(member.name), \(counts[member.id] ?? 0) Mal dran\(member.isActive ? "" : ", inaktiv")")
                }
            }
        }
    }
}

struct SlotRow: View {
    let plan: Plan
    let slot: Slot
    let isNext: Bool
    let isPast: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Fmt.short(slot.date))
                    .fontWeight(isNext ? .semibold : .regular)
                if isNext {
                    Text("Nächster Termin")
                        .font(.caption)
                        .foregroundStyle(Palette.color(plan.colorIndex))
                }
            }
            Spacer()
            if slot.isSkipped {
                Text("Übersprungen").foregroundStyle(.secondary)
            } else if slot.isOpen {
                Label("Offen", systemImage: "exclamationmark.circle").foregroundStyle(.orange)
            } else {
                HStack(spacing: 6) {
                    ForEach(slot.assignedMemberIDs, id: \.self) { id in
                        if let member = plan.member(id: id) {
                            AvatarView(member: member, size: 24)
                            Text(member.name)
                        }
                    }
                }
            }
            if slot.isManual {
                Image(systemName: "hand.raised")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("manuell zugewiesen")
            }
        }
        .opacity(isPast ? 0.55 : 1)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Zum Bearbeiten tippen")
    }
}

struct RhythmEditorView: View {
    @Environment(PlanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    private let plan: Plan
    @State private var rhythm: RhythmDraft
    @State private var slotSize: Int
    @State private var start: Date
    @State private var end: Date

    init(plan: Plan) {
        self.plan = plan
        _rhythm = State(initialValue: RhythmDraft(plan.rhythm))
        _slotSize = State(initialValue: plan.slotSize)
        _start = State(initialValue: plan.startDate.startOfDay())
        _end = State(initialValue: plan.endDate.startOfDay())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Zeitraum") {
                    DatePicker("Start", selection: $start, displayedComponents: .date)
                    DatePicker("Ende", selection: $end, in: start...latestEnd, displayedComponents: .date)
                }
                Section {
                    RhythmForm(draft: $rhythm, slotSize: $slotSize)
                } footer: {
                    Text("Ergibt \(previewCount) Termine. Vergangene und manuell gesetzte Termine bleiben erhalten.")
                }
            }
            .onChange(of: start) { _, _ in
                if end < start { end = start }
                if end > latestEnd { end = latestEnd }
            }
            .navigationTitle("Rhythmus & Zeitraum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Speichern", action: save) }
            }
        }
    }

    /// A plan may span at most ten years (see `PlanLimits`).
    private var latestEnd: Date {
        DayDate(start).adding(days: RhythmGenerator.maximumSpanDays).startOfDay()
    }

    private var previewCount: Int {
        RhythmGenerator.dates(for: rhythm.rhythm, from: DayDate(start), to: DayDate(end)).count
    }

    private func save() {
        var updated = plan
        updated.rhythm = rhythm.rhythm
        updated.slotSize = slotSize
        updated.startDate = DayDate(start)
        updated.endDate = DayDate(end)
        store.update(store.regenerate(updated))
        dismiss()
    }
}
