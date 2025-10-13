## Stats Page Redesign PRD

### 1. Introduction / Overview
Redesign the Stats experience into a comprehensive, offline-first analytics hub for a watch collection. Emphasis is on: A) showcasing collection depth and curation, D) social/shareable-style brag stats presentation aesthetics (but private-only), B) encouraging healthier, more balanced wearing rotation, and C) surfacing ownership lifecycle/value insights. The tone blends playful/gamified elements with minimal/analytical structure and light editorial storytelling.

### 2. Goals
- Provide an at-a-glance understanding of collection composition and usage patterns.
- Encourage balanced rotation by highlighting frequently/rarely worn pieces.
- Offer clear historical spending and portfolio value context (USD only).
- Maintain fully offline, private operation with fast performance on large datasets.
- Deliver a luxurious, editorial visual style with intuitive drill-downs.

### 3. User Stories
- As a collector, I want to see which watches I wear most by day so I can rotate better.
- As an enthusiast, I want a calendar heatmap of wear days to visualize streaks.
- As an owner, I want spending and value summaries to understand my portfolio.
- As a planner, I want brand/movement/complication breakdowns to guide the next purchase.
- As a caretaker, I want to see service history summaries and upcoming needs.
- As a power user, I want filters and date ranges that apply across all modules.

### 4. Functional Requirements
1) Navigation and Structure
   - FR-1.1: The Stats feature is a single SwiftUI screen with modular sections organized as tabs: Collection, Wearing, Finance, Fun.
   - FR-1.2: Each tab renders independent modules (cards/charts/lists) and supports cross-tab shared filters and date ranges.
   - FR-1.3: Tapping a stat/card drills into a focused detail view for that metric where applicable.

2) Data Sources (existing)
   - Watch identity and attributes from `WatchV2`:
     - Core: `manufacturer`, `line`, `modelName`, `referenceNumber`, `nickname`, `countryOfOrigin`, `tags`.
     - Case/dimensions: `watchCase.diameterMM`, `watchCase.thicknessMM`, `watchCase.lugToLugMM`, `watchCase.material`.
     - Movement: `movement.type`, `movement.caliber`, `movement.powerReserveHours`.
     - Dial: `dial.color`, `dial.finish`, `dial.complications`.
     - Water: `water.waterResistanceM`.
     - Ownership: `ownership.dateAcquired`, `ownership.purchasedFrom`, `ownership.purchasePriceAmount`, `ownership.purchasePriceCurrency`, `ownership.condition`, `ownership.boxPapers`, `ownership.currentEstimatedValueAmount`, `ownership.currentEstimatedValueCurrency`.
     - Children: `serviceHistory[date, provider, workDescription, costAmount, costCurrency, warrantyUntil]`, `valuations[date, source, valueAmount, valueCurrency]`.
   - Wear tracking from `WearEntry` (one entry per watch per day; no durations). Multiple watches per day are supported.
   - Repository capabilities: total counts, wear counts per watch, last worn date, unique brands, streaks, all wear entries, first dates.

3) Time and Timezone
   - FR-3.1: Normalize all wear dates to the user’s home timezone. Store and aggregate by start-of-day in home TZ.
   - FR-3.2: A day can include multiple watches; each watch contributes one day to its wear count.

4) Date Ranges and Filters
   - FR-4.1: Date ranges: 7D, 30D, 90D, YTD, All, plus a custom date range picker.
   - FR-4.2: Filters (multi-select where applicable): Brand, Movement/Complication, Price bracket (derived from `ownership.purchasePriceAmount`), In-rotation vs vaulted/for sale (derived from tags or condition), Condition/Service status.
   - FR-4.3: Chart granularity auto-selects Day/Week/Month based on range; lists honor the same filters/range.

5) Collection Tab
   - FR-5.1: Summary cards: total watches, unique brands, total purchase cost (USD), total estimated value (USD).
   - FR-5.2: Composition breakdowns: by brand, country, movement type, complications, materials.
   - FR-5.3: Distributions: case diameter, thickness, lug-to-lug, water resistance.
   - FR-5.4: Acquisition timeline: count and spend by month/year; cadence chart.
   - FR-5.5: Service overview: last service per watch and upcoming (based on `serviceHistory.warrantyUntil` or derived intervals when present).
   - FR-5.6: Box/Papers completeness summary from `ownership.boxPapers`.

6) Wearing Tab
   - FR-6.1: Most worn (by days) and least worn lists within selected range; ties resolved by most recent wear.
   - FR-6.2: Rotation balance index: visualizes distribution equality across watches worn in range.
   - FR-6.3: Neglect index: highlights watches with zero days worn in range and days since last wear.
   - FR-6.4: Streaks: daily wear streak (global), optional brand streaks, and no-repeat streak (sequence of distinct watches across days).
   - FR-6.5: Calendar heatmap of wear days at day granularity; multiple watches per day show stacked indicators or a count badge.
   - FR-6.6: Context views: weekday/weekend breakdown is supported (derived from date). Advanced contexts (work/travel) require wear-entry tags and are out of scope.

