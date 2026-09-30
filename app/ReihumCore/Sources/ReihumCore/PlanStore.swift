import Foundation
import Observation

/// Local-only persistence: one JSON file in Application Support, written atomically.
/// Nothing leaves the device unless the user shares or exports it.
///
/// Safety rules:
/// - Every change is normalised and validated before it is stored, so a file we wrote always loads again.
/// - A file that cannot be read is moved aside (never overwritten), and the app starts empty with a message.
/// - If it cannot be moved aside, saving is blocked so the unreadable file is never destroyed.
@Observable
public final class PlanStore {
    public private(set) var plans: [Plan] = []
    public var lastError: String?

    /// Called after every successful save, e.g. to reschedule local reminders.
    @ObservationIgnored public var onDidSave: (([Plan]) -> Void)?
    @ObservationIgnored private var writeProtected = false

    private let fileURL: URL
    private let now: () -> Date

    public init(fileURL: URL? = nil, now: @escaping () -> Date = { Date() }) {
        self.now = now
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = support.appendingPathComponent("Reihum", isDirectory: true).appendingPathComponent("plans.json")
        }
        load()
    }

    // MARK: Loading

    public func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            plans = []
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            plans = try BackupCodec.decode(data, maxBytes: 200_000_000)
            lastError = nil
        } catch {
            plans = []
            if let savedAs = moveUnreadableFileAside() {
                lastError = "Die gespeicherten Pläne konnten nicht gelesen werden. Die Datei wurde als «\(savedAs)» gesichert und geht nicht verloren. Ursache: \(error.localizedDescription)"
            } else {
                writeProtected = true
                lastError = "Die gespeicherten Pläne konnten nicht gelesen werden und die Datei konnte nicht gesichert werden. Speichern ist gesperrt, damit nichts überschrieben wird. Ursache: \(error.localizedDescription)"
            }
        }
    }

    private func moveUnreadableFileAside() -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let stamp = formatter.string(from: now())
        let folder = fileURL.deletingLastPathComponent()
        let base = fileURL.deletingPathExtension().lastPathComponent

        var target = folder.appendingPathComponent("\(base).unreadable-\(stamp).json")
        var counter = 1
        while FileManager.default.fileExists(atPath: target.path) {
            target = folder.appendingPathComponent("\(base).unreadable-\(stamp)-\(counter).json")
            counter += 1
        }
        do {
            try FileManager.default.moveItem(at: fileURL, to: target)
            return target.lastPathComponent
        } catch {
            return nil
        }
    }

    // MARK: Saving

    @discardableResult
    private func save() -> Bool {
        guard !writeProtected else {
            lastError = "Speichern ist gesperrt, weil die vorhandene Datei nicht gesichert werden konnte."
            return false
        }
        do {
            let data = try BackupCodec.encode(plans, now: now())
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            var options: Data.WritingOptions = [.atomic]
            #if os(iOS)
            options.insert(.completeFileProtectionUntilFirstUserAuthentication)
            #endif
            try data.write(to: fileURL, options: options)
            lastError = nil
            onDidSave?(plans)
            return true
        } catch {
            lastError = "Speichern fehlgeschlagen: \(error.localizedDescription)"
            return false
        }
    }

    /// Normalises and validates; on a problem the message is set and nothing is changed.
    private func accepted(_ plan: Plan) -> Plan? {
        let cleaned = plan.normalized()
        if let problem = PlanValidator.problem(in: cleaned) {
            lastError = "Der Plan konnte nicht gespeichert werden. \(problem)"
            return nil
        }
        return cleaned
    }

    // MARK: Changes

    public func plan(id: UUID) -> Plan? { plans.first { $0.id == id } }

    @discardableResult
    public func add(_ plan: Plan) -> Bool {
        guard plans.count < PlanLimits.maxPlans else {
            lastError = "Es sind höchstens \(PlanLimits.maxPlans) Pläne möglich."
            return false
        }
        guard let cleaned = accepted(plan) else { return false }
        plans.append(cleaned)
        return save()
    }

    @discardableResult
    public func update(_ plan: Plan) -> Bool {
        guard let index = plans.firstIndex(where: { $0.id == plan.id }) else { return false }
        guard let cleaned = accepted(plan) else { return false }
        plans[index] = cleaned
        return save()
    }

    public func delete(id: UUID) {
        plans.removeAll { $0.id == id }
        save()
    }

    public func deleteAll() {
        plans.removeAll()
        save()
    }

    /// Recomputes future, non-manual slots. History and manual slots stay.
    public func regenerate(_ plan: Plan, today: DayDate = DayDate.today(), overwriteManual: Bool = false) -> Plan {
        FairnessEngine.regenerate(plan, today: today, overwriteManual: overwriteManual)
    }

    // MARK: Export and import

    public func exportJSON() throws -> Data {
        try BackupCodec.encode(plans, pretty: true, now: now())
    }

    /// Adds imported plans; a plan with an existing ID replaces the old one.
    /// All-or-nothing: on any problem nothing is changed.
    public func importJSON(_ data: Data) throws -> Int {
        let imported = try BackupCodec.decode(data)
        var merged = plans
        for plan in imported {
            if let index = merged.firstIndex(where: { $0.id == plan.id }) {
                merged[index] = plan
            } else {
                merged.append(plan)
            }
        }
        guard merged.count <= PlanLimits.maxPlans else {
            throw BackupError.invalidContent("Danach gäbe es mehr als \(PlanLimits.maxPlans) Pläne.")
        }
        let previous = plans
        plans = merged
        guard save() else {
            plans = previous
            throw BackupError.invalidContent(lastError ?? "Speichern fehlgeschlagen.")
        }
        return imported.count
    }
}
