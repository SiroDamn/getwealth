import Foundation
import Observation
import ReihumCore

/// Local-only persistence: one JSON file in Application Support, written atomically.
/// Nothing ever leaves the device unless the user shares it.
@Observable
final class PlanStore {
    private(set) var plans: [Plan] = []
    var lastError: String?

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let folder = support.appendingPathComponent("Reihum", isDirectory: true)
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            self.fileURL = folder.appendingPathComponent("plans.json")
        }
        load()
    }

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            plans = try Self.decoder.decode([Plan].self, from: data)
            lastError = nil
        } catch {
            lastError = "Die gespeicherten Pläne konnten nicht gelesen werden: \(error.localizedDescription)"
        }
    }

    private func save() {
        do {
            let data = try Self.encoder.encode(plans)
            var options: Data.WritingOptions = [.atomic]
            #if os(iOS)
            options.insert(.completeFileProtectionUntilFirstUserAuthentication)
            #endif
            try data.write(to: fileURL, options: options)
            lastError = nil
        } catch {
            lastError = "Speichern fehlgeschlagen: \(error.localizedDescription)"
        }
        if UserDefaults.standard.bool(forKey: "remindersEnabled") {
            ReminderManager.shared.reschedule(plans: plans)
        }
    }

    func plan(id: UUID) -> Plan? { plans.first { $0.id == id } }

    func add(_ plan: Plan) {
        plans.append(plan)
        save()
    }

    func update(_ plan: Plan) {
        guard let index = plans.firstIndex(where: { $0.id == plan.id }) else { return }
        plans[index] = plan
        save()
    }

    func delete(id: UUID) {
        plans.removeAll { $0.id == id }
        save()
    }

    func deleteAll() {
        plans.removeAll()
        save()
    }

    /// Recomputes future, non-manual slots. History and manual slots stay.
    func regenerate(_ plan: Plan, overwriteManual: Bool = false) -> Plan {
        FairnessEngine.regenerate(plan, today: DayDate.today(), overwriteManual: overwriteManual)
    }

    func exportJSON() throws -> Data {
        try Self.encoder.encode(plans)
    }

    /// Adds imported plans. Plans with an existing ID are replaced.
    func importJSON(_ data: Data) throws -> Int {
        guard data.count < 20_000_000 else {
            throw NSError(domain: "Reihum", code: 1, userInfo: [NSLocalizedDescriptionKey: "Die Datei ist zu gross."])
        }
        let imported = try Self.decoder.decode([Plan].self, from: data)
        for plan in imported {
            if let index = plans.firstIndex(where: { $0.id == plan.id }) {
                plans[index] = plan
            } else {
                plans.append(plan)
            }
        }
        save()
        return imported.count
    }
}
