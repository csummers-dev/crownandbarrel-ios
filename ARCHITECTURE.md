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

## **CI/CD Pipeline Architecture**

### **GitHub Actions Workflows**

The project uses GitHub Actions for continuous integration and deployment with the following workflow structure:

#### **Main CI Pipeline** (`.github/workflows/ci.yml`)
- **Setup Stage**: Install dependencies and generate Xcode project
- **Lint Stage**: Run SwiftLint for code quality
- **Build Stage**: Compile for Debug and Release configurations
- **Test Stage**: Run unit tests and UI tests in parallel
- **Archive Stage**: Create distribution archives
- **Cleanup Stage**: Clean up simulator and temporary files

#### **Release Pipeline** (`.github/workflows/release.yml`)
- **TestFlight Deployment**: Automated TestFlight upload preparation
- **App Store Deployment**: App Store submission preparation
- **GitHub Releases**: Automatic release creation for tags

#### **Validation Pipeline** (`.github/workflows/validate.yml`)
- **YAML Validation**: Configuration file validation
- **Swift Syntax**: Basic syntax checking
- **Security Scanning**: Trivy vulnerability scanner
- **Code Quality**: SwiftLint integration
- **Performance Monitoring**: Build time tracking

#### **Security Pipeline** (`.github/workflows/security.yml`)
- **CodeQL Analysis**: GitHub's advanced code analysis
- **Dependency Scanning**: Comprehensive vulnerability assessment
- **Secret Detection**: TruffleHog integration
- **License Compliance**: Dependency license checking

#### **Dependency Update Pipeline** (`.github/workflows/dependency-update.yml`)
- **Automated Updates**: Weekly dependency updates
- **Security Patches**: Security vulnerability updates
- **Version Management**: Automated version bumping

### **Validation System**

#### **Pre-commit Hooks**
- **GitHub Actions Validation**: Validates workflow files before commit
- **Swift Syntax Checking**: Validates Swift files
- **YAML Validation**: Validates configuration files

#### **Pre-push Hooks**
- **Additional Validation**: Extra validation before pushing
- **Build Checks**: Basic build validation (if Xcode available)

#### **Validation Scripts**
- **`scripts/validate-github-actions.sh`**: Comprehensive workflow validation
- **`scripts/setup-github-hooks.sh`**: Git hooks setup

### **Quality Gates**

#### **Required for Success**
- ✅ All tests must pass
- ✅ SwiftLint must pass (warnings allowed)
- ✅ Security scans must pass
- ✅ Build must complete successfully
- ✅ Archive creation must succeed

#### **Security Requirements**
- ✅ All actions pinned to specific versions
- ✅ Secrets properly managed via GitHub Secrets
- ✅ No hardcoded sensitive values
- ✅ Proper permissions configuration

## **Achievements System Architecture**

### **System Overview**

The achievements system is a comprehensive gamification feature that recognizes and celebrates user milestones in their watch collecting and wearing journey. The system provides real-time achievement unlocking, progress tracking, and visual feedback across the app.

**Core Components**:
- **Domain Models**: Achievement definitions and user state tracking
- **Persistence Layer**: GRDB-based storage with efficient indexing
- **Evaluation Engine**: Real-time criteria evaluation and progress calculation
- **UI Components**: Reusable SwiftUI components for display and interaction
- **Integration Points**: Embedded in StatsView, WatchV2DetailView, and CalendarView

**Design Principles**:
- **Real-Time Evaluation**: Achievements unlock immediately when criteria are met
- **Local-First**: All data stored locally with no cloud sync
- **Permanent Unlocks**: Achievements remain unlocked even if contributing data is deleted
- **Extensible**: Easy to add new achievements in future updates
- **Performance Optimized**: Efficient queries and batch processing

### **Domain Model Architecture**

#### **Achievement Model**
- **Purpose**: Defines a single achievement with its criteria and metadata
- **Properties**: id, name, description, imageAssetName, category, unlockCriteria, targetValue
- **Immutability**: Achievement definitions are constant (hardcoded in AchievementDefinitions)
- **Categories**: Five categories with 10 achievements each (total: 50)
  - Collection Size: Milestones for collection growth
  - Wearing Frequency: Recognition for logging wears
  - Consistency: Rewards for maintaining streaks
  - Diversity: Celebrate variety in collection and rotation
  - Special Occasions: Commemorate firsts and milestones

#### **AchievementState Model**
- **Purpose**: Tracks user's progress and unlock status for each achievement
- **Properties**: id, achievementId, isUnlocked, unlockedAt, currentProgress, progressTarget, createdAt, updatedAt
- **Mutability**: State updates as user interacts with the app
- **GRDB Integration**: Conforms to FetchableRecord and PersistableRecord
- **Progress Tracking**: Stores current progress separately from unlock status

#### **AchievementCriteria Enum**
- **Purpose**: Type-safe definition of achievement unlock conditions
- **18 Criteria Types**: Covers all achievement evaluation scenarios
- **Associated Values**: Parameterized criteria (e.g., watchCountReached(count: 10))
- **Codable**: Custom Codable implementation for database persistence
- **Display Helpers**: Human-readable descriptions and target value extraction

