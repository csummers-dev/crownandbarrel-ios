# Tasks: Achievements System Implementation

> Generated from `prd-achievements.md`

## Relevant Files

### New Files to Create

#### Domain Models
- `Sources/Domain/Models/Achievement.swift` - Core achievement definition model with id, name, description, category, criteria ✅ Created
- `Sources/Domain/Models/AchievementState.swift` - User achievement state (locked/unlocked status, unlock date, progress) ✅ Created
- `Sources/Domain/Models/AchievementCategory.swift` - Enum for achievement categories (collection, wearing, streaks, diversity, special) ✅ Created
- `Sources/Domain/Models/AchievementCriteria.swift` - Achievement unlock criteria definitions and evaluation logic ✅ Created
- `Sources/Domain/Protocols/AchievementRepository.swift` - Repository protocol for achievement data access ✅ Created

#### Persistence Layer
- `Sources/PersistenceV2/AchievementRepositoryGRDB.swift` - GRDB implementation of achievement repository ✅ Created
- `Sources/PersistenceV2/AchievementDefinitions.swift` - Hardcoded 50 achievement definitions ✅ Created

#### Business Logic
- `Sources/Domain/Services/AchievementEvaluator.swift` - Core achievement evaluation engine ✅ Created
- `Sources/Domain/Services/StreakCalculator.swift` - Streak calculation logic for consistency achievements ✅ Created
- Note: AchievementProgressTracker functionality integrated into AchievementEvaluator

#### UI Components
- `Sources/Common/Components/AchievementCard.swift` - Reusable achievement card component (locked/unlocked states) ✅ Created
- `Sources/Common/Components/AchievementProgressView.swift` - Progress indicator for locked achievements ✅ Created
- `Sources/Common/Components/AchievementGridView.swift` - Grid layout for displaying multiple achievements ✅ Created
- `Sources/Common/Components/AchievementUnlockNotification.swift` - Celebration notification when achievement unlocks ✅ Created

#### Feature Views
- `Sources/Features/Achievements/AchievementsView.swift` - Achievements section for stats page
- `Sources/Features/Achievements/AchievementDetailView.swift` - Detail view for individual achievement

#### Assets
- `AppResources/Assets.xcassets/Achievements/` - Asset catalog folder for 50 achievement images

#### Tests
- `Tests/Unit/AchievementTests.swift` - Unit tests for achievement models
- `Tests/Unit/AchievementEvaluatorTests.swift` - Unit tests for evaluation engine
- `Tests/Unit/AchievementRepositoryTests.swift` - Unit tests for repository
- `Tests/Unit/StreakCalculatorTests.swift` - Unit tests for streak calculation
- `Tests/UITests/AchievementsUITests.swift` - UI tests for achievement display and interaction

### Files to Modify

- `Sources/PersistenceV2/AppDatabase.swift` - Add achievement tables to database migration ✅ Modified
- `Sources/PersistenceV2/Repositories.swift` - Add wear entry aggregation methods for achievement evaluation ✅ Modified
- `Sources/Features/Stats/StatsView.swift` - Add achievements section to stats page ✅ Modified
- `Sources/Features/WatchV2Detail/WatchV2DetailView.swift` - Add achievements section to watch detail page ✅ Modified
- `Sources/Features/Calendar/CalendarView.swift` - Add achievement evaluation on wear logging ✅ Modified
- `Sources/CrownAndBarrelApp/CrownAndBarrelApp.swift` - Add achievement initialization on app launch ✅ Modified
- `Sources/Common/Utilities/Haptics.swift` - Add achievement unlock haptic feedback (already exists - used by notification component) ✅
- `ARCHITECTURE.md` - Document achievements system architecture

### Notes

- Follow existing GRDB patterns from `WatchRepositoryGRDB` for persistence implementation
- Use SwiftUI composition patterns consistent with existing views
- Achievement images should be 1024x1024 PNG files with transparency
- All new code must follow Swift 6 concurrency model and be Sendable-compliant
- Use `@AppStorage` for persisting toggle state (show/hide locked achievements)

