Crown & Barrel
===========

An open-source iOS app to manage a watch collection, track wear history, and visualize data insights.

![Branch: feature/ui-updates](https://img.shields.io/badge/branch-feature--ui--updates-1E90FF?style=flat&logo=github)
[![Build/Test CI](https://github.com/csummers-dev/crownandbarrel-ios/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/csummers-dev/crownandbarrel-ios/actions/workflows/ci.yml)
![SwiftLint](https://img.shields.io/badge/lint-SwiftLint-FA7343?logo=swift)
![Latest release](https://img.shields.io/github/v/release/csummers-dev/crownandbarrel-ios)

Key decisions
- iOS 17 minimum, iPhone only (portrait). Rationale: ensures modern full-screen behavior on iPhone devices, simplifies API surface (e.g., updated onChange), and avoids legacy compatibility modes. Landscape mode a consideration for future updates.
- Local persistence via Core Data
- Backup/restore is full replace (.goodwatch zip)

Architecture
- SwiftUI + Combine for UI and state
- MVVM + Repository pattern
- Core Data for persistence, file-based image storage
- Swift Charts for statistics, UICalendarView (wrapped) for calendar
- Design System for colors, typography, spacing, icons, and theme management

Redesign 2025-09 highlights
- Navigation: Inline titles on all tabs; per-tab NavigationStacks isolate behavior (e.g., search only on Collection).
- Tab bar: Subtle top hairline using UITabBarAppearance for visual separation.
- Stats: Replaced bar charts with full pie charts (SectorMark, iOS 17+) and a metallic-inspired palette (gold, silver, steel blue, emerald, graphite). Legends shown on trailing side.
- Collection: Compact sort/layout controls with reduced vertical spacing and small control size.
- Calendar: On date selection, the entries area animates a slight (4pt) downward offset; empty-state CTA reads “No watches worn this day. Add one?” which opens the add-worn sheet.
  - Divider spacing is fixed at ~4pt between calendar and entries to prevent overlap with the last week.
  - Entries list rows: compact watch thumbnail + “Manufacturer - Model”; manufacturer bolded, model regular.
  - After adding a worn entry, the list refreshes immediately.
- Tokens: Added `AppColors.chartPalette`, `AppColors.tabBarHairline`, `AppTypography.titleCompact`, and `AppSpacing.xxs` for finer tuning.

Launch splash overlay (theme-aware)
- What: A lightweight SwiftUI overlay shown immediately at app start.
- Why: Prevents a flash of unthemed content and matches the user's saved theme on boot.
- How: `CrownAndBarrelApp` wraps `RootView` in a `ZStack` and shows `SplashOverlay` (background = `AppColors.background`, text = `AppColors.textSecondary`). It fades out after the first frame using a short `DispatchQueue.main.asyncAfter` with an opacity transition.
- Tests: UI test asserts the splash appears on launch and dismisses within a short interval.

Theming (user-selectable)
- A JSON-driven theme catalog (`AppResources/Themes.json`) defines:
  - `accent`, `background`, `secondaryBackground`, `tertiaryBackground`, `separator`, `textPrimary`, `textSecondary`, `tabBarHairline`, `chartPalette` (5 colors)
  - `colorScheme`: `system`, `light`, or `dark` for `.preferredColorScheme`
- `ThemeCatalog` loads themes on launch; `ThemeManager` exposes the current theme via `@AppStorage("selectedThemeId")`.
- `AppColors` reads from the current theme; `brandGold` now aliases `accent`.
- Settings → Appearance exposes a combined "Theme" picker listing all entries from `Themes.json` with color swatches.
- Appearance proxies (tab bar/nav bar/segmented control) update when the theme changes.
  - Navigation titles and bar button items intentionally use themed secondary text by design.
  - Calendar labels in `UICalendarView` are themed via `UILabel.appearance(whenContainedInInstancesOf:)`.

Add or edit a theme
1) Edit `AppResources/Themes.json` (validate 5 colors under `chartPalette`).
2) Run the app; the new theme appears in Settings.
3) Ensure text contrast passes (primary ≥ 7:1, secondary ≥ 4.5:1). Unit tests verify this.

Assets (images)
- Preferred: Add a theme-aware placeholder in the asset catalog at `AppResources/Assets.xcassets/WatchEntryPlaceholder.imageset` (supports Light/Dark variants automatically).
- Fallback (raw files):
  - Light mode: `AppResources/Images/WatchEntryPlaceholder-LightMode-1000.png`
  - Dark mode: `AppResources/Images/WatchEntryPlaceholder-DarkMode-1000.png`
- Notes:
  - Use square PNGs (1000×1000 recommended) with transparent background.
  - The loader tries the asset catalog first (“WatchEntryPlaceholder”), then falls back to the raw Light/Dark PNGs.

Future enhancements
- Theming: Expand metallic theme application across headers and accents; user-selectable accent color.
- Stats: Full page redesign with richer charts, time filters (7/30/90/365), category breakdowns, and comparisons.
- Accessibility: VoiceOver summaries for pie segments; high-contrast fallback palette.
- Visual polish: Donut labels for pies; refined legends and spacing with tokens.
- Calendar depth: Per-day summaries and quick-add favorites.

Modules (source layout)
- `Sources/CrownAndBarrelApp`: app entry, root navigation, tab scaffolding
- `Sources/DesignSystem`: colors, typography, spacing, icons, theme manager
- `Sources/Domain`: models, errors, repository protocols
- `Sources/Common`: shared components and utilities (e.g., `WatchImageView`, `ImageStore`)
- `Sources/Features`: feature UIs (Collection, Stats, Calendar, Watch Detail, Watch Form)
- `Sources/Persistence`: Core Data stack, repositories, mappers

Getting started
1) Prerequisites: Xcode 16+, macOS with command line tools
2) Generate the Xcode project with XcodeGen (recommended)
   - Install: `brew install xcodegen`
   - Generate: `xcodegen generate`
   - Open: `open CrownAndBarrel.xcodeproj`
   - Run: Select a simulator (iPhone 16 or newer) and Build/Run