### **Data Persistence Architecture**

#### **Database Schema**

**achievements Table** (Optional - definitions are hardcoded):
- Columns: id, name, description, image_asset_name, category, criteria_json, target_value, created_at
- Purpose: Could store definitions, but currently definitions come from AchievementDefinitions.swift

**user_achievement_state Table**:
- Columns: id, achievement_id (FK), is_unlocked, unlocked_at, current_progress, progress_target, created_at, updated_at
- Indexes: is_unlocked, achievement_id, composite (is_unlocked, unlocked_at)
- Purpose: Tracks user progress for all 50 achievements

**wearEntries Table** (Added for achievements):
- Columns: id, watchId (FK), date
- Indexes: date, composite (watchId, date)
- Purpose: Tracks when watches are worn for frequency and streak achievements

#### **Repository Pattern**

**AchievementRepository Protocol**:
- Definition queries: fetchAllDefinitions(), fetchByCategory(), fetchDefinition(id:)
- State management: fetchUserState(), updateUserState(), updateUserStates() (batch)
- Filtered queries: fetchUnlocked(), fetchLocked()
- Combined queries: fetchAchievementsWithStates(), fetchUnlockedWithDefinitions()
- Utilities: initializeUserStates(), deleteAllUserStates()

**WatchRepositoryV2 Extensions**:
- Achievement-related queries added for evaluation:
  - totalWatchCount(), totalWearCount(), wearCountForWatch(watchId:)
  - uniqueBrandsCount(), currentStreak(), allWearEntries()
  - uniqueDaysWithEntries(), firstWearDate(), firstWatchDate()

### **Evaluation Engine Architecture**

#### **AchievementEvaluator Service**

**Core Responsibilities**:
- Evaluate achievement criteria against current user data
- Update achievement state with progress and unlock status
- Trigger evaluations based on user actions

**Evaluation Methods**:
- `evaluateAll()`: Checks all locked achievements (batch processing)
- `evaluateAchievement(_:)`: Evaluates single achievement
- `evaluateCriteria(_:)`: Private method dispatching to specific criteria evaluators

**Event-Triggered Evaluation**:
- `evaluateOnWatchAdded()`: Triggered when watch is added (collection, diversity achievements)
- `evaluateOnWearLogged(watchId:date:)`: Triggered when wear is logged (frequency, consistency achievements)
- `evaluateOnDataDeleted()`: Recalculates progress when data removed (unlocked achievements stay unlocked)
- `evaluateExistingUserData()`: Migration helper for first launch and app updates

**Criteria Evaluation**:
- Collection Size: Compares watch count to target
- Wearing Frequency: Compares total or single-watch wear counts
- Consistency: Uses StreakCalculator for consecutive day/weekend/weekday streaks
- Diversity: Evaluates unique brands, rotation patterns, balanced distribution
- Special Occasions: Checks first-time events and tracking milestones

#### **StreakCalculator Service**

**Purpose**: Calculates various types of wearing streaks

**Streak Logic (Per PRD)**:
- Multiple watches worn on the same day count as ONE day toward the streak
- Streak counts consecutive days from today backwards
- Weekend/weekday streaks skip non-relevant days

**Methods**:
- `calculateCurrentStreak(wearEntries:)`: Consecutive days from today
- `calculateConsecutiveWeekends(from:)`: Consecutive weekends with at least one entry
- `calculateConsecutiveWeekdays(from:)`: Consecutive weekdays (skips weekends)

### **UI Component Architecture**

#### **AchievementCard Component**
- **Purpose**: Displays individual achievement with lock/unlock state
- **States**: Locked (grayed 40% opacity, progress bar) vs Unlocked (full color, unlock date)
- **Size**: 80x80 circular image, card layout with padding
- **Accessibility**: Full VoiceOver support with descriptive labels
- **Theme**: Respects themeToken for automatic updates

#### **AchievementProgressView Component**
- **Purpose**: Shows progress toward unlocking
- **Modes**: Compact (4px bar for cards) vs Full (labeled bar with percentage)
- **Animation**: Smooth 0.3s ease-in-out on progress changes
- **Display**: Progress bar + fractional text (e.g., "8/10")

#### **AchievementGridView Component**
- **Purpose**: Grid layout for multiple achievements
- **Layout**: LazyVGrid with adaptive columns (150-200px)
- **Filtering**: Category chips + show only unlocked toggle
- **Sorting**: Unlocked first, then by progress, then alphabetically
- **Empty State**: Helpful message when no achievements match filters

#### **AchievementUnlockNotification Component**
- **Purpose**: Celebrates achievement unlocks
- **Animation**: Slide in from top with spring physics
- **Haptics**: Success haptic (UINotificationFeedbackGenerator .success)
- **Auto-Dismiss**: 3 seconds or swipe/tap to dismiss
- **Z-Index**: 999 to ensure visibility over other content

### **Integration Architecture**

