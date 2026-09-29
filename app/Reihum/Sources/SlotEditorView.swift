import SwiftUI
import ReihumCore

struct SlotEditorView: View {
    @Environment(PlanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let plan: Plan
    @State private var draft: Slot
    @State private var selections: [UUID?]

    init(plan: Plan, slot: Slot) {
        self.plan = plan
        _draft = State(initialValue: slot)
        var initial: [UUID?] = slot.assignedMemberIDs.map { Optional($0) }
        while initial.count < plan.slotSize { initial.append(nil) }
        _selections = State(initialValue: Array(initial.prefix(plan.slotSize)))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(Fmt.long(draft.date))
                }
                Section("Zuweisung") {
                    ForEach(0..<plan.slotSize, id: \.self) { index in
                        Picker(plan.slotSize == 1 ? "Person" : "Person \(index + 1)", selection: $selections[index]) {
                            Text("Niemand").tag(UUID?.none)
                            ForEach(plan.members) { member in
                                Text(member.name + (member.isAbsent(on: draft.date) ? " (abwesend)" : ""))
                                    .tag(Optional(member.id))
                            }
                        }
                        .disabled(draft.isSkipped)
                    }
                    Toggle("Termin überspringen", isOn: $draft.isSkipped)
                }
                Section("Notiz") {
                    TextField("Optional", text: Binding(
                        get: { draft.note ?? "" },
                        set: { draft.note = $0.isEmpty ? nil : String($0.prefix(200)) }
                    ))
                }
                Section {
                    NavigationLink("Mit anderem Termin tauschen") {
                        SwapPickerView(plan: plan, current: draft) { other in
                            store.update(FairnessEngine.swap(slotA: draft.id, slotB: other.id, in: plan))
                            dismiss()
                        }
                    }
                    .disabled(draft.isSkipped)
                }
                if draft.isManual {
                    Section {
                        Label("Manuell gesetzt. «Neu berechnen» überschreibt diesen Termin nur, wenn du das ausdrücklich wählst.", systemImage: "hand.raised")
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Termin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Speichern", action: save) }
            }
        }
    }

    private func save() {
        var slot = draft
        var ids: [UUID] = []
        for case let id? in selections where !ids.contains(id) { ids.append(id) }
        slot.assignedMemberIDs = slot.isSkipped ? [] : ids
        store.update(FairnessEngine.applyManualEdit(slot, in: plan))
        dismiss()
    }
}

struct SwapPickerView: View {
    let plan: Plan
    let current: Slot
    let onPick: (Slot) -> Void

    var body: some View {
        List(plan.sortedSlots.filter { $0.id != current.id && !$0.isSkipped }) { slot in
            Button { onPick(slot) } label: {
                HStack {
                    Text(Fmt.short(slot.date))
                    Spacer()
                    Text(plan.names(for: slot).joined(separator: " & "))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Tauschen mit …")
        .navigationBarTitleDisplayMode(.inline)
    }
}
