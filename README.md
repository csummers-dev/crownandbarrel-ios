# Crown & Barrel

[![Build/Test CI](https://github.com/csummers-dev/crownandbarrel-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/csummers-dev/crownandbarrel-ios/actions/workflows/ci.yml)
![SwiftLint](https://img.shields.io/badge/lint-SwiftLint-FA7343?logo=swift)
![Beta Status](https://img.shields.io/badge/status-Beta%20Testing-orange?logo=testflight)
![iOS](https://img.shields.io/badge/iOS-26.0+-blue?logo=ios)

Crown & Barrel is a sophisticated digital watch collection management application for iOS. Built with SwiftUI and designed for watch enthusiasts and collectors, it combines elegant aesthetics with powerful functionality to organize, track, and analyze your timepiece collection.

## Beta Testing Phase

**Crown & Barrel is currently in active beta testing through TestFlight.** The app features comprehensive watch collection management with sophisticated theming, haptic feedback, and luxury typography systems.

### Beta Status
- **Internal Testing**: Active and ongoing
- **External Testing**: Available for invited testers
- **TestFlight**: Fully deployed and functional
- **Target**: Public App Store release following successful beta validation

## Features

### Watch Collection Management
- **Comprehensive watch details** including manufacturer, model, serial numbers, and high-quality photos
- **Advanced metadata** with purchase dates, warranty information, service records, and valuation tracking
- **Intelligent search** across manufacturers, models, and reference numbers
- **Favorites system** for quick access to most-worn timepieces
- **Flexible viewing modes** with grid and list layouts

### Wear Tracking & Analytics
- **Daily wear logging** with single-tap convenience
- **Statistical analysis** of wear patterns and frequency
- **Historical accuracy** with past-only analytics excluding future dates
- **Visual insights** through interactive charts and data visualization
- **Trend analysis** to understand collection usage patterns

### Luxury Design System
- **Eight curated luxury themes** including Champagne Gold, Royal Sapphire, and Emerald Heritage
- **Sophisticated typography** with selective serif fonts for premium brand identity
- **iOS 26.0 compliance** featuring Liquid Glass design elements
- **Immediate theme updates** with real-time color synchronization across all interface elements
- **Professional color theory** applied to ensure optimal contrast and visual harmony

### Haptic Feedback System
- **Contextual haptic feedback** across navigation, collection interactions, and form submissions
- **Debounced implementation** preventing overwhelming feedback during rapid interactions
- **Accessibility integration** supporting users who rely on tactile feedback
- **Professional-grade implementation** with comprehensive testing coverage

### Calendar Integration
- **Visual calendar interface** displaying wear history with intuitive date-based navigation
- **Quick wear entry** directly from calendar dates
- **Historical browsing** to explore past wearing patterns
- **Date-based insights** for understanding seasonal preferences

### Data Management
- **Local-first architecture** ensuring complete data privacy and control
- **Backup and restore** functionality with `.crownandbarrel` archive format
- **Core Data persistence** with optimized performance and reliability
- **Sample data generation** for development and testing purposes

## Architecture

### Technical Foundation
- **SwiftUI** with modern iOS development patterns
- **Core Data** for robust local data persistence
- **MVVM architecture** with clean separation of concerns
- **Comprehensive testing** including UI tests, unit tests, and integration tests
- **Modular design system** with reusable components and tokens

### Design System
- **Centralized theming** with semantic color tokens and consistent spacing
- **Typography hierarchy** optimized for luxury brand identity
- **Component library** ensuring visual consistency across all screens
- **Accessibility compliance** with dynamic type and VoiceOver support

### Quality Assurance
- **Continuous integration** with automated testing and code quality checks
- **SwiftLint integration** maintaining consistent code standards
- **Comprehensive test suite** covering haptics, themes, and core functionality
- **Performance monitoring** ensuring optimal user experience

## Requirements

- **iOS 17.0 or later**
- **iPhone** (portrait orientation)
- **Xcode 16.0 or later** (for development)
- **macOS** with command line tools (for development)

## Installation

### For Users
Crown & Barrel will be available on the App Store. For early access, build from source using the development guide.

### For Developers
1. Clone the repository
2. Open `CrownAndBarrel.xcodeproj` in Xcode
3. Build and run on iOS Simulator or device
4. Refer to [DEVELOPMENT.md](DEVELOPMENT.md) for detailed setup instructions

## Privacy & Security

Crown & Barrel prioritizes user privacy and data security:

- **Local-only storage** with no external data transmission
- **No analytics or tracking** of any kind
- **User-controlled backups** with complete data ownership
- **Open source transparency** allowing full code inspection
- **No network dependencies** for core functionality

## Documentation

### Core Documentation
- **[Development Guide](DEVELOPMENT.md)** - Setup, build, and testing procedures
- **[Architecture Guide](ARCHITECTURE.md)** - Technical design patterns and decisions
- **[Contributing Guidelines](CONTRIBUTING.md)** - Contribution standards and processes
- **[Testing Guide](TESTING.md)** - Testing strategies and best practices

### Feature Documentation
- **[Haptic System](docs/haptics/README.md)** - Comprehensive haptic feedback documentation
- **[Theme System](docs/themes/README.md)** - Theme implementation and customization guide
- **[Typography Guide](docs/LUXURY_TYPOGRAPHY_GUIDE.md)** - Typography system documentation

### Deployment Documentation
- **[TestFlight Setup](docs/deployment/README.md)** - Complete deployment guide
- **[App Store Content](docs/deployment/APP_STORE_CONTENT.md)** - Marketing and listing content

### Infrastructure Documentation
- **[CI/CD Pipeline](docs/CI_CD_TROUBLESHOOTING.md)** - Continuous integration and deployment
- **[Pipeline Maintenance](docs/PIPELINE_MAINTENANCE_GUIDE.md)** - Infrastructure maintenance guide

### Complete Documentation Index
- **[Documentation Hub](docs/README.md)** - Complete documentation overview and navigation

## Contributing

Crown & Barrel welcomes contributions from the community. Please review our [Contributing Guidelines](CONTRIBUTING.md) for information on code standards, testing requirements, and submission processes.

### Development Standards
- **SwiftLint compliance** for consistent code quality
- **Comprehensive testing** for all new features
- **Documentation requirements** for public APIs and complex functionality
- **Performance considerations** for optimal user experience

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for complete details.

## Contact

**Developer**: [@csummersdev](https://github.com/csummers-dev)
**Email**: [csummersdev@icloud.com](mailto:csummersdev@icloud.com)

Crown & Barrel is developed with dedication to excellence in both code quality and user experience, reflecting the precision and craftsmanship valued by luxury timepiece enthusiasts.