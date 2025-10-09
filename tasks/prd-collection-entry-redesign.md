# Product Requirements Document: Collection Entry View Redesign

## Introduction/Overview

The collection entry detail view will be redesigned to provide a clean, elegant, and scannable interface for viewing individual watch details. The redesign addresses usability issues with the current expand/collapse pattern, which creates unnecessary friction and hides information behind interaction barriers. The new design will display all available information in a single, scrollable page with a visual hierarchy that prioritizes the most important details—watch photos, brand identity, and wear statistics—while maintaining the luxury aesthetic established in the collection list view.

**Problem Statement:** The current collection entry view uses collapsible sections that require users to tap multiple times to see all their watch details. This creates a fragmented experience that doesn't match the app's luxury positioning and makes it harder to appreciate the watch at a glance.

**Goal:** Create a streamlined, elegant detail view that displays all watch information without expansion controls, shows only populated fields, and provides quick access to wear statistics and achievements in a visually cohesive layout.

## Goals

1. **Eliminate Interaction Friction:** Remove all expand/collapse controls to provide immediate access to all watch details in a single scroll
2. **Improve Information Density:** Show only fields that contain data, avoiding empty states and placeholder text that add visual clutter
3. **Enhance Visual Hierarchy:** Prioritize watch photos, brand/model information, and wear statistics to match user mental models
4. **Maintain Design Consistency:** Align the detail view aesthetic with the collection list view's simple, beautiful, clean design language
5. **Surface Key Statistics:** Make wear count, last worn date, and achievement progress immediately visible without navigation

## User Stories

1. **As a watch collector**, I want to see all my watch's details at once so that I can quickly reference any information without multiple taps
2. **As a watch enthusiast**, I want to see only the fields I've filled out so that the view feels tailored to my specific watch and not cluttered with empty placeholders
3. **As a user tracking my collection**, I want to see how many times I've worn this watch prominently displayed so that I understand my wearing patterns
4. **As an achievement-oriented user**, I want to see which achievements this watch has unlocked displayed at the bottom in an icon row so that I feel a sense of accomplishment
5. **As a visual learner**, I want to browse through all my watch photos in a gallery so that I can appreciate different angles and details
6. **As a user focused on details**, I want technical specifications grouped logically so that I can easily find case dimensions, movement specs, or ownership information

## Functional Requirements

### FR1: Photo Gallery Display
- **FR1.1** Display all watch photos in a horizontal carousel/gallery at the top of the view
- **FR1.2** If multiple photos exist, enable swiping between photos with page indicator dots
- **FR1.3** If no photos exist, display a tasteful placeholder matching the collection list style
- **FR1.4** Primary photo should be displayed first in the carousel

### FR2: Watch Identity Section
- **FR2.1** Display manufacturer and model name prominently below the photo gallery using luxury serif typography
- **FR2.2** Show line/collection name if populated
- **FR2.3** Display reference number if available
- **FR2.4** Show nickname if set, using a visually distinct but complementary style
- **FR2.5** Fields with no value should be completely hidden (not shown with dashes or placeholders)

### FR3: Statistics Section
- **FR3.1** Display "Times Worn" count in a prominent, easy-to-scan format
- **FR3.2** Display "Last Worn" date if the watch has been worn at least once
- **FR3.3** Display achievement progress summary (e.g., "5 of 12 achievements unlocked")
- **FR3.4** Statistics should be grouped together and visually distinct from other details

### FR4: Technical Specifications Display
The following specification groups should be displayed only when at least one field in the group contains data:

- **FR4.1 Core Details Group:** Serial number, production year, country of origin, limited edition number, personal notes, tags
- **FR4.2 Case Specifications Group:** Material, finish, shape, diameter, thickness, lug-to-lug, lug width, bezel type, bezel material, caseback type, caseback material
- **FR4.3 Dial Details Group:** Dial color, finish, indices style, indices material, hands style, hands material, lume type, complications
- **FR4.4 Crystal Details Group:** Crystal material, shape/profile, AR coating
- **FR4.5 Movement Specifications Group:** Movement type, caliber, power reserve, frequency (VPH), jewel count, accuracy specification, chronometer certification
- **FR4.6 Water Resistance Group:** Water resistance (meters), crown type, crown guard presence
- **FR4.7 Strap/Bracelet Details Group:** Strap type, material, color, end links, clasp type, bracelet link count, quick release capability
- **FR4.8 Ownership Information Group:** Date acquired, purchased from, purchase price (with currency), condition, box/papers status, current estimated value (with currency), insurance provider, insurance policy number, insurance renewal date