#### **StatsView Integration**
- Achievements section after stats cards
- Horizontal scroll of achievement cards
- Toggle for showing/hiding locked achievements (@AppStorage persisted)
- Loads all achievements with states on view appear
- Initializes achievement states on first launch

#### **WatchV2DetailView Integration**
- Collapsible Achievements section
- Shows watch-specific unlocked achievements
- Filters for single-watch wear count achievements
- Loads asynchronously with Task

#### **CalendarView Integration**
- Evaluator in WatchPicker sheet
- Calls `evaluateOnWearLogged()` after incrementWear
- Displays unlock notification for newly unlocked achievements
- Haptic feedback via notification component

#### **App Launch Integration**
- Achievement evaluation in CrownAndBarrelApp.init()
- Calls `evaluateExistingUserData()` on every launch
- Auto-unlocks achievements for existing user data
- Handles new achievements in app updates

### **Data Flow Architecture**

#### **Achievement Unlock Flow**
1. **User Action** → Add watch or log wear entry
2. **Repository** → Persists watch or wear entry to database
3. **Evaluator Trigger** → `evaluateOnWatchAdded()` or `evaluateOnWearLogged()`
4. **Criteria Evaluation** → Query current user data and compare to criteria
5. **State Update** → Update currentProgress, unlock if criteria met
6. **Persistence** → Save updated state to database
7. **UI Notification** → Display unlock notification with haptic feedback
8. **View Refresh** → Stats/Detail views update on next load

#### **Progress Tracking Flow**
1. **User Data Changes** → Watches added, wears logged, data deleted
2. **Evaluator** → Recalculates progress for relevant achievements
3. **Repository** → Updates achievement state progress values
4. **UI Display** → Progress bars update in achievement cards
5. **Unlock Check** → If progress >= target, unlock achievement

#### **First Launch Flow**
1. **App Launch** → CrownAndBarrelApp.init() runs
2. **Initialization** → `evaluateExistingUserData()` called
3. **State Creation** → `initializeUserStates()` creates states for all 50 achievements
4. **Batch Evaluation** → `evaluateAll()` checks all achievements
5. **Auto-Unlock** → Unlocks achievements user already qualifies for
6. **Silent Completion** → No UI interruption, achievements available in StatsView

### **Performance Characteristics**

**Evaluation Performance**:
- Achievement evaluation completes in <100ms for 95% of actions (per PRD)
- Batch processing for efficient state updates
- Indexed queries for fast filtering
- Category-based evaluation to reduce unnecessary checks

**Database Performance**:
- Composite indexes for efficient locked/unlocked filtering
- Foreign key constraints with cascade delete
- WAL mode for concurrent access
- Minimal joins (progress_target duplicated in state table)

**Memory Efficiency**:
- Achievement definitions loaded from constants (no database reads)
- User states loaded on-demand
- UI components use lazy loading (LazyVGrid)
- Batch updates to minimize database transactions

### **Extension Points**

#### **Adding New Achievements**
1. Add achievement definition to AchievementDefinitions.swift
2. Add new criteria case to AchievementCriteria enum if needed
3. Implement evaluation logic in AchievementEvaluator
4. Add achievement image asset
5. On app launch, `evaluateExistingUserData()` auto-unlocks for qualifying users

#### **New Achievement Categories**
1. Add case to AchievementCategory enum
2. Update display helpers (displayName, iconName, categoryDescription)
3. Create achievement definitions in new category
4. Add category to filtering UI

#### **Custom Criteria Types**
1. Add case to AchievementCriteria enum with associated values
2. Implement Codable encoding/decoding
3. Add evaluation method to AchievementEvaluator
4. Add unit tests for new criteria type

### **Testing Strategy**

**Unit Tests** (86 test methods):
- Model validation and Codable support
- Evaluation engine with in-memory database
- Streak calculation with PRD edge cases
- Repository persistence and filtering
- Data integrity validation

**UI Tests** (11 test methods):
- Achievement display in StatsView
- Toggle behavior and persistence
- Watch detail page integration
- Accessibility verification
- Theme integration

**Manual Testing Checklist**:
- Add watches → verify collection achievements unlock
- Log wears → verify wearing frequency achievements unlock
- Log consecutive days → verify streak achievements unlock
- Toggle locked achievements → verify filtering works
- View watch detail → verify watch-specific achievements appear
- Achievement unlock → verify notification and haptic feedback

### **Known Limitations and Future Enhancements**

**Current Limitations**:
- Watch-specific achievement association not fully implemented (fetchAchievementsForWatch returns empty)
- No "recently unlocked" section (per PRD non-goals)
- No social features or achievement sharing
- No time-limited or seasonal achievements
- Achievement images use placeholder fallback (SF Symbol "trophy.fill")

**Future Enhancements**:
- Enhanced watch-specific achievement tracking with database association
- Achievement analytics (most common, rarest achievements)
- Achievement progress notifications (e.g., "50% to next achievement")
- Enhanced unlock celebrations with animations
- Achievement categories in separate views

---

*This architecture guide is maintained by the Crown & Barrel development team. For questions or suggestions about the architecture, please create an issue or contact the development team.*
