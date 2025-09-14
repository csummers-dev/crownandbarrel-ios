import Foundation

// What: This file intentionally contains no implementation.
// Why: The canonical `Appearance` enum is defined inside `CrownAndBarrelApp.swift` to ensure
//      the type is always included in the app target even if project references drift.
// How: Keeping this shim avoids Xcode project churn while preventing a duplicate type declaration
//      that would cause “invalid redeclaration of 'Appearance'” in CI.
