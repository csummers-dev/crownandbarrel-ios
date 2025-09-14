import SwiftUI
import WebKit
import UIKit

/// Remaining placeholder static pages

/// PrivacyPolicyView renders the privacy policy from a bundled HTML file.
/// - What: Loads `PrivacyPolicy.html` from the app bundle with graceful fallback.
/// - Why: Keeps content editable without a code change; supports rich formatting.
/// - How: Wraps a `WKWebView` inside SwiftUI and loads the HTML string.
struct PrivacyPolicyView: View {
    @State private var htmlContent: String? = nil

    var body: some View {
        Group {
            if let htmlContent {
                HTMLWebView(html: htmlContent)
            } else {
                ProgressView()
                    .onAppear { loadHTMLFromBundle() }
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background.ignoresSafeArea())
    }

    private func loadHTMLFromBundle() {
        if let url = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "html"),
           let data = try? Data(contentsOf: url),
           let html = String(data: data, encoding: .utf8) {
            htmlContent = html
        } else {
            htmlContent = """
            <h1>Privacy Policy</h1>
            <p>This policy could not be loaded from the bundled file. \(Brand.appDisplayName) stores your data locally on your device. No data leaves your device unless you export a backup.</p>
            """
        }
    }
}

/// Minimal SwiftUI wrapper around `WKWebView` to render provided HTML and open external links.
private struct HTMLWebView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        webView.loadHTMLString(wrappedHTML(from: html), baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(wrappedHTML(from: html), baseURL: nil)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    private func wrappedHTML(from content: String) -> String {
        """
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
            <meta name="color-scheme" content="light dark">
            <style>
              :root { color-scheme: light dark; }
              body { font: -apple-system-body; padding: 16px; margin: 0; }
              h1 { font: -apple-system-headline; }
              h2 { font: -apple-system-subheadline; margin-top: 1.25em; }
              h3 { font: -apple-system-subheadline; margin-top: 1em; }
              a { color: -apple-system-blue; }
              ul { padding-left: 1.2em; }
            </style>
          </head>
          <body>
            \(content)
          </body>
        </html>
        """
    }
}

/// AboutView shares the app vision, authorship, contact, and roadmap.
/// - What: Static sections styled like Settings/App Data using a Form with primary backgrounds.
/// - Why: Consistent visual language and readability across the app.
/// - How: Plain header rows + native sections with empty headers to avoid system tints.
struct AboutView: View {
    @Environment(\.themeToken) private var themeToken

    var body: some View {
        Form {
            headerRow("About")
            Section {
                Text("Crown & Barrel is your companion for a life of timepieces. It keeps your collection organized with simplicity and elegance, captures the memories of each wear, and distills insights into visualizations. Thoughtfully designed for iOS, Crown & Barrel favors clarity over clutter and longevity over noise. Crown & Barrel will always be free and open-source. Developed with love by @csummers-dev.")
                    .listRowBackground(AppColors.background)
            } header: { EmptyView() }

            headerRow("Developer")
            Section {
                HStack {
                    Text("GitHub")
                    Spacer(minLength: 0)
                    Link("@csummers-dev", destination: URL(string: "https://github.com/csummers-dev")!)
                }
                .listRowBackground(AppColors.background)
                HStack {
                    Text("Email")
                    Spacer(minLength: 0)
                    Link("csummersdev@icloud.com", destination: URL(string: "mailto:csummersdev@icloud.com")!)
                }
                .listRowBackground(AppColors.background)
                Text("Have a feature request or need support? Reach out anytime.")
                    .listRowBackground(AppColors.background)
            } header: { EmptyView() }

            headerRow("Roadmap")
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Theming: Expand palettes and live accent options, more app icons")
                    Text("• Stats: Richer charts, time filters (7/30/90/365), comparisons")
                    Text("• Accessibility: VoiceOver summaries, high-contrast palette")
                    Text("• Visual polish: Donut labels, refined spacing and legends")
                    Text("• Calendar: Per-day summaries, quick-add favorites")
                    Text("• Haptics: Richer, tactile feedback for key interactions")
                }
                .listRowBackground(AppColors.background)
            } header: { EmptyView() }
        }
        .listSectionSeparator(.hidden, edges: .all)
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .listSectionSpacing(.custom(0))
        .contentMargins(.top, -8, for: .scrollContent)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("About")
                    .font(AppTypography.titleCompact)
                    .foregroundStyle(AppColors.accent)
            }
        }
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .id(themeToken + "-about-form")
    }
}

private extension AboutView {
    /// Plain header row mirroring Settings style to avoid UIKit grouped header backgrounds.
    func headerRow(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.none)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, -6)
        .listRowSeparator(.hidden)
        .listRowBackground(AppColors.background)
    }
}