3) Build & run on iPhone simulator (iOS 17+)

Testing
- Unit test target covers domain, repositories, filters, and backup/restore. Includes a launch configuration check that guards against legacy letterboxing.
- UI tests cover collection, form, detail, calendar, stats, and full-screen launch behavior. Includes a collection image refresh verification after saving edits.
- Unit tests validate the app icon presence, theme-aware placeholders, and the square-cropping utility.
- CI (GitHub Actions): see build/test badge above; workflow runs `xcodebuild test`.
- Run locally: `xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test`

Platform and device support
- Minimum iOS version: 17.0
  - Why: Avoids legacy layout modes; enables updated SwiftUI APIs; reduces compatibility risk.
- Devices: iPhone only, portrait orientation
  - Why: Phone-first UX and simpler safe-area/layout semantics.

Launch and full-screen behavior
- Uses a modern Launch Screen (UILaunchStoryboardName) to signal contemporary device support; prevents letterboxing on iPhone 16/16 Pro. Safe areas are respected throughout (NavigationStack, TabView, safeAreaInset where needed).
- Ensure Info.plist contains:
  - `UILaunchStoryboardName` = `LaunchScreen` (file at `AppResources/LaunchScreen.storyboard`).

Image selection and cropping
- All watch images are enforced to be square:
  - Selection: images are center-cropped to square on import.
  - Persistence: images are re-validated as square before saving.
  - Display: grid tiles (120×120) and list thumbnails (56×56) use a fixed square size with `.scaledToFill()` in a rounded container.
  - Detail: watch pages show an image header (user image or theme-aware placeholder) above details.

### App icon
- **Place base 1024px PNG**: `AppResources/AppIcon-1024.png` (square, no rounded corners).
- **Generate all sizes**: `./AppResources/icongen.sh AppResources/AppIcon-1024.png`.
  - Outputs to `AppResources/Assets.xcassets/AppIcon.appiconset` with a preconfigured `Contents.json`.
