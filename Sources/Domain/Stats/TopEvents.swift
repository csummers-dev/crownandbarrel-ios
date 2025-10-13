import Foundation

public struct TopEventItem: Sendable, Equatable, Identifiable {
    public let id = UUID()
    public let title: String
    public let detail: String
    public let date: Date?
}