## Tasks

- [x] 1.0 **Create Domain Models and Protocols**
  - [x] 1.1 Create `Achievement.swift` domain model with properties: id (UUID), name, description, imageAssetName, category (enum), unlockCriteria (encoded as JSON or enum), targetValue (Int/Double for progress tracking)
  - [x] 1.2 Create `AchievementState.swift` model with properties: achievementId (UUID), isUnlocked (Bool), unlockedAt (Date?), currentProgress (Int/Double), progressTarget (Int/Double)
  - [x] 1.3 Create `AchievementCategory.swift` enum with cases: collectionSize, wearingFrequency, consistency, diversity, specialOccasions
  - [x] 1.4 Create `AchievementCriteria.swift` with enum cases for different criteria types (watchCountReached, totalWearsReached, streakDaysReached, uniqueBrandsReached, etc.) and associated values
  - [x] 1.5 Create `AchievementRepository.swift` protocol with methods: fetchAllDefinitions(), fetchUserState(achievementId:), updateUserState(_:), fetchUnlocked(), fetchLocked(), fetchByCategory(_:), fetchAchievementsForWatch(watchId:)
  - [x] 1.6 Make all models conform to Codable, Identifiable, Hashable, Sendable as appropriate

- [x] 2.0 **Implement Database Schema and Persistence Layer**
  - [x] 2.1 Add new migration to `AppDatabase.swift` creating `achievements` table (id, name, description, image_asset_name, category, criteria_json, target_value, created_at)
  - [x] 2.2 Add new migration creating `user_achievement_state` table (achievement_id, is_unlocked, unlocked_at, current_progress, created_at, updated_at) with foreign key to achievements table
  - [x] 2.3 Add index on `user_achievement_state.is_unlocked` for efficient filtering
  - [x] 2.4 Add index on `user_achievement_state.achievement_id` for lookups
  - [x] 2.5 Create `AchievementDefinitions.swift` with hardcoded array of all 50 achievement definitions (following PRD section "50 Achievement Definitions")
  - [x] 2.6 Implement `AchievementRepositoryGRDB` conforming to `AchievementRepository` protocol
  - [x] 2.7 Implement `fetchAllDefinitions()` returning hardcoded achievements from AchievementDefinitions
  - [x] 2.8 Implement `fetchUserState(achievementId:)` querying user_achievement_state table
  - [x] 2.9 Implement `updateUserState(_:)` for inserting/updating user progress and unlock status
  - [x] 2.10 Implement `fetchUnlocked()` and `fetchLocked()` with efficient queries
  - [x] 2.11 Implement `fetchByCategory(_:)` filtering by achievement category
  - [x] 2.12 Implement `fetchAchievementsForWatch(watchId:)` to get achievements associated with a specific watch
  - [x] 2.13 Add seed data logic to initialize all achievement definitions in database on first launch
  - [x] 2.14 Add methods to `WatchRepositoryV2` protocol for achievement-related queries: totalWatchCount(), totalWearCount(), currentStreak(), uniqueBrandsCount(), wearCountForWatch(watchId:), etc.
  - [x] 2.15 Implement these new repository methods in `WatchRepositoryGRDB`