### FR5: Child Collections Display
- **FR5.1** If service history entries exist, display them in a list format showing date, provider, work description, and cost
- **FR5.2** If valuation entries exist, display them showing date, source, and value
- **FR5.3** If strap inventory items exist, display them showing type, material, color, and width
- **FR5.4** Each collection should be labeled with a clear section header

### FR6: Achievements Display
- **FR6.1** Display watch-specific achievements in a horizontal row at the bottom of the view
- **FR6.2** Show achievement icon/badge with label text below
- **FR6.3** Allow achievements to wrap to multiple rows if needed
- **FR6.4** Only display unlocked achievements related to this specific watch
- **FR6.5** Achievements should include single-watch milestones (e.g., "Favorite Watch" for 10 wears, "True Love" for 50 wears)

### FR7: Layout and Styling
- **FR7.1** Use a single `ScrollView` without any collapsible sections
- **FR7.2** Apply consistent spacing using `AppSpacing` tokens (xs, sm, md, lg, xl)
- **FR7.3** Use `AppTypography` styles: serif for headings/brands, sans-serif for body text
- **FR7.4** Match the visual style of the collection list view (grid/list cards)
- **FR7.5** Maintain the luxury aesthetic with elegant typography, generous white space, and refined visual hierarchy
- **FR7.6** Group related fields visually using spacing and subtle visual separators

### FR8: Field Visibility Logic
- **FR8.1** For optional String fields: hide if nil or empty string
- **FR8.2** For optional numeric fields: hide if nil
- **FR8.3** For optional Date fields: hide if nil
- **FR8.4** For optional enum fields: hide if nil
- **FR8.5** For array/collection fields: hide entire section if empty
- **FR8.6** For Boolean fields: only show if true (e.g., "Crown Guard: Yes" only appears if crownGuard == true)

### FR9: Empty State
- **FR9.1** If a watch has only core identity fields filled (manufacturer, model), still display the view normally
- **FR9.2** Do not show any "Add more details" prompts or empty state messaging
- **FR9.3** The view should gracefully adapt to show only available information

## Non-Goals (Out of Scope)

1. **Edit Actions:** This view will not include inline editing or action buttons (Edit remains in navigation bar per existing implementation)
2. **Delete Actions:** No delete functionality in this view
3. **Share Functionality:** No share button or export options
4. **Comparison Mode:** Not building watch-to-watch comparison
5. **Photo Editing:** No ability to reorder, delete, or edit photos from this view
6. **Manual Achievement Tracking:** Achievements remain automatically calculated based on wear data
7. **Customizable Field Order:** Field groupings and order are fixed by the design, not user-customizable
8. **Collapsible Preferences:** No user preference to toggle between expanded/collapsed modes

## Design Considerations

### Visual Hierarchy (Priority Order)
1. **Watch Photos** - Largest, most prominent element at the top
2. **Brand and Model Name** - Serif typography, bold/medium weight, immediately below photos
3. **Times Worn Statistic** - Featured prominently in statistics section
4. **Most Recent Activity Date** - Supporting context for wear patterns

### Layout Structure
```
┌─────────────────────────────────┐
│  Photo Gallery (Carousel)       │
│  (Swipeable, page indicators)   │
├─────────────────────────────────┤
│  Manufacturer + Model (Serif)   │
│  Line • Reference                │
│  "Nickname" (if present)         │
├─────────────────────────────────┤
│  📊 Statistics Section           │
│  Times Worn: 42                  │
│  Last Worn: Jan 15, 2025         │
│  Achievements: 5/12 unlocked     │
├─────────────────────────────────┤
│  Core Details                    │
│  Serial Number: ABC123           │
│  Production Year: 2023           │
│  Country: Switzerland            │
├─────────────────────────────────┤
│  Case Specifications             │
│  Material: Stainless Steel       │
│  Diameter: 40mm                  │
│  ... (only populated fields)     │
├─────────────────────────────────┤
│  [Other specification groups]    │
│  ... (as populated)              │
├─────────────────────────────────┤
│  🏆 Achievements                 │
│  [Icon] [Icon] [Icon]            │
│  Label   Label   Label           │
└─────────────────────────────────┘
```