- **Project setup**: `project.yml` sets `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon`; Xcode picks it up on generate/build.
- **Notes**:
  - Keep edges within the HIG safe area; no transparency padding.
  - Marketing icon (1024) is included as `ios-marketing`.

### Commenting standards (What, Why, How)
- **Goal**: Make code self-explanatory for future maintainers without refactoring behavior.
- **Principle**: Comment intent and tradeoffs; avoid narrating obvious syntax.
- **Where to comment**:
  - **Types (struct/class/enum)**: Start with a short block that explains the feature’s role.
  - **Public/internal methods**: Describe the “what” (purpose), “why” (reasoning/business rule), and “how” (non-obvious algorithm or side effect). Include threading/async and error behavior.
  - **Stored properties**: Only when the meaning isn’t obvious from the name or when constraints matter.
  - **Conditionals/branches**: When guarding edge cases, explain the invariant or risk avoided.
- **Style**:
  - Prefer concise sentences; use bullet lists for multi-point rationale.
  - Use domain language users would recognize (e.g., “wear entry,” “backup replace-only”).
  - Keep comments up-to-date in the same edit that changes behavior.
- **Examples applied in this codebase**:
  - Core Data stack: Why programmatic model and merge policies are used; why in-memory tests avoid batch deletes.
  - Calendar UIKit wrapper: Why `UICalendarView` via representable and how selection normalization reloads entries.
  - Repositories: How denormalized fields (timesWorn/lastWornDate) help sorting, and why uniqueness checks exist.
  - App Data flows: Why import is replace-only; how export uses a temporary URL + FileDocument wrapper.
  - Theme: Why `@AppStorage` with raw value ties into `ThemeManager` and `preferredColorScheme`.
- **Error messages**:
  - Must be clear, concise, and informative; prefer actionable wording (what failed; what the user can try).
  - Surface domain errors via `LocalizedError` with human-friendly descriptions.
- **Accessibility and UX notes**:
  - Call out VoiceOver labels and Dynamic Type-sensitive components where non-standard.
  - Note when haptics are used for feedback and why.
  
### Rationale highlights (design choices)
- **iOS 17+, iPhone portrait only**: Ensures modern safe areas and avoids legacy, letterboxed modes. Simplifies API usage (e.g., updated `onChange`) and reduces compatibility surface.
- **Core Data + programmatic model**: Single source of truth in code, fewer Xcode model merge issues, explicit schema evolution.
- **Replace-only backups (.goodwatch)**: Prevents partial merges and conflict ambiguity. Import is deterministic; export is transparent (JSON + images).
- **Local image files**: Keeps Core Data light, enables efficient file operations and easier backup packaging.
- **MVVM + Repository**: Decouples UI from persistence, enabling testability and future storage changes.

Seeding sample data (optional)
- Use the App Data screen (Settings → App Data) and tap "Load sample data" in Debug builds.

Backup format (.goodwatch)
- metadata.json (app version, schema version, export date)
- watches.json
- wear_entries.json
- images/ (image files referenced by watches)

Accessibility
- Dynamic Type, sufficient contrast, 44pt hit targets
- VoiceOver labels and hints on interactive elements
 - Reduced motion support, haptics for key interactions

Roadmap (high → low)
1) Collection, Watch Form, Watch Detail, Calendar, Stats
2) Settings and App Data (backup/restore/delete)
3) Privacy Policy and About
4) Polish and advanced insights