7) Finance Tab
   - FR-7.1: Spend by year/brand from `ownership.purchasePriceAmount` grouped by `ownership.dateAcquired`.
   - FR-7.2: Portfolio value (sum `ownership.currentEstimatedValueAmount`) vs cost basis (sum `purchasePriceAmount`); delta and percentage.
   - FR-7.3: Liquidity scenario: suggest “top 3 to sell” by highest estimated value or best delta; show total proceeds in USD.
   - FR-7.4: Currency: Display USD only; format according to `en_US`.

8) Comparative / Benchmarking
   - FR-8.1: Per-watch panel comparing its wear days and value to collection averages within the selected range.
   - FR-8.2: Month-by-month and year-over-year charts for wear days and acquisition spend.

9) Fun Tab (Creative Modules; private-only)
   - FR-9.1: Wear heatmap calendar (range-aware).
   - FR-9.2: Rotation health score with actionable tips (e.g., “Wear your neglected top 3 this week”).
   - FR-9.3: Brand bingo/completion cards based on `manufacturer` variety.
   - FR-9.4: Complication radar chart based on `dial.complications`.
   - FR-9.5: “Top 5 events” cards (e.g., most-worn month, new brand unlocked, longest streak).
   - FR-9.6: “Neglected watches” nudge with suggested schedule (picks N oldest-not-worn pieces).
   - FR-9.7: Collector milestones/achievements (badges) aligned to streaks, wear counts, unique brands.
   - FR-9.8: No share/export functionality; everything is private-only.

10) Customization
   - FR-10.1: Users can reorder/hide modules within each tab via an Edit screen.
   - FR-10.2: Users can save one default preset per tab.
   - FR-10.3: Users can set personal monthly wear targets per watch (optional; can be deferred if not trivial).

11) Performance, Offline, Precomputation
   - FR-11.1: Entire Stats experience is fully offline; no network usage.
   - FR-11.2: Must support large datasets (hundreds of watches; multi-year wear history).
   - FR-11.3: Background precomputation and indexing permitted for aggregations (e.g., daily counts, month buckets, brand tallies) with local caching.
   - FR-11.4: Initial render should be responsive; subsequent range/filter changes should be near-instant via cached aggregates.

12) UX / Visual Style
   - FR-12.1: Editorial luxury style (refined typography, ample spacing, premium palette) consistent with existing design system.
   - FR-12.2: Charts favor clarity; use SwiftUI Charts with metallic-inspired palette when appropriate.
   - FR-12.3: Drill-ins open sheets or push to detail views with consistent transitions; long-press to favorite/pin where relevant.

### 5. Non-Goals (Out of Scope for now)
- Automated valuation fetching or updates.
- Social leaderboards, public profiles, or external sharing/exports.
- Location-based maps or travel heatmaps.
- Time-of-day analytics and context tags for wear entries (no wear-entry metadata today).

### 6. Design Considerations
- Tabs: Collection / Wearing / Finance / Fun.
- Editorial luxury vibe with subtle gamification.
- Heatmap and radar charts should feel premium and legible in dark/light themes.
- Tap-to-drill for any stat; consider pin/favorite for quick access.

### 7. Technical Considerations
- Data model alignment
  - `WatchV2` fields listed above; `WatchOwnership` provides purchase/value/condition; `ServiceHistoryEntry` and `ValuationEntry` support service/value timelines.
  - `WearEntry` is day-level only; multiple per day across watches; no durations.
- Timezone policy
  - Normalize to home TZ; persist `WearEntry.date` at start-of-day home TZ for stable grouping.
- Aggregations and caching
  - Build per-day and per-month aggregates from `WearEntry` and ownership data. Cache per filter/range hash keys.
- Large dataset performance
  - Use background tasks to (re)index aggregates; invalidate caches when watches or wear entries change.
- Charts
  - Use SwiftUI Charts; auto granularity by range.
- Formatting
  - All currency in USD; format using `en_US` locale; no currency conversion.
- Architecture
  - One SwiftUI view composed of modular sections, each as a subview with a local store; shared filters/ranges at the top level.

### 8. Success Metrics
- Acceptance criteria (must pass):
  - A) Stats match manual calculations on representative sample data.
  - B) Filters/ranges remain in sync across all modules.
- Product success: Not specified (per input).

### 9. Open Questions
- Accessibility targets: Dynamic Type, VoiceOver, contrast ratios?
- Internationalization: Right-to-left and locale formatting beyond USD?
- Personal targets (FR-10.3): include at v1 or defer?
- Neglect/rotation scoring formulas: finalize thresholds and copy.
- Performance SLOs: e.g., render <150ms from cached aggregates; <600ms cold?
- Service “upcoming” definition: default interval if no warrantyUntil present?

### 10. Acceptance Test Notes (Data Validations)
- Wear counts and streaks computed from `WearEntry` day-level data; verify with sample sets including multiple watches per day.
- Composition and distributions map to `WatchV2` fields exactly; confirm null/empty handling.
- Finance charts use only `WatchOwnership` amounts and `dateAcquired` for grouping; USD only.
- Timezone correctness: boundary tests around DST and TZ changes.