### Component Reuse
- Leverage `WatchImageView` for photo display
- Use existing `AppColors`, `AppSpacing`, `AppTypography` tokens
- Reuse `AchievementCard` or create simplified `AchievementBadge` component
- Apply same card styling/shadows as `WatchGridCard` for consistency

### Typography Guidelines
- **Manufacturer + Model**: `AppTypography.luxury` or `.heading` (serif, 18-20pt)
- **Section Headers**: `AppTypography.heading` (serif, headline weight)
- **Field Labels**: System `.subheadline` or `.caption` in secondary color
- **Field Values**: System `.body` in primary text color
- **Statistics**: System `.title3` or `.title2` for emphasis

## Technical Considerations

### Data Loading
- Watch data is passed via initializer: `init(watch: WatchV2)`
- Wear count must be fetched: `watchRepository.wearCountForWatch(watchId:)`
- Last worn date requires query for most recent `WearEntry` for this watch
- Achievements must be loaded and filtered: `achievementRepository.fetchAchievementsWithStates()`

### Performance
- Avoid loading all photos at full resolution; use `PhotoStoreV2.loadThumb()` for gallery
- Lazy load achievement data in `.task` modifier
- Consider computed properties for field visibility to keep view body clean

### Repository Methods Needed
- `watchRepository.wearCountForWatch(watchId: UUID) async throws -> Int` (likely exists)
- `watchRepository.lastWornDate(watchId: UUID) async throws -> Date?` (may need to implement)
- `achievementRepository.fetchAchievementsForWatch(watchId: UUID) async throws -> [(Achievement, AchievementState?)]` (may need filtering logic)

### Testing Considerations
- Test with watch entries that have minimal data (only manufacturer + model)
- Test with watch entries that have extensive data across all specification groups
- Test with watches that have 0 wears, 1 wear, and 50+ wears
- Test with watches that have 0 photos, 1 photo, and 5+ photos
- Test achievement display with 0, 1, 3, and 10+ unlocked achievements
- Verify achievement row wraps properly on smaller screens

## Success Metrics

1. **Quick Information Access:** Users can find any watch detail within 5 seconds (down from current multi-tap process)
2. **Improved Aesthetics:** The view feels more elegant and matches the app's luxury theme, as measured by user feedback or design review
3. **Reduced Support Requests:** Fewer complaints about navigation difficulties or "hidden" information
4. **Increased Engagement:** Users spend more time viewing their collection entries (tracked via analytics if available)
5. **Visual Consistency:** Design passes review for consistency with collection list view style

## Open Questions

1. **Section Order:** Should service history and valuations appear before or after technical specifications?
   - **Recommendation:** After technical specs but before achievements, as they're historical context rather than inherent watch properties

2. **Numeric Precision:** How many decimal places should we show for measurements (e.g., diameter: 40mm vs 40.5mm vs 40.50mm)?
   - **Recommendation:** Show decimals only if non-zero (40mm, 40.5mm) using `String(format:)` or similar formatting

3. **Currency Display:** How should we format purchase prices and valuations with currency codes?
   - **Recommendation:** Use `NumberFormatter` with currency style and the specified currency code (e.g., "$1,250 USD", "€2.500 EUR")

4. **Date Formatting:** Should "Last Worn" show relative dates ("3 days ago") or absolute dates ("Jan 15, 2025")?
   - **Recommendation:** Use relative dates for recent wears (< 7 days ago) and absolute dates for older wears

5. **Achievement Badge Size:** What dimensions should achievement icons use in the horizontal row?
   - **Recommendation:** 60x60pt with 8-12pt spacing between badges, allowing room for multi-line label text below

6. **Empty Photo State:** Should the placeholder match the current system icon style or use a custom luxury placeholder?
   - **Recommendation:** Reuse existing placeholder logic from `WatchGridCard` for consistency

7. **Section Headers:** Should specification groups have visible headers ("Case Specifications") or be visually implied through spacing?
   - **Recommendation:** Include subtle headers using `AppTypography.heading` for clarity and scannability

8. **Tags Display:** Should tags be shown as pills/chips or as a comma-separated list?
   - **Recommendation:** Show as a wrapped horizontal row of pills for better visual scanning

9. **Strap Inventory:** If a watch has 5+ straps, should there be a "Show more" control or display all?
   - **Recommendation:** Show all straps; users who collect straps will want to see them all

10. **Service History Sorting:** Should service entries be shown newest-first or oldest-first?
    - **Recommendation:** Newest-first (reverse chronological) to show most recent service at the top
