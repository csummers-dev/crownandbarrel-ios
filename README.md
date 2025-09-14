# Crown & Barrel

[![Build/Test CI](https://github.com/csummers-dev/crownandbarrel-ios/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/csummers-dev/crownandbarrel-ios/actions/workflows/ci.yml)
![SwiftLint](https://img.shields.io/badge/lint-SwiftLint-FA7343?logo=swift)
![Latest release](https://img.shields.io/github/v/release/csummers-dev/crownandbarrel-ios)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue?logo=ios)

An elegant iOS app for managing your watch collection, tracking wear history, and visualizing insights. Built with privacy in mind. Ad-free and open-source.

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Requirements](#requirements)
- [Privacy & Data](#privacy--data)
- [Contributing](#contributing)
- [Development](#development)
- [Architecture](#architecture)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features

### 🎨 **Beautiful Design**
- **6 Themed Color Schemes**: Daytime, Nighttime, Pastel, Forest, Ocean, and Sunset
- **System-Based Defaults**: Automatically matches your device's appearance on first launch
- **Consistent UI**: Unified design language across all screens

### ⌚ **Watch Collection Management**
- **Add & Edit Watches**: Comprehensive details including manufacturer, model, serial numbers, and photos
- **Optional Date Fields**: Purchase date, warranty expiration, service dates, and sale information
- **Favorite System**: Mark your most-worn watches as favorites
- **Smart Search**: Find watches by manufacturer, model, or reference number

### 📊 **Wear Tracking & Analytics**
- **Daily Wear Logging**: Mark watches as worn with a single tap
- **Smart Statistics**: Track wear frequency and patterns
- **Past-Only Analytics**: Excludes future dates from calculations for accurate insights
- **Visual Charts**: Beautiful pie charts showing wear distribution

### 📅 **Calendar Integration**
- **Visual Calendar**: See which watches you wore on specific dates
- **Quick Add**: Add wear entries directly from the calendar
- **Historical View**: Browse your wearing patterns over time

### 🔄 **Data Management**
- **Local Storage**: All data stays on your device
- **Backup & Restore**: Export your collection as a `.crownandbarrel` file
- **Sample Data**: Load demo watches for testing (debug builds)

## Screenshots

*Screenshots coming soon - showcasing the beautiful interface across different themes*

## Installation

### For Users
1. Download from the App Store (coming soon)
2. Or build from source using the [Development](#development) instructions below

### For Developers
See the [Development](#development) section for detailed setup instructions.

## Requirements

- **iOS 17.0+** (iPhone only, portrait orientation)
- **Xcode 16+** (for development)
- **macOS** with command line tools (for development)

## Privacy & Data

- **Local-First**: All data is stored locally on your device
- **No Tracking**: No analytics, no data collection, no external services
- **Backup Control**: You control when and how to backup your data
- **Open Source**: Full source code available for transparency

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Quick Start for Contributors
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## Development

### Prerequisites
- Xcode 16+
- macOS with command line tools
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

### Setup
1. **Clone the repository**
   ```bash
   git clone https://github.com/csummers-dev/crownandbarrel-ios.git
   cd crownandbarrel-ios
   ```

2. **Install XcodeGen**
   ```bash
   brew install xcodegen
   ```

3. **Generate the Xcode project**
   ```bash
   xcodegen generate
   ```

4. **Open in Xcode**
   ```bash
   open CrownAndBarrel.xcodeproj
   ```

5. **Run the app**
   - Select iPhone 16 simulator (or newer)
   - Build and run (⌘+R)

### Project Structure
```
Sources/
├── CrownAndBarrelApp/     # App entry point and root navigation
├── DesignSystem/          # Colors, typography, spacing, themes
├── Domain/               # Models, errors, repository protocols
├── Common/               # Shared components and utilities
├── Features/             # Feature UIs (Collection, Stats, Calendar, etc.)
└── Persistence/          # Core Data stack and repositories

Tests/
├── Unit/                # Unit tests
└── UITests/             # UI tests

AppResources/            # Assets, themes, launch screen
```

## Architecture

### **Design Patterns**
- **MVVM + Repository**: Clean separation of concerns
- **SwiftUI + Combine**: Modern reactive UI framework
- **Core Data**: Robust local persistence
- **Design System**: Consistent tokens for colors, typography, and spacing

### **Key Components**
- **Theme System**: JSON-driven themes with system integration
- **Repository Pattern**: Abstracted data access for testability
- **Image Management**: Square-cropped watch photos with fallback placeholders
- **Backup System**: Complete data export/import with replace-only semantics

### **Technical Decisions**
- **iOS 17+**: Modern APIs, full-screen behavior, simplified compatibility
- **iPhone Portrait Only**: Optimized UX, simpler layout constraints
- **Local Storage**: Privacy-first, no external dependencies
- **Replace-Only Backups**: Prevents merge conflicts, deterministic imports

## Testing

### **Test Coverage**
- **Unit Tests**: Domain logic, repositories, theme system, data validation
- **UI Tests**: User flows, theme switching, form validation, navigation
- **Accessibility**: VoiceOver support, Dynamic Type, contrast validation

### **Running Tests**
```bash
# Run all tests
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run specific test target
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelTests
```

### **Test Features**
- **Theme Testing**: Automated theme switching and validation
- **Data Persistence**: Backup/restore functionality testing
- **Form Validation**: Watch creation and editing workflows
- **Accessibility**: Screen reader and contrast compliance

## Troubleshooting

### **Common Issues**

#### **Project Generation**
```bash
# Ensure all required directories exist
mkdir -p Sources Tests/Unit Tests/UITests AppResources

# Clean and regenerate
rm -rf CrownAndBarrel.xcodeproj
xcodegen generate
```

#### **Build Errors**
- Ensure Xcode 16+ is installed
- Clean build folder (⌘+Shift+K)
- Reset simulator if needed

#### **Simulator Issues**
```bash
# List available simulators
xcrun simctl list devices | grep -E "iPhone 1|Booted"

# Reset simulator
xcrun simctl erase "iPhone 16"
```

#### **App Resources**
- Verify `AppResources/` is included in project sources
- Check that `LaunchScreen.storyboard` exists
- Ensure `Info.plist` contains `UILaunchStoryboardName: LaunchScreen`

### **Getting Help**
- Check existing [Issues](https://github.com/csummers-dev/crownandbarrel-ios/issues)
- Create a new issue with detailed reproduction steps
- Include device/simulator information and error logs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Developed with ❤️ by [@csummers-dev](https://github.com/csummers-dev)**

For support or feature requests, contact: [csummersdev@icloud.com](mailto:csummersdev@icloud.com)



