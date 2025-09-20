# Development Guide

This guide provides detailed instructions for setting up, building, and testing Crown & Barrel for development.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Project Structure](#project-structure)
- [Building the App](#building-the-app)
- [Testing](#testing)
- [Development Tools](#development-tools)
- [Debugging](#debugging)
- [Performance Analysis](#performance-analysis)

## Prerequisites

### System Requirements
- **macOS**: macOS 14.0+ (Sonoma or later)
- **Xcode**: Xcode 16.0+ with iOS 17.0+ SDK
- **Command Line Tools**: Latest version installed
- **Git**: For version control
- **Homebrew**: For package management

### Required Tools
- **XcodeGen**: For project generation
- **SwiftLint**: For code style enforcement (optional but recommended)

## Setup Instructions

### 1. Clone the Repository
```bash
# Clone the main repository
git clone https://gitlab.com/csummersdev/crown-and-barrel.git
cd crown-and-barrel

# Or clone your fork (for contributors)
git clone https://gitlab.com/YOUR_USERNAME/crown-and-barrel.git
cd crown-and-barrel
```

### 2. Install Dependencies
```bash
# Install XcodeGen via Homebrew
brew install xcodegen

# Verify installation
xcodegen --version
```

### 3. Generate Xcode Project
```bash
# Generate the Xcode project from project.yml
xcodegen generate

# Verify project was created
ls -la CrownAndBarrel.xcodeproj
```

### 4. Open in Xcode
```bash
# Open the project in Xcode
open CrownAndBarrel.xcodeproj
```

### 5. Configure Simulator
- Select **iPhone 16** simulator (or newer)
- Ensure simulator is running iOS 17.0+
- If needed, create a new simulator:
  ```bash
  xcrun simctl create "iPhone 16" "iPhone 16" "iOS17.0"
  ```

### 6. Build and Run
- In Xcode, select the **CrownAndBarrel** scheme
- Choose **iPhone 16** as the destination
- Press **⌘+R** to build and run

## Project Structure

### Source Organization
```
Sources/
├── CrownAndBarrelApp/     # App entry point and root navigation
│   ├── CrownAndBarrelApp.swift    # Main app file with SwiftUI App
│   ├── RootView.swift             # Root navigation structure
│   ├── Appearance.swift           # Global appearance configuration
│   └── Placeholders.swift         # Placeholder data and images
│
├── DesignSystem/          # Design tokens and theming
│   ├── ThemeManager.swift         # Theme switching and management
│   ├── ThemeCatalog.swift         # Available themes
│   ├── ThemeToken.swift           # Theme token definitions
│   ├── Colors.swift               # Color definitions
│   ├── Typography.swift           # Font and text styles
│   ├── Spacing.swift              # Spacing tokens
│   ├── Radius.swift               # Corner radius tokens
│   ├── Layout.swift               # Layout constants
│   ├── Icons.swift                # Icon definitions
│   └── Brand.swift                # Brand-specific styling
│
├── Domain/               # Business logic and models
│   ├── Models/
│   │   ├── Watch.swift            # Watch entity model
│   │   ├── WearEntry.swift        # Wear entry model
│   │   └── Enums.swift            # Domain enumerations
│   ├── Protocols/
│   │   ├── WatchRepository.swift  # Watch data access protocol
│   │   └── BackupRepository.swift # Backup/restore protocol
│   └── Errors/
│       └── AppError.swift         # Application error types
│
├── Features/             # Feature-specific UI and logic
│   ├── Collection/                # Watch collection management
│   │   ├── CollectionView.swift           # Main collection view
│   │   └── CollectionViewModel.swift      # Collection business logic
│   ├── Calendar/                  # Calendar and wear tracking
│   │   └── CalendarView.swift             # Calendar interface
│   ├── Stats/                     # Analytics and statistics
│   │   └── StatsView.swift                # Statistics display
│   ├── WatchDetail/               # Individual watch details
│   │   └── WatchDetailView.swift          # Watch detail interface
│   ├── WatchForm/                 # Watch creation/editing
│   │   ├── WatchFormView.swift            # Watch form interface
│   │   └── WatchFormViewModel.swift       # Form business logic
│   └── Settings/                  # App configuration
│       ├── SettingsView.swift             # Settings interface
│       └── AppDataView.swift              # Data management
│
├── Persistence/          # Data layer implementation
│   ├── CoreDataStack.swift        # Core Data setup and configuration
│   ├── WatchRepositoryCoreData.swift # Core Data repository implementation
│   ├── BackupRepositoryFile.swift # File-based backup implementation
│   └── Mappers.swift              # Entity mapping utilities
│
└── Common/               # Shared utilities and components
    ├── Components/
    │   └── WatchImageView.swift   # Reusable watch image component
    └── Utilities/
        ├── AppEvents.swift        # App-wide event handling
        ├── DateUtils.swift        # Date manipulation utilities
        ├── Haptics.swift          # Haptic feedback utilities
        ├── ImageStore.swift       # Image storage and management
        └── SampleData.swift       # Sample data for testing
```

### Test Organization
```
Tests/
├── Unit/                # Unit tests
│   ├── AssetsPresenceTests.swift      # Asset validation tests
│   ├── ContrastTests.swift            # Color contrast tests
│   ├── FiltersAndBackupTests.swift    # Backup/restore tests
│   ├── ImageStoreCropTests.swift      # Image processing tests
│   ├── LaunchConfigurationTests.swift # App launch tests
│   ├── MoreRepositoryTests.swift      # Repository tests
│   ├── RadiusTokensTests.swift        # Design token tests
│   ├── SpacingTokensTests.swift       # Spacing tests
│   ├── ThemeCatalogTests.swift        # Theme system tests
│   ├── ThemeDefaultingTests.swift     # Theme defaulting tests
│   ├── ThemeResolutionTests.swift     # Theme resolution tests
│   ├── WatchFormViewModelTests.swift  # Form logic tests
│   └── WatchRepositoryTests.swift     # Data layer tests
│
└── UITests/             # UI tests
    ├── AccentColorUITests.swift        # Accent color tests
    ├── AddWatchFlowUITests.swift       # Watch creation flow
    ├── AppDataToastUITests.swift       # Data management UI
    ├── CalendarAndDetailUITests.swift  # Calendar and detail views
    ├── CalendarListBackgroundUITests.swift # Calendar styling
    ├── CollectionCardStyleUITests.swift # Collection styling
    ├── CollectionGridSizingUITests.swift # Grid layout tests
    ├── CollectionImageRefreshUITests.swift # Image refresh tests
    ├── CollectionSpacingUITests.swift  # Collection spacing
    ├── DetailWornTodayUITests.swift    # Detail view tests
    ├── FullScreenLaunchUITests.swift   # App launch tests
    ├── PrivacyPolicyUITests.swift      # Privacy policy tests
    ├── SettingsAppearanceHeaderUITests.swift # Settings UI
    ├── StatsTitleUITests.swift         # Statistics UI
    ├── StatsUITests.swift              # Statistics functionality
    └── ThemeLiveRefreshUITests.swift   # Theme switching tests
```

## Building the App

### Xcode Build
1. **Select Scheme**: Choose `CrownAndBarrel` scheme
2. **Select Destination**: Choose `iPhone 16` simulator
3. **Build**: Press **⌘+B** or use Product → Build
4. **Run**: Press **⌘+R** or use Product → Run

### Command Line Build
```bash
# Build the project
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build and run
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Debug vs Release
- **Debug**: Default configuration with debugging symbols
- **Release**: Optimized build for performance testing

## Testing

### Running Tests in Xcode
1. **Select Test Target**: Choose `CrownAndBarrelTests` or `CrownAndBarrelUITests`
2. **Run Tests**: Press **⌘+U** or use Product → Test
3. **View Results**: Check test results in the Test Navigator

### Command Line Testing
```bash
# Run all tests
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run unit tests only
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelTests

# Run UI tests only
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelUITests
```

### Test Categories
- **Unit Tests**: Business logic, repositories, utilities
- **UI Tests**: User flows, theme switching, form validation
- **Integration Tests**: Core Data, backup/restore, image handling

### Test Data
- **Sample Data**: Available in debug builds via `SampleData.swift`
- **Test Fixtures**: Use consistent test data for reproducible tests
- **Mock Objects**: Mock external dependencies for isolated testing

## Development Tools

### XcodeGen
- **Purpose**: Generate Xcode project from `project.yml`
- **Usage**: `xcodegen generate`
- **Benefits**: Version control friendly, consistent project structure

### SwiftLint
- **Purpose**: Automated code style enforcement
- **Installation**: `brew install swiftlint`
- **Usage**: Run from Xcode or command line
- **Configuration**: `.swiftlint.yml` in project root

### Git Hooks
- **Pre-commit**: Run SwiftLint before commits
- **Pre-push**: Run tests before pushing
- **Setup**: Install hooks in `.git/hooks/`

### Simulator Management
```bash
# List available simulators
xcrun simctl list devices

# Boot specific simulator
xcrun simctl boot "iPhone 16"

# Reset simulator
xcrun simctl erase "iPhone 16"

# Take screenshot
xcrun simctl io "iPhone 16" screenshot screenshot.png
```

## Debugging

### Xcode Debugger
- **Breakpoints**: Set breakpoints in code
- **LLDB Commands**: Use LLDB for advanced debugging
- **View Debugger**: Debug SwiftUI view hierarchy
- **Memory Graph**: Debug memory issues

### Console Logging
- **os_log**: Use structured logging
- **print()**: For temporary debugging
- **assert()**: For development assertions
- **precondition()**: For critical checks

### Common Debug Scenarios
- **Core Data Issues**: Check persistent store and migrations
- **Theme Problems**: Verify theme loading and application
- **Image Loading**: Check image store and caching
- **Performance**: Use Instruments for profiling

## Performance Analysis

### Instruments
- **Time Profiler**: CPU usage and performance bottlenecks
- **Memory Graph**: Memory usage and leaks
- **Core Animation**: UI performance and rendering
- **Energy Log**: Battery usage optimization

### SwiftUI Performance
- **View Updates**: Minimize unnecessary view updates
- **State Management**: Use appropriate state types
- **Image Loading**: Optimize image loading and caching
- **List Performance**: Use efficient list implementations

### Core Data Performance
- **Fetch Requests**: Optimize fetch predicates and sorting
- **Batch Operations**: Use batch updates for large operations
- **Background Contexts**: Perform heavy operations off main thread
- **Memory Management**: Proper context lifecycle management

### Memory Management
- **Weak References**: Use weak references to prevent retain cycles
- **Image Caching**: Implement proper image cache limits
- **Context Cleanup**: Properly dispose of Core Data contexts
- **Memory Warnings**: Handle memory warnings appropriately

## Build System Checklist

### Pre-Commit Build Verification
Before committing code, ensure the following:

#### ✅ **Compilation Compliance**
- [ ] **Build Success**: `xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel build` succeeds
- [ ] **No Compilation Errors**: Zero compilation errors in build output
- [ ] **Sendable Warnings**: Acceptable (warnings only, not errors)
- [ ] **Static Analysis**: No critical static analysis warnings

#### ✅ **Core Data Patterns**
- [ ] **Weak References**: All Core Data closures use `[weak self, weak stack]`
- [ ] **Guard Statements**: Proper guard statements for safe unwrapping
- [ ] **Return Statements**: Explicit return statements in closures with return types
- [ ] **Error Handling**: Proper error propagation with `AppError.unknown`

#### ✅ **Code Quality**
- [ ] **Variable Declaration**: Use `let` for immutable variables
- [ ] **Static Member Access**: Explicit type qualification (e.g., `AppIconSize.iPhoneIcons`)
- [ ] **Notification Handling**: No invalid notification names
- [ ] **Error Types**: All errors use `AppError` enum

#### ✅ **Asset Management**
- [ ] **App Icons**: All icons properly referenced in `Contents.json`
- [ ] **File Cleanup**: No `.DS_Store` files in asset directories
- [ ] **Dark Mode**: Proper light/dark mode variants (except marketing icons)
- [ ] **Icon Generation**: Use `./scripts/generate-app-icons.sh` for icon updates

#### ✅ **Documentation**
- [ ] **Code Comments**: Inline documentation for complex logic
- [ ] **Architecture Updates**: Update `ARCHITECTURE.md` for significant changes
- [ ] **Troubleshooting**: Update `TROUBLESHOOTING.md` for new issues
- [ ] **API Documentation**: Document public interfaces and methods

### Build Failure Recovery
If build fails, follow this recovery sequence:

1. **Check Compilation Errors**:
   ```bash
   xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel build 2>&1 | grep -E "error:|warning:" | head -10
   ```

2. **Fix Sendable Warnings**:
   - Add `[weak self, weak stack]` to Core Data closures
   - Add guard statements for safe unwrapping
   - Add explicit return statements

3. **Fix Asset Issues**:
   ```bash
   # Clean up asset directory
   rm AppResources/Assets.xcassets/AppIcon.appiconset/.DS_Store
   rm AppResources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024-dark.png
   ```

4. **Regenerate Project** (if needed):
   ```bash
   xcodegen generate
   ```

5. **Clean Build**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   xcodebuild clean -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel
   ```

### Critical Anti-Patterns (NEVER DO)
- ❌ **Never remove `[weak self]` from Core Data closures**
- ❌ **Never use `[self, stack]` in Core Data closures**
- ❌ **Never omit return statements in closures with return types**
- ❌ **Never add `.DS_Store` files to asset directories**
- ❌ **Never create dark mode variants for marketing icons (1024x1024)**
- ❌ **Never use invalid notification names**
- ❌ **Never omit `AppError.unknown` case**
- ❌ **Never bypass haptic debouncing for rapid interactions**
- ❌ **Never use inappropriate haptic intensities for interaction types**
- ❌ **Never omit haptic feedback for critical user actions**

## Haptic Development Guidelines

### **Haptic Integration Standards**
- **Contextual Feedback**: Use appropriate haptic methods for different interaction types
- **Performance**: Always use `Haptics.debouncedHaptic()` for rapid interactions
- **Accessibility**: Provide enhanced feedback for accessibility users when appropriate
- **Consistency**: Follow established patterns for similar interaction types
- **Testing**: Include haptic testing in all UI interaction tests

### **Haptic Method Selection**
- **Light Impact**: Subtle interactions (taps, selections, navigation)
- **Medium Impact**: Important actions (saves, changes, confirmations)
- **Heavy Impact**: Critical operations (deletions, resets, warnings)
- **Success Notification**: Completed operations (saves, successful data entry)
- **Error**: Validation failures, operation failures
- **Warning**: Cautionary actions, potentially destructive operations

### **Haptic Integration Patterns**
```swift
// Collection View Interactions
Haptics.collectionInteraction()              // Card selection
Haptics.searchInteraction(.filterChange)     // Sort/filter changes
Haptics.debouncedHaptic { Haptics.lightImpact() }  // Rapid interactions

// Form Interactions
Haptics.formInteraction()                    // Field focus
Haptics.successNotification()                // Successful save
Haptics.error()                              // Validation failure

// Accessibility Enhancement
Haptics.accessibleInteraction(.elementSelected)  // Enhanced feedback
```

### **Haptic Testing Requirements**
- **Unit Tests**: Test all haptic methods execute without errors
- **UI Tests**: Verify haptic integration doesn't break functionality
- **Performance Tests**: Ensure haptic calls complete within acceptable time
- **Accessibility Tests**: Verify enhanced feedback works correctly
- **Device Tests**: Test on actual hardware to verify haptic intensity

---

*This development guide is maintained by the Crown & Barrel development team. For questions or suggestions about development setup, please create an issue or contact the development team.*