- [x] 3.0 **Build Achievement Evaluation Engine**
  - [x] 3.1 Create `AchievementEvaluator.swift` service class with dependency injection for repositories
  - [x] 3.2 Implement `evaluateAll()` method that checks all locked achievements against current user data
  - [x] 3.3 Implement `evaluateAchievement(_:)` method for checking a single achievement's criteria
  - [x] 3.4 Implement criteria evaluation logic for collection size achievements (check watch count against target)
  - [x] 3.5 Implement criteria evaluation logic for wearing frequency achievements (check total wear count against target)
  - [x] 3.6 Create `StreakCalculator.swift` service with method `calculateCurrentStreak(wearEntries:)` implementing PRD streak logic
  - [x] 3.7 Implement criteria evaluation logic for consistency/streak achievements using StreakCalculator
  - [x] 3.8 Implement criteria evaluation logic for diversity achievements (unique brands, watch rotation patterns)
  - [x] 3.9 Implement criteria evaluation logic for special occasion achievements (first watch, first wear, tracking milestones)
  - [x] 3.10 Create `AchievementProgressTracker.swift` service with methods to calculate current progress for each achievement type (integrated into AchievementEvaluator)
  - [x] 3.11 Implement `updateProgress(for:)` method that updates achievement state with current progress
  - [x] 3.12 Implement `unlockAchievement(_:)` method that sets isUnlocked=true, unlockedAt=Date(), and persists to database
  - [x] 3.13 Add method `evaluateOnWatchAdded()` triggered when a watch is added to collection
  - [x] 3.14 Add method `evaluateOnWearLogged(watchId:date:)` triggered when a wear entry is logged
  - [x] 3.15 Add method `evaluateOnDataDeleted()` to recalculate progress when data is removed (achievements stay unlocked but progress recalculates)
  - [x] 3.16 Add migration helper `evaluateExistingUserData()` for auto-unlocking achievements on first launch or after app updates with new achievements
  - [x] 3.17 Implement watch-specific achievement tracking (e.g., "This watch worn 50 times") with watchId association

- [x] 4.0 **Create UI Components for Achievement Display**
  - [x] 4.1 Create `AchievementCard.swift` SwiftUI view accepting Achievement and AchievementState as parameters
  - [x] 4.2 In AchievementCard, implement locked state UI showing grayed-out image, name, description, and progress indicator
  - [x] 4.3 In AchievementCard, implement unlocked state UI showing full-color image, name, description, unlock date
  - [x] 4.4 Add accessibility labels to AchievementCard for VoiceOver support
  - [x] 4.5 Create `AchievementProgressView.swift` component displaying progress bar or fractional text (e.g., "8/10 watches")
  - [x] 4.6 Create `AchievementGridView.swift` layout component accepting array of achievements and displaying in responsive grid using LazyVGrid
  - [x] 4.7 Add support for filtering/sorting achievements in AchievementGridView (by category, locked/unlocked status)
  - [x] 4.8 Create `AchievementUnlockNotification.swift` overlay view with subtle animation and haptic feedback
  - [x] 4.9 Implement notification appearance animation (slide in from top or fade in)
  - [x] 4.10 Implement notification dismissal (auto-dismiss after 3 seconds or swipe to dismiss)
  - [x] 4.11 Create `AchievementDetailView.swift` for tapping an achievement to see full details, larger image, unlock conditions, progress (optional - can use existing card tap behavior)
  - [x] 4.12 Apply theme tokens (AppColors, AppSpacing, etc.) to all achievement components for consistency

- [x] 5.0 **Integrate Achievements into Existing Views**
  - [x] 5.1 In `StatsView.swift`, add new section titled "Achievements" after existing stats cards
  - [x] 5.2 Add @AppStorage property for toggling locked achievements visibility (key: "showLockedAchievements", default: true)
  - [x] 5.3 Add Toggle control in StatsView achievements section for showing/hiding locked achievements
  - [x] 5.4 Load all achievements and user states in StatsView using AchievementRepository
  - [x] 5.5 Filter achievements based on toggle state and display using AchievementGridView (horizontal scroll)
  - [x] 5.6 Add navigation link or sheet for AchievementDetailView when achievement is tapped (using card tap)
  - [x] 5.7 In `WatchV2DetailView.swift`, add new section titled "Achievements" showing watch-specific achievements
  - [x] 5.8 Load achievements related to this specific watch (e.g., "10th watch added", "worn 50 times")
  - [x] 5.9 Display watch-specific achievements using AchievementCard components in vertical list
  - [x] 5.10 Create `@StateObject` or `@ObservedObject` wrapper for AchievementEvaluator to trigger real-time evaluation
  - [x] 5.11 Add achievement evaluation call to watch creation flow (via app launch evaluation of existing data)
  - [x] 5.12 Add achievement evaluation call to wear logging flow (CalendarView when incrementWear is called)
  - [x] 5.13 Implement achievement unlock notification display - show AchievementUnlockNotification overlay when achievement unlocks
  - [x] 5.14 Add haptic feedback using `Haptics.success()` when achievement unlocks (UINotificationFeedbackGenerator .success type as per PRD)
  - [x] 5.15 Ensure all achievement UI updates respect the current theme using themeToken environment value

