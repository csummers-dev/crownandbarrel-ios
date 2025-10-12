import Foundation

public struct ServiceStatus: Sendable, Equatable {
    public let watchId: UUID
    public let manufacturer: String
    public let modelName: String
    public let lastServiceDate: Date?
    public let warrantyUntil: Date?
}


