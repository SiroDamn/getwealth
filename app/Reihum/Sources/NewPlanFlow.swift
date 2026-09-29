import SwiftUI
import ReihumCore

/// Four short steps: name, people, rhythm, period.
struct NewPlanFlow: View {
    @Environment(PlanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @AppStorage("attributionDefault") private var attributionDefault = true

    @State private var step = 0
    @State private var name = ""
    @State private var symbolName = Symbols.choices[0]
    @State private var colorIndex = 0
    @State private var memberNames: [String] = []
    @State private var memberWeights: [Double] = []
    @State private var newMemberName = ""
    @State private var rhythm = RhythmDraft()
    @State private var slotSize = 1
    @State private var startDate = Date()
    @State private var durationWeeks = 12

    private let stepTitles = ["Name", "Personen", "Rhythmus", "Zeitraum"]

    var body: some View {
        NavigationStack {
            Form {
                switch step {
                case 0: nameStep
                case 1: peopleStep
                case 2: rhythmStep
                default: periodStep
                }
            }
            .navigationTitle("Neuer Plan: \(stepTitles[step])")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    if step < 3 {
                        Button("Weiter") { step += 1 }.disabled(!canContinue)
                    } else {
                        Button("Plan erstellen") { create() }.disabled(!canContinue)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        if step > 0 { Button("Zurück") { step -= 1 } }
                        Spacer()
                        Text("Schritt \(step + 1) von 4").font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var canContinue: Bool {
        switch step {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return memberNames.count >= 2
        default: return durationWeeks >= 1
        }
    }

    // MARK: Steps

    private var nameStep: some View {
        Group {
            Section("Wofür ist der Plan?") {
                TextField("z. B. Znüni-Dienst", text: $name)
                    .submitLabel(.next)
            }
            Section("Symbol") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(Symbols.choices, id: \.self) { symbol in
                        Button {
                            symbolName = symbol
                        } label: {
                            Image(systemName: symbol)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(symbol == symbolName ? Palette.color(colorIndex).opacity(0.25) : Color.clear, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(symbol)
                        .accessibilityAddTraits(symbol == symbolName ? .isSelected : [])
                    }
                }
            }
            Section("Farbe") {
                HStack {
                    ForEach(Palette.colors.indices, id: \.self) { index in
                        Circle()
                            .fill(Palette.colors[index])
                            .frame(width: 26, height: 26)
                            .overlay(Circle().stroke(Color.primary, lineWidth: index == colorIndex ? 2 : 0))
                            .onTapGesture { colorIndex = index }
                            .accessibilityLabel("Farbe \(index + 1)")
                            .accessibilityAddTraits(index == colorIndex ? .isSelected : [])
                    }
                }
            }
        }
    }

    private var peopleStep: some View {
        Group {
            Section {
                ForEach(memberNames.indices, id: \.self) { index in
                    HStack {
                        Text(memberNames[index])
                        Spacer()
                        Picker("Anteil", selection: $memberWeights[index]) {
                            Text("½").tag(0.5)
                            Text("1").tag(1.0)
                            Text("2").tag(2.0)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 130)
                        .accessibilityLabel("Anteil von \(memberNames[index])")
                    }
                }
                .onDelete { offsets in
                    memberNames.remove(atOffsets: offsets)
                    memberWeights.remove(atOffsets: offsets)
                }
                HStack {
                    TextField("Vorname hinzufügen", text: $newMemberName)
                        .submitLabel(.done)
                        .onSubmit(addMember)
                    Button("Hinzufügen", action: addMember)
                        .disabled(newMemberName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Personen (\(memberNames.count))")
            } footer: {
                Text(memberNames.count < 2 ? "Mindestens zwei Personen." : "Anteil ½ = halb so oft dran, zum Beispiel bei Teilzeit. Nur Vornamen genügen.")
            }
        }
    }

    private var rhythmStep: some View {
        Section {
            RhythmForm(draft: $rhythm, slotSize: $slotSize)
        } footer: {
            Text("Der Rhythmus kann später geändert werden. Vergangene Termine bleiben erhalten.")
        }
    }

    private var periodStep: some View {
        Group {
            Section {
                DatePicker("Start", selection: $startDate, displayedComponents: .date)
                Stepper("Dauer: \(durationWeeks) Wochen", value: $durationWeeks, in: 1...104)
            } footer: {
                Text("Ergibt \(previewCount) Termine bis \(Fmt.numeric(endDay)).")
            }
        }
    }

    // MARK: Logic

    private var startDay: DayDate { DayDate(startDate) }
    private var endDay: DayDate { startDay.adding(days: durationWeeks * 7 - 1) }
    private var previewCount: Int { RhythmGenerator.dates(for: rhythm.rhythm, from: startDay, to: endDay).count }

    private func addMember() {
        let trimmed = newMemberName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= 40 else { return }
        memberNames.append(trimmed)
        memberWeights.append(1)
        newMemberName = ""
    }

    private func create() {
        let members = memberNames.indices.map { index in
            Member(name: memberNames[index], weight: memberWeights[index], colorIndex: index)
        }
        let plan = Plan(
            name: name.trimmingCharacters(in: .whitespaces),
            symbolName: symbolName,
            colorIndex: colorIndex,
            rhythm: rhythm.rhythm,
            startDate: startDay,
            endDate: endDay,
            slotSize: slotSize,
            showAttribution: attributionDefault,
            members: members
        )
        store.add(store.regenerate(plan))
        dismiss()
    }
}
