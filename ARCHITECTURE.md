# Architecture Guide

This document outlines the architecture, design patterns, code standards, and technical decisions for Crown & Barrel.

## Table of Contents

- [Design Patterns](#design-patterns)
- [Project Structure](#project-structure)
- [Key Components](#key-components)
- [Technical Decisions](#technical-decisions)
- [Code Standards](#code-standards)
- [Data Flow](#data-flow)
- [Testing Strategy](#testing-strategy)

## Design Patterns

### **MVVM + Repository Pattern**
- **ViewModels**: Handle business logic and state management
- **Views**: Pure SwiftUI views with minimal logic
- **Repositories**: Abstract data access for testability
- **Models**: Domain entities with clear boundaries

### **SwiftUI + Combine**
- **Reactive UI**: SwiftUI views automatically update when state changes
- **Combine Publishers**: Handle asynchronous operations and data flow
- **State Management**: Single source of truth with proper state updates

### **Core Data Integration**
- **Persistence Layer**: Robust local storage with relationships
- **Repository Abstraction**: Clean separation between UI and data layer
- **Migration Support**: Schema evolution capabilities

### **Design System Architecture**
- **Token-Based Design**: Consistent spacing, colors, and typography
- **Theme System**: JSON-driven themes with runtime switching
- **Component Library**: Reusable UI components

### **App Icon System**
- **Multi-Size Support**: All required iOS icon sizes (20@2x through 1024px)
- **Dark Mode Integration**: Automatic light/dark mode switching based on system appearance
- **Enum-Based Management**: `AppIconSize` enum for centralized size definitions
- **Automated Generation**: Script-based icon generation from master 1024x1024 images
- **Future-Ready**: `AppIconManager` class for user-selectable icon themes
- **Validation System**: Comprehensive icon validation and compliance checking

## Project Structure

```
Sources/
├── CrownAndBarrelApp/     # App entry point and root navigation
│   ├── CrownAndBarrelApp.swift    # Main app file
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
│   ├── Calendar/                  # Calendar and wear tracking
│   ├── Stats/                     # Analytics and statistics
│   ├── WatchDetail/               # Individual watch details
│   ├── WatchForm/                 # Watch creation/editing
│   └── Settings/                  # App configuration
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

## Key Components

### **Theme System**
- **JSON-Driven Themes**: Themes defined in `AppResources/Themes.json`
- **Runtime Switching**: Themes can be changed without app restart
- **System Integration**: Automatic dark/light mode detection
- **Token-Based**: Consistent design tokens across all components

### **Repository Pattern**
- **Protocol-Based**: Abstract interfaces for all data operations
- **Testability**: Easy to mock for unit testing
- **Separation of Concerns**: Clean boundary between UI and data layers
- **Multiple Implementations**: Core Data and file-based implementations

### **Image Management**
- **Square Cropping**: Automatic image cropping for consistent display
- **Fallback System**: Placeholder images when photos are missing
- **Local Storage**: Images stored locally with efficient caching
- **Memory Management**: Proper image loading and unloading

### **Backup System**
- **Replace-Only Semantics**: Prevents merge conflicts during restore
- **Complete Export**: All data exported to single `.crownandbarrel` file
- **Validation**: Data integrity checks during import/export
- **User Control**: Manual backup/restore operations only

### **App Icon Management**
- **Size Enumeration**: `AppIconSize` enum defines all required iOS icon dimensions
- **Theme Support**: Light and dark mode variants with automatic system integration
- **Generation Script**: Automated icon generation from master 1024x1024 images
- **Manager Class**: `AppIconManager` provides centralized icon operations and validation
- **Future Extensibility**: Architecture supports user-selectable icon themes
- **Compliance Validation**: Built-in validation for Apple App Store requirements

### **Error Handling Architecture**
- **Centralized Error Types**: `AppError` enum provides consistent error handling across the app
- **Localized Messages**: All errors include user-friendly descriptions
- **Sendable Compliance**: Proper error handling for Swift 6 concurrency requirements
- **Unknown Error Support**: `AppError.unknown` case for unexpected error conditions
- **Error Propagation**: Consistent error throwing patterns in async operations

### **Core Data Concurrency Patterns**
- **Weak Reference Pattern**: All Core Data operations use `[weak self, weak stack]` to prevent retain cycles
- **Sendable Compliance**: Core Data closures properly handle Swift 6 concurrency warnings
- **Guard Pattern**: Consistent guard statements for safe unwrapping in async contexts
- **Return Statement Requirements**: Explicit return statements in closures with return types
- **Error Handling**: Proper error propagation with `AppError.unknown` for unexpected failures

### **Haptic Feedback System**

#### **System Architecture Overview**
The haptic feedback system is a comprehensive, contextually-aware tactile feedback system that provides immediate user confirmation for all interactions across the Crown & Barrel application. The system is built on iOS's `UIFeedbackGenerator` framework and implements sophisticated patterns for different interaction types.

**Core Components**:
- **Haptics Enum**: Central haptic feedback coordinator with contextual methods
- **Supporting Enums**: Type-safe interaction type definitions for different contexts
- **Performance Monitoring**: Debug-only performance tracking and optimization
- **Integration Layer**: Seamless integration with SwiftUI views and user interactions

**Design Principles**:
- **Contextual Awareness**: Different haptic patterns for different interaction contexts
- **Intensity Mapping**: Appropriate haptic intensity based on interaction importance
- **Accessibility First**: Enhanced feedback for users with accessibility needs
- **Performance Optimized**: Minimal overhead with efficient debouncing and caching
- **Type Safety**: Enum-based type safety prevents runtime errors
- **Extensibility**: Modular design allows easy addition of new haptic patterns

#### **System Architecture Components**

**1. Core Haptic Engine** (`Haptics` enum):
- **Basic Haptics**: `lightImpact()`, `mediumImpact()`, `heavyImpact()`, `success()`, `error()`, `warning()`
- **Contextual Haptics**: Specialized methods for different interaction contexts
- **Performance Haptics**: Debouncing and performance optimization methods
- **Accessibility Haptics**: Enhanced feedback for accessibility users

**2. Contextual Pattern System**:
- **Collection Patterns**: `collectionInteraction()`, `searchInteraction()`, `formInteraction()`
- **View-Specific Patterns**: `calendarInteraction()`, `detailViewInteraction()`, `settingsInteraction()`
- **Advanced Patterns**: `statsInteraction()`, `dataInteraction()`, `navigationInteraction()`
- **Accessibility Patterns**: `accessibleInteraction()` with enhanced feedback

**3. Performance Monitoring System**:
- **Basic Monitoring**: `recordHapticCall()` for usage tracking
- **Advanced Monitoring**: `recordAdvancedHapticCall()` with timing analysis
- **Performance Reports**: `getHapticPerformanceReport()` for comprehensive analysis
- **Debug-Only Features**: Performance monitoring only available in debug builds

**4. Integration Architecture**:
- **View Integration**: Seamless integration with SwiftUI views
- **Event Handling**: Proper integration with user interaction events
- **State Management**: Integration with view state and user preferences
- **Error Handling**: Graceful degradation on unsupported devices

#### **Data Flow Architecture**

**Haptic Call Flow**:
1. **User Interaction**: User performs action (tap, swipe, etc.)
2. **Context Resolution**: System determines appropriate haptic context
3. **Pattern Selection**: Contextual haptic pattern is selected
4. **Intensity Mapping**: Appropriate haptic intensity is determined
5. **Performance Check**: Debouncing and performance optimization applied
6. **Haptic Execution**: `UIFeedbackGenerator` executes haptic feedback
7. **Performance Tracking**: Debug-only performance monitoring (if enabled)

**Integration Flow**:
1. **View Event**: SwiftUI view receives user interaction event
2. **Haptic Call**: View calls appropriate haptic method
3. **Context Processing**: Haptic system processes context and intensity
4. **System Integration**: iOS haptic system executes feedback
5. **User Feedback**: User receives immediate tactile confirmation

#### **Performance Architecture**

**Optimization Strategies**:
- **Debouncing**: 100ms debounce interval prevents haptic spam
- **Generator Pooling**: Efficient reuse of haptic generators
- **Context Caching**: Cached contextual pattern resolution
- **Lazy Loading**: Performance data loaded only when needed

**Performance Characteristics**:
- **Latency**: <1ms haptic call overhead
- **Memory**: Minimal memory footprint with efficient patterns
- **Battery**: Optimized for minimal battery impact
- **Threading**: All haptic calls properly dispatched to main thread

#### **Accessibility Architecture**

**Enhanced Accessibility Support**:
- **Screen Reader Integration**: Enhanced feedback for VoiceOver users
- **Intensity Customization**: Adjustable haptic intensity for accessibility needs
- **Context Awareness**: Accessibility-aware haptic pattern selection
- **WCAG Compliance**: WCAG 2.1 AA compliant accessibility patterns

**Accessibility Features**:
- **Enhanced Feedback**: More pronounced haptic feedback for accessibility users
- **Customizable Intensity**: User-adjustable haptic intensity
- **Context Sensitivity**: Accessibility-aware contextual pattern selection
- **Compliance Validation**: Built-in accessibility compliance checking

#### **Integration Architecture**

**View Integration Patterns**:
- **Direct Integration**: Direct haptic method calls in view event handlers
- **Contextual Integration**: Context-aware haptic pattern selection
- **Performance Integration**: Performance-optimized haptic execution
- **Accessibility Integration**: Accessibility-aware haptic feedback

**System Integration**:
- **iOS Integration**: Native integration with iOS haptic system
- **SwiftUI Integration**: Seamless integration with SwiftUI framework
- **Combine Integration**: Integration with reactive programming patterns
- **Core Data Integration**: Integration with data persistence layer

#### **Error Handling Architecture**

**Graceful Degradation**:
- **Device Support**: Automatic fallback for unsupported devices
- **System Errors**: Graceful handling of system-level errors
- **Performance Errors**: Fallback patterns for performance issues
- **Accessibility Errors**: Fallback patterns for accessibility issues

**Error Recovery**:
- **Automatic Recovery**: Automatic recovery from transient errors
- **User Notification**: Appropriate user notification for persistent errors
- **Logging**: Comprehensive error logging for debugging
- **Monitoring**: Error monitoring and alerting systems

#### **Phase 1 Implementation (Completed)**
- **Collection View Interactions**: 5 haptic touch points (card selection, grid/list toggle, sort changes, search activation, pull-to-refresh)
- **Watch Form Interactions**: 15+ haptic touch points (text fields, pickers, toggles, date pickers, save/validation, image selection)
- **Debounced Haptics**: 100ms debounce interval prevents haptic spam from rapid interactions
- **Accessibility Enhancements**: Enhanced feedback patterns for screen reader users with `AccessibilityInteractionType` enum
- **Comprehensive Testing**: 90%+ test coverage with unit tests and UI integration tests
- **Performance Optimized**: <1ms overhead per haptic call with efficient debouncing

#### **Phase 2 Implementation (Completed)**
- **Calendar View Interactions**: 3 haptic touch points (date selection, wear entry addition, navigation feedback)
- **Watch Detail View Interactions**: 4 haptic touch points (mark as worn, edit initiation, image tap, refresh completion)
- **Settings View Interactions**: 2 haptic touch points (theme selection, view appearance)
- **Enhanced Contextual Haptics**: New specialized haptic patterns with `CalendarInteractionType` and `DetailViewInteractionType` enums
- **Performance Monitoring**: Debug-only performance tracking for haptic usage and impact
- **Comprehensive Testing**: 95%+ test coverage with extended unit and UI integration tests
- **Total App Coverage**: 45+ haptic touch points across all major user interactions

#### **Phase 3 Implementation (Completed)**
- **Stats View Interactions**: 8 haptic touch points (data point taps, chart interactions, list headers, watch list items, refresh completion)
- **App Data View Interactions**: 4 haptic touch points (export, import, delete, seed sample data operations)
- **Navigation Interactions**: 2 haptic touch points (menu opening, menu item selection)
- **Advanced Contextual Haptics**: New specialized haptic patterns with `StatsInteractionType`, `DataInteractionType`, and `NavigationInteractionType` enums
- **Advanced Performance Monitoring**: Enhanced performance tracking with detailed metrics and timing analysis
- **Comprehensive Testing**: 98%+ test coverage with extensive unit and UI integration tests
- **Complete App Coverage**: 70+ haptic touch points across the entire application

#### **Phase 4 Implementation (Completed)**
- **Comprehensive Architecture Documentation**: Complete system architecture documentation with detailed technical implementation details
- **System Architecture Diagrams**: Visual system architecture documentation with data flow and component interaction diagrams
- **Development Standards**: Comprehensive development standards and guidelines for haptic system development
- **Maintenance Guidelines**: Complete maintenance and evolution documentation with procedures and best practices
- **Evolution Roadmap**: Long-term evolution roadmap with future development phases and technology considerations
- **Quality Assurance Standards**: Comprehensive QA standards and testing requirements
- **Performance Analysis**: Detailed performance analysis and optimization recommendations
- **Complete Documentation Set**: Comprehensive documentation covering all aspects of the haptic system

#### **Haptic Integration Patterns**
- **Collection View**: Uses `Haptics.collectionInteraction()` for card taps and `Haptics.searchInteraction(.filterChange)` for sort changes
- **Form Interactions**: Uses `Haptics.formInteraction()` for field focus and `Haptics.successNotification()` for successful saves
- **Validation Feedback**: Uses `Haptics.error()` for validation failures and `Haptics.success()` for successful validation
- **Calendar Interactions**: Uses `Haptics.calendarInteraction(.dateSelection)` for date selection and `Haptics.calendarInteraction(.wearEntryAdded)` for wear entry addition
- **Detail View Interactions**: Uses `Haptics.detailViewInteraction(.wearMarked)` for marking as worn and `Haptics.detailViewInteraction(.editInitiated)` for edit initiation
- **Settings Interactions**: Uses `Haptics.settingsInteraction(.themeChange)` for theme selection and `Haptics.lightImpact()` for view appearance
- **Stats Interactions**: Uses `Haptics.statsInteraction(.dataPointTapped)` for data point taps and `Haptics.statsInteraction(.chartTapped)` for chart interactions
- **Data Management Interactions**: Uses `Haptics.dataInteraction(.exportInitiated)` for export operations and `Haptics.dataInteraction(.deleteInitiated)` for delete operations
- **Navigation Interactions**: Uses `Haptics.navigationInteraction(.menuOpened)` for menu opening and `Haptics.navigationInteraction(.menuItemSelected)` for menu item selection
- **Debouncing**: All rapid interactions use `Haptics.debouncedHaptic()` to prevent overwhelming feedback
- **Accessibility**: Enhanced feedback uses `Haptics.accessibleInteraction()` for better accessibility compliance
- **Performance Monitoring**: Debug builds use `Haptics.recordHapticCall()` and `Haptics.recordAdvancedHapticCall()` for comprehensive performance tracking

## Build System & Compiler Compliance

### **Swift Compilation Standards**
- **Swift 6 Concurrency**: All code must be compatible with Swift 6 concurrency model
- **Sendable Compliance**: Proper handling of `@Sendable` closure requirements
- **Weak Reference Patterns**: Mandatory use of weak references in Core Data operations
- **Error Handling**: Consistent error propagation with `AppError` enum
- **Return Statement Requirements**: Explicit return statements in closures with return types

### **Critical Compilation Patterns**
- **Core Data Operations**: Always use `[weak self, weak stack]` pattern
- **Guard Statements**: Consistent guard patterns for safe unwrapping
- **Static Member Access**: Explicit type qualification for static members
- **Variable Declaration**: Use `let` for immutable variables
- **Notification Handling**: Avoid invalid notification names

### **Asset Management Standards**
- **App Icon Compliance**: All icons must be properly referenced in `Contents.json`
- **File Cleanup**: Remove system files (`.DS_Store`) and unused assets
- **Dark Mode Support**: Proper light/dark mode icon variants (except marketing icons)
- **Generation Scripts**: Use automated scripts for asset generation

## Technical Decisions

### **iOS 17+ Requirement**
- **Modern APIs**: Access to latest SwiftUI and iOS features
- **Full-Screen Behavior**: Proper status bar and navigation handling
- **Simplified Compatibility**: No need to support older iOS versions
- **Performance**: Better performance on supported devices

### **iPhone Portrait Only**
- **Optimized UX**: Single orientation allows for better user experience
- **Simpler Layout**: Reduced layout complexity and constraints
- **Design Focus**: Can optimize specifically for portrait orientation
- **Maintenance**: Less code to maintain for different orientations

### **Local Storage Only**
- **Privacy-First**: No external dependencies or data transmission
- **Performance**: Faster access to local data
- **Reliability**: No network dependencies
- **User Control**: Complete control over data location

### **Replace-Only Backups**
- **Deterministic**: Predictable behavior during restore operations
- **Conflict Prevention**: No merge conflicts or data inconsistencies
- **Simplicity**: Easier to implement and test
- **User Understanding**: Clear behavior for users

## Code Standards

### **Swift Style Guidelines**
- **SwiftLint**: Automated code style enforcement
- **Naming Conventions**: Clear, descriptive names for all entities
- **Documentation**: Comprehensive code comments and documentation
- **Error Handling**: Proper error handling with custom error types

### **SwiftUI Best Practices**
- **View Composition**: Break down complex views into smaller components
- **State Management**: Proper use of `@State`, `@ObservedObject`, `@StateObject`
- **Performance**: Efficient view updates and minimal re-renders
- **Accessibility**: VoiceOver support and Dynamic Type compatibility

### **Architecture Patterns**
- **Single Responsibility**: Each class/struct has one clear purpose
- **Dependency Injection**: Testable code with injected dependencies
- **Protocol-Oriented**: Use protocols for abstractions
- **Immutable Models**: Value types where appropriate

### **Testing Standards**
- **Unit Tests**: Test business logic and data operations
- **UI Tests**: Test user flows and interactions
- **Test Coverage**: Aim for high test coverage on critical paths
- **Mock Objects**: Use mocks for external dependencies

## Data Flow

### **User Interaction Flow**
1. **User Action** → SwiftUI View
2. **View** → ViewModel (via bindings)
3. **ViewModel** → Repository (for data operations)
4. **Repository** → Core Data Stack
5. **Data Change** → Repository publishes update
6. **ViewModel** → Updates published state
7. **View** → Automatically updates via SwiftUI

### **Theme Application Flow**
1. **Theme Selection** → ThemeManager
2. **ThemeManager** → Updates global theme state
3. **Theme State** → Propagates to all views
4. **Views** → Apply theme tokens automatically
5. **System Integration** → Respects system appearance settings

### **Data Persistence Flow**
1. **User Action** → ViewModel
2. **ViewModel** → Repository protocol
3. **Repository** → Core Data implementation
4. **Core Data** → Persistent store
5. **Change Notification** → Repository
6. **Repository** → ViewModel update
7. **ViewModel** → View update

## Testing Strategy

### **Unit Testing**
- **Domain Logic**: Test business rules and data validation
- **Repository Layer**: Test data operations with in-memory stores
- **Utilities**: Test helper functions and utilities
- **Theme System**: Test theme switching and token application

### **UI Testing**
- **User Flows**: Test complete user journeys
- **Theme Switching**: Verify theme changes work correctly
- **Form Validation**: Test input validation and error handling
- **Navigation**: Test navigation between screens

### **Integration Testing**
- **Core Data**: Test with real Core Data stack
- **Backup/Restore**: Test complete backup and restore flows
- **Image Handling**: Test image loading and display
- **Performance**: Test app performance under load

### **Accessibility Testing**
- **VoiceOver**: Test screen reader compatibility
- **Dynamic Type**: Test text scaling
- **Contrast**: Verify color contrast ratios
- **Navigation**: Test accessibility navigation

---

*This architecture guide is maintained by the Crown & Barrel development team. For questions or suggestions about the architecture, please create an issue or contact the development team.*
