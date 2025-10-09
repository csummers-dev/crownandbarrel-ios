# Task List: Collection Entry Visual Redesign

## Relevant Files

- `Sources/Features/WatchV2List/WatchV2ListView.swift` - Main collection view containing both grid and list view implementations; uses `WatchGridCard` and `WatchListRow` components from WatchEntryComponents
- `Sources/Features/WatchV2List/WatchEntryComponents.swift` - Shared reusable components for watch entries (WatchGridCard and WatchListRow)
- `Sources/Features/WatchV2List/WatchV2ListViewModel.swift` - View model for the collection list view
- `Sources/Domain/WatchV2/WatchV2.swift` - Watch domain model containing manufacturer, modelName, line, and nickname fields
- `Sources/DesignSystem/Typography.swift` - Typography system defining font styles for the app
- `Sources/DesignSystem/Colors.swift` - Centralized color tokens for consistent theming
- `Sources/DesignSystem/Spacing.swift` - Spacing scale for layout rhythm
- `Tests/Unit/WatchV2ListTests.swift` - Unit tests for the collection list view (if exists, otherwise needs creation)

### Notes

- The current implementation is in `WatchV2ListView.swift` with embedded `WatchGridCard` and `WatchListRow` structs (lines 174-279)
- Grid view uses `LazyVGrid` with 2 flexible columns (lines 113-124)
- List view uses `LazyVStack` (lines 126-135)
- Watch model has: manufacturer, line, modelName, nickname (optional), and photos
- Design system already has `AppColors`, `AppSpacing`, and `AppTypography` for consistency
- Current implementation shows manufacturer + modelName concatenated, line separately, and nickname optionally

## Tasks

- [x] 1.0 Create Shared Component for Watch Entry Display
  - [x] 1.1 Extract `WatchGridCard` and `WatchListRow` into separate reusable components in a new file `WatchEntryComponents.swift`
  - [x] 1.2 Create a shared `WatchEntryContent` view that displays manufacturer, model, and nickname with consistent styling
  - [x] 1.3 Ensure the shared component handles optional nickname field gracefully without breaking layout
  - [x] 1.4 Update `WatchV2ListView.swift` to use the new shared components

- [x] 2.0 Implement Fixed-Size Grid Layout with Visual Hierarchy
  - [x] 2.1 Calculate optimal square dimensions for grid items (considering 2-column layout with proper spacing)
  - [x] 2.2 Apply fixed frame dimensions to grid items using `.frame(width:height:)` modifier
  - [x] 2.3 Implement visual hierarchy for text fields: manufacturer (large/bold), model (medium), nickname (small)
  - [x] 2.4 Remove shadows/borders from grid items to achieve flat design
  - [x] 2.5 Ensure consistent spacing between grid items using `AppSpacing` tokens
  - [x] 2.6 Position image prominently within each grid item with consistent sizing

- [ ] 3.0 Implement Consistent List View Layout
  - [ ] 3.1 Apply fixed height to all list items for consistency
  - [ ] 3.2 Implement same visual hierarchy as grid view (manufacturer large, model medium, nickname small)
  - [ ] 3.3 Ensure same font colors are used as grid view
  - [ ] 3.4 Apply consistent spacing and alignment using `AppSpacing` tokens
  - [ ] 3.5 Position image consistently within list items

- [ ] 4.0 Apply Text Truncation and Typography System
  - [ ] 4.1 Apply `.lineLimit(1)` and `.truncationMode(.tail)` to all text fields in both grid and list views
  - [ ] 4.2 Implement manufacturer text using large font from `AppTypography` or custom size
  - [ ] 4.3 Implement model text using medium font size
  - [ ] 4.4 Implement nickname text using small font from `AppTypography` (caption style)
  - [ ] 4.5 Verify text truncation works correctly with long manufacturer/model/nickname values

- [ ] 5.0 Ensure Design System Integration and Theme Consistency
  - [ ] 5.1 Replace all hardcoded colors with `AppColors` semantic tokens
  - [ ] 5.2 Replace all hardcoded spacing values with `AppSpacing` tokens
  - [ ] 5.3 Ensure text colors work correctly in both light and dark modes
  - [ ] 5.4 Verify layout consistency across different device sizes (iPhone SE, standard, Max)
  - [ ] 5.5 Test with watches that have missing optional fields (no nickname, no line)
  - [ ] 5.6 Verify visual consistency with rest of app's design principles