Troubleshooting (paths and project generation)
- XcodeGen: “Decoding failed at "path": Nothing found”
  - Ensure referenced folders exist before generating: `Sources`, `Tests/Unit`, `Tests/UITests`, and `AppResources` (if listed in `project.yml`).
    - Check quickly:
      ```bash
      ls -la; ls -la Sources; ls -la Tests; ls -la AppResources
      ```
  - If you recently added a new folder (e.g., `AppResources`), create it first, then run `xcodegen generate` again.
  - Verify YAML indentation uses spaces (no tabs) and keys are correctly spelled:
    ```yaml
    targets:
      CrownAndBarrel:
        sources:
          - path: Sources
          - path: AppResources
    ```
  - Try a minimal spec temporarily to isolate the issue, then add entries back:
    ```yaml
    targets:
      CrownAndBarrel:
        type: application
        platform: iOS
        sources:
          - path: Sources
    ```
  - Use these helpers to debug the spec:
    ```bash
    xcodegen dump | cat
    ruby -ryaml -e 'puts YAML.load_file("project.yml").to_s' | cat
    ```
  - If the error persists, try absolute paths as a diagnostic (shouldn’t be needed long-term):
    ```yaml
    sources:
      - path: /Users/yourname/Developer/CrownAndBarrel/Sources
    ```
  - Clean any stale project and DerivedData, then regenerate:
    ```bash
    rm -rf CrownAndBarrel.xcodeproj
    rm -rf ~/Library/Developer/Xcode/DerivedData/CrownAndBarrel-*
    xcodegen generate
    ```

- App resources not copied/recognized
  - Ensure `AppResources/` is listed under `targets.CrownAndBarrel.sources` and exists on disk.
  - For Launch Screen, include `AppResources/LaunchScreen.storyboard` and set in `project.yml`:
    ```yaml
    info:
      properties:
        UILaunchStoryboardName: LaunchScreen
    ```
  - Letterboxed/legacy appearance on iPhone 16/Pro:
    - Verify `AppResources/Info.plist` includes:
      ```xml
      <key>UILaunchStoryboardName</key>
      <string>LaunchScreen</string>
      ```
    - Clean build folder and rebuild. If the simulator still shows letterboxing, erase the simulator content (Device → Erase All Content and Settings) and relaunch.

- Simulator destination not found
  - Pick an available simulator shown by:
    ```bash
    xcrun simctl list devices | grep -E "iPhone 1|Booted"
    ```
  - Update the destination, for example: `-destination 'platform=iOS Simulator,name=iPhone 16'`.

- Test targets: Info.plist error
  - Ensure auto-Info generation is enabled for test targets in `project.yml`:
    ```yaml
    settings:
      base:
        GENERATE_INFOPLIST_FILE: YES
    ```

Minimal project.yml example
```yaml
name: CrownAndBarrel
options:
  deploymentTarget:
    iOS: "17.0"
targets:
  CrownAndBarrel:
    type: application
    platform: iOS
    sources:
      - path: Sources
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.goodwatch.app
        GENERATE_INFOPLIST_FILE: YES
```

Bootstrap script (create folders, then generate the project)
```bash
#!/usr/bin/env bash
set -euo pipefail

# Create expected directories if missing
mkdir -p Sources \
         Tests/Unit \
         Tests/UITests \
         AppResources

# Optional: ensure a minimal project.yml exists
if [ ! -f project.yml ]; then
  cat > project.yml <<'YAML'
name: CrownAndBarrel
options:
  deploymentTarget:
    iOS: "17.0"
targets:
  CrownAndBarrel:
    type: application
    platform: iOS
    sources:
      - path: Sources
      - path: AppResources
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.goodwatch.app
        GENERATE_INFOPLIST_FILE: YES
  CrownAndBarrelTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: Tests/Unit
    settings:
      base:
        GENERATE_INFOPLIST_FILE: YES
    dependencies:
      - target: CrownAndBarrel
  CrownAndBarrelUITests:
    type: bundle.ui-testing
    platform: iOS
    sources:
      - path: Tests/UITests
    settings:
      base:
        GENERATE_INFOPLIST_FILE: YES
    dependencies:
      - target: CrownAndBarrel
YAML
fi

# Generate the Xcode project
xcodegen generate
echo "Generated CrownAndBarrel.xcodeproj"
```


