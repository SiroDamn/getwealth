import SwiftUI
import ReihumCore

struct MembersView: View {
    @Environment(PlanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Plan
    @State private var newName = ""

    init(plan: Plan) {
        _draft = State(initialValue: plan)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($draft.members) { $member in
                        NavigationLink {
                            MemberDetailView(member: $member)
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(member: member)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(member.name).foregroundStyle(member.isActive ? .primary : .secondary)
                                    Text(subtitle(member)).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in removeMembers(at: offsets) }
                    HStack {
                        TextField("Vorname hinzufügen", text: $newName)
                            .submitLabel(.done)
                            .onSubmit(addMember)
                        Button("Hinzufügen", action: addMember)
                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Personen (\(draft.members.count))")
                } footer: {
                    Text("Personen mit vergangenen Terminen besser deaktivieren statt löschen, damit die Historie lesbar bleibt. Nach dem Speichern werden zukünftige Termine neu berechnet.")
                }
            }
            .navigationTitle("Personen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        store.update(store.regenerate(draft))
                        dismiss()
                    }
                    .disabled(draft.activeMembers.count < 1)
                }
            }
        }
    }

    private func subtitle(_ member: Member) -> String {
        var parts: [String] = ["Anteil \(Fmt.weight(member.weight))"]
        if !member.isActive { parts.append("inaktiv") }
        if !member.absences.isEmpty { parts.append("\(member.absences.count) Abwesenheit\(member.absences.count == 1 ? "" : "en")") }
        return parts.joined(separator: " · ")
    }

    /// A member who already has past turns is deactivated instead of removed, so the history stays readable.
    /// Upcoming manual assignments of a removed member are cleared and become open turns.
    private func removeMembers(at offsets: IndexSet) {
        let today = DayDate.today()
        for index in offsets.sorted(by: >) {
            let id = draft.members[index].id
            let hasHistory = draft.slots.contains { slot in
                slot.date < today && slot.assignedMemberIDs.contains(id)
            }
            if hasHistory {
                draft.members[index].isActive = false
            } else {
                draft.members.remove(at: index)
                for slotIndex in draft.slots.indices where draft.slots[slotIndex].date >= today {
                    draft.slots[slotIndex].assignedMemberIDs.removeAll { $0 == id }
                }
            }
        }
    }

    private func addMember() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= 40 else { return }
        draft.members.append(Member(name: trimmed, colorIndex: draft.members.count))
        newName = ""
    }
}

struct MemberDetailView: View {
    @Binding var member: Member
    @State private var showingAbsence = false

    var body: some View {
        Form {
            Section("Name") {
                TextField("Vorname", text: $member.name)
            }
            Section {
                Picker("Anteil", selection: $member.weight) {
                    Text("½").tag(0.5)
                    Text("1").tag(1.0)
                    Text("2").tag(2.0)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Anteil")
            } footer: {
                Text("½ = halb so oft dran, 2 = doppelt so oft. Zum Beispiel bei Teilzeit oder Doppelrollen.")
            }
            Section {
                Toggle("Aktiv", isOn: $member.isActive)
            } footer: {
                Text("Inaktive Personen werden nicht mehr eingeteilt. Ihre bisherigen Termine bleiben.")
            }
            Section("Abwesenheiten") {
                ForEach(member.absences) { absence in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(Fmt.numeric(absence.start)) bis \(Fmt.numeric(absence.end))")
                        if let note = absence.note, !note.isEmpty {
                            Text(note).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in member.absences.remove(atOffsets: offsets) }
                Button("Abwesenheit hinzufügen") { showingAbsence = true }
            }
        }
        .navigationTitle(member.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAbsence) {
            AbsenceEditor { absence in member.absences.append(absence) }
        }
    }
}

struct AbsenceEditor: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Absence) -> Void
    @State private var start = Date()
    @State private var end = Date()
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Von", selection: $start, displayedComponents: .date)
                DatePicker("Bis", selection: $end, in: start..., displayedComponents: .date)
                TextField("Hinweis (optional), z. B. Ferien", text: $note)
            }
            .navigationTitle("Abwesenheit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        onSave(Absence(start: DayDate(start), end: DayDate(end), note: note.isEmpty ? nil : note))
                        dismiss()
                    }
                }
            }
        }
    }
}