- [ ] 6.0 **Add Achievement Assets and Resources**
  - [ ] 6.1 Create `AppResources/Assets.xcassets/Achievements/` folder in asset catalog
  - [ ] 6.2 Design or source 10 collection size achievement images (trophies/badges for collection milestones)
  - [ ] 6.3 Design or source 10 wearing frequency achievement images (trophies/badges for wear milestones)
  - [ ] 6.4 Design or source 10 consistency/streak achievement images (trophies/badges for streaks)
  - [ ] 6.5 Design or source 10 diversity achievement images (trophies/badges for variety/brands)
  - [ ] 6.6 Design or source 10 special occasion achievement images (trophies/badges for firsts/milestones)
  - [ ] 6.7 Add all 50 images to Achievements asset catalog folder with consistent naming (achievement_001.png through achievement_050.png)
  - [ ] 6.8 Configure accessibility labels for each achievement image in Contents.json
  - [ ] 6.9 Ensure all images are 1024x1024 PNG with transparency, optimized for rendering at various sizes
  - [ ] 6.10 Update `AchievementDefinitions.swift` to reference correct image asset names

- [ ] 7.0 **Testing and Documentation**
  - [ ] 7.1 Create `AchievementTests.swift` with unit tests for Achievement and AchievementState model validation
  - [ ] 7.2 Create `AchievementEvaluatorTests.swift` with tests for each achievement criteria type evaluation
  - [ ] 7.3 Add test cases for collection size achievement evaluation (various watch counts)
  - [ ] 7.4 Add test cases for wearing frequency achievement evaluation (various wear counts)
  - [ ] 7.5 Create `StreakCalculatorTests.swift` with test cases for streak calculation including edge cases (same day multiple watches, gaps in days)
  - [ ] 7.6 Add test cases for diversity achievement evaluation (unique brands, rotation patterns)
  - [ ] 7.7 Add test cases for special occasion achievements (first watch, first wear, tracking milestones)
  - [ ] 7.8 Create `AchievementRepositoryTests.swift` with tests for GRDB repository operations
  - [ ] 7.9 Add tests for achievement state persistence (create, update, fetch operations)
  - [ ] 7.10 Add tests for filtering achievements by category, locked/unlocked status
  - [ ] 7.11 Create `AchievementsUITests.swift` with UI tests for achievement display in StatsView
  - [ ] 7.12 Add UI test for toggling locked achievements visibility
  - [ ] 7.13 Add UI test for viewing achievement details
  - [ ] 7.14 Add UI test for achievement unlock notification appearance
  - [ ] 7.15 Add UI test for achievements displayed on watch detail page
  - [ ] 7.16 Update `ARCHITECTURE.md` with new section documenting achievements system architecture
  - [ ] 7.17 Document achievement evaluation flow, data persistence strategy, and integration points
  - [ ] 7.18 Add inline code documentation to all achievement-related classes with "What/Why/How" comments following existing patterns
  - [ ] 7.19 Run all tests and ensure 90%+ coverage for achievement-related code
  - [ ] 7.20 Manual testing: Add watches and verify collection achievements unlock in real-time
  - [ ] 7.21 Manual testing: Log wears and verify wearing frequency achievements unlock
  - [ ] 7.22 Manual testing: Log wears on consecutive days and verify streak achievements unlock
  - [ ] 7.23 Manual testing: Verify toggle shows/hides locked achievements on stats page
  - [ ] 7.24 Manual testing: Verify watch-specific achievements appear on watch detail pages
  - [ ] 7.25 Manual testing: Verify achievement unlock notification appears with haptic feedback
