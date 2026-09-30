import Foundation

/// The on-disk and export format: a small envelope with a schema version around the plans.
public struct BackupFile: Codable, Equatable {
    public static let currentSchemaVersion = 1
    public var schemaVersion: Int
    public var exportedAt: Date
    public var plans: [Plan]
}

public enum BackupError: Error, Equatable, LocalizedError {
    case tooLarge
    case notABackup
    case newerVersion(Int)
    case invalidContent(String)

    public var errorDescription: String? {
        switch self {
        case .tooLarge:
            return "Die Datei ist zu gross."
        case .notABackup:
            return "Die Datei ist keine gültige Reihum-Sicherung."
        case .newerVersion:
            return "Die Datei stammt aus einer neueren Version von Reihum. Bitte aktualisiere die App."
        case .invalidContent(let reason):
            return "Die Sicherung enthält ungültige Daten. \(reason)"
        }
    }
}

public enum BackupCodec {
    private struct Header: Decodable { let schemaVersion: Int }

    private static func makeEncoder(pretty: Bool) -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = pretty ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public static func encode(_ plans: [Plan], pretty: Bool = false, now: Date = Date()) throws -> Data {
        let file = BackupFile(schemaVersion: BackupFile.currentSchemaVersion, exportedAt: now, plans: plans)
        return try makeEncoder(pretty: pretty).encode(file)
    }

    /// All-or-nothing: either every plan in the file is valid and returned, or an error is thrown.
    public static func decode(_ data: Data, maxBytes: Int = PlanLimits.maxImportBytes) throws -> [Plan] {
        guard data.count <= maxBytes else { throw BackupError.tooLarge }
        let decoder = makeDecoder()

        guard let header = try? decoder.decode(Header.self, from: data), header.schemaVersion >= 1 else {
            throw BackupError.notABackup
        }
        guard header.schemaVersion <= BackupFile.currentSchemaVersion else {
            throw BackupError.newerVersion(header.schemaVersion)
        }
        guard let file = try? decoder.decode(BackupFile.self, from: data) else {
            throw BackupError.notABackup
        }

        guard file.plans.count <= PlanLimits.maxPlans else {
            throw BackupError.invalidContent("Zu viele Pläne (höchstens \(PlanLimits.maxPlans)).")
        }
        guard Set(file.plans.map(\.id)).count == file.plans.count else {
            throw BackupError.invalidContent("Ein Plan kommt doppelt vor.")
        }
        for plan in file.plans {
            if let problem = PlanValidator.problem(in: plan) {
                throw BackupError.invalidContent("Plan «\(plan.name.prefix(30))»: \(problem)")
            }
        }
        return file.plans
    }
}
