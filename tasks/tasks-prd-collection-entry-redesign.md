# Task List: Collection Entry View Redesign

## Relevant Files

- `Sources/PersistenceV2/Repositories.swift` - Extended WatchRepositoryV2 protocol and WatchRepositoryGRDB implementation with lastWornDate method
- `Sources/Common/Utilities/DateFormatters.swift` - Centralized date formatting utilities for relative and absolute date displays
- `Sources/Common/Utilities/WatchFieldFormatters.swift` - Field formatting and visibility logic utilities
- `Sources/Common/Components/DetailSectionHeader.swift` - Reusable section header component for detail views
- `Sources/Common/Components/StatisticRow.swift` - Component for displaying key statistics (times worn, last worn)
- `Sources/Common/Components/AchievementBadge.swift` - Compact achievement badge for horizontal display
- `Sources/Common/Components/SpecificationRow.swift` - Component for displaying key-value specification pairs
- `Sources/Features/WatchV2Detail/WatchV2DetailView.swift` - Completely redesigned detail view (modified)
- `Tests/Unit/DateFormattersTests.swift` - Unit tests for date formatting utilities
- `Tests/Unit/WatchFieldFormattersTests.swift` - Unit tests for field visibility and formatting logic
- `Tests/Unit/WatchRepositoryGRDBTests.swift` - Tests for new repository methods (modified)

## Tasks

- [ ] 1.0 Extend Repository with Missing Data Methods
  - [x] 1.1 Add `lastWornDate(watchId:)` method to WatchRepositoryV2 protocol
  - [x] 1.2 Implement `lastWornDate(watchId:)` in WatchRepositoryGRDB to query most recent WearEntry
  - [x] 1.3 Verify existing `wearCountForWatch(watchId:)` method works correctly
  - [x] 1.4 Test new repository method with unit tests

- [ ] 2.0 Create Reusable UI Components for Detail View
  - [ ] 2.1 Create `DetailSectionHeader.swift` component with luxury typography styling
  - [ ] 2.2 Create `StatisticRow.swift` component for displaying statistics (times worn, last worn)
  - [ ] 2.3 Create `AchievementBadge.swift` compact component for horizontal achievement display
  - [ ] 2.4 Create `SpecificationRow.swift` component for key-value pairs with smart visibility
  - [ ] 2.5 Create tag pill component for displaying tags as chips

- [ ] 3.0 Implement Field Visibility and Formatting Utilities
  - [ ] 3.1 Create `DateFormatters.swift` with relative/absolute date formatting logic
  - [ ] 3.2 Create `WatchFieldFormatters.swift` with field visibility helpers for all watch properties
  - [ ] 3.3 Add currency formatting utilities for purchase prices and valuations
  - [ ] 3.4 Add numeric precision formatting for measurements (diameter, thickness, etc.)
  - [ ] 3.5 Create helper methods to determine if specification groups have any populated fields

- [ ] 4.0 Redesign WatchV2DetailView with New Layout
  - [ ] 4.1 Replace CollapsibleSection components with new ScrollView-based layout
  - [ ] 4.2 Implement photo gallery carousel at the top using TabView with page indicators
  - [ ] 4.3 Create watch identity section with manufacturer, model, line, reference, nickname
  - [ ] 4.4 Add statistics section displaying times worn, last worn, and achievement progress
  - [ ] 4.5 Implement core details group with smart field visibility
  - [ ] 4.6 Implement case specifications group with section header and smart visibility
  - [ ] 4.7 Implement dial details group with smart visibility
  - [ ] 4.8 Implement crystal details group with smart visibility
  - [ ] 4.9 Implement movement specifications group with smart visibility
  - [ ] 4.10 Implement water resistance group with smart visibility
  - [ ] 4.11 Implement strap/bracelet details group with smart visibility
  - [ ] 4.12 Implement ownership information group with smart visibility
  - [ ] 4.13 Add service history display if entries exist
  - [ ] 4.14 Add valuations display if entries exist
  - [ ] 4.15 Add strap inventory display if items exist
  - [ ] 4.16 Implement achievements horizontal row at bottom with wrapping
  - [ ] 4.17 Apply consistent spacing using AppSpacing tokens throughout
  - [ ] 4.18 Apply luxury typography using AppTypography styles

- [ ] 5.0 Add Unit Tests for New Components and Logic
  - [ ] 5.1 Write unit tests for DateFormatters utility
  - [ ] 5.2 Write unit tests for WatchFieldFormatters visibility logic
  - [ ] 5.3 Write unit tests for currency and numeric formatting
  - [ ] 5.4 Add repository tests for lastWornDate method
  - [ ] 5.5 Create UI tests or preview tests for new components
