import SwiftUI

/// Remaining placeholder static pages

/// PrivacyPolicyView explains how the app treats user data.
/// - What: Static text describing local-only storage and optional permissions.
/// - Why: Transparency builds trust; users can confirm no network collection.
/// - How: Simple `ScrollView` + `VStack` with semantic headings for VO.
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Privacy Policy").font(.title)
                Text("Good Watch stores your data locally on your device. No data leaves your device unless you export a backup. We do not collect or process personal data.")
                Text("Permissions").font(.headline)
                Text("Photos access is used only to let you pick a watch image.")
                Text("Backups").font(.headline)
                Text("You can export a backup file and store it where you choose. Import fully replaces your current data.")
            }
            .padding()
        }
    }
}

/// AboutView shares the app vision and authorship at a glance.
/// - What: Minimal text content with headings for scannability.
/// - Why: Helps users understand intent and provenance of the product.
/// - How: Static layout in a `ScrollView` for small-screen accessibility.
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Good Watch")
                    .font(.title)
                Text("Vision: Beautiful, modern, and helpful watch box analytics.")
                Text("Design philosophy: Simple, focused, iOS-native.")
                Text("Developer: TBD")
                Text("This is an independent, open design focused app for enthusiasts.")
            }
            .padding()
        }
    }
}


