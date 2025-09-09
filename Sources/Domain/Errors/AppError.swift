import Foundation

/// Application-wide error type with user-friendly messages.
public enum AppError: LocalizedError, Equatable {
    case validation(String)
    case duplicateWear(String)
    case repository(String)
    case backupFailed(String)
    case restoreFailed(String)
    case incompatibleBackup(String)
    case deleteAllRequiresConfirmation

    public var errorDescription: String? {
        switch self {
        case .validation(let message):
            return message
        case .duplicateWear(let message):
            return message
        case .repository(let message):
            return message
        case .backupFailed(let message):
            return message
        case .restoreFailed(let message):
            return message
        case .incompatibleBackup(let message):
            return message
        case .deleteAllRequiresConfirmation:
            return "Two confirmations are required to delete all data."
        }
    }
}


