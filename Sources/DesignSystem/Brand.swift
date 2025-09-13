import Foundation

/// Centralized brand constants.
/// - What: Single source of truth for user-facing name and identifiers.
/// - Why: Avoid string drift across code, tests, and configurations.
/// - How: Read these constants wherever a brand string or identifier is needed.
enum Brand {
    static let appDisplayName: String = "Crown & Barrel"
    static let bundleIdentifier: String = "com.crownandbarrel.app"
}


