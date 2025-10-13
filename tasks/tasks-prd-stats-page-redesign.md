## Relevant Files

- `Sources/Features/Stats/StatsView.swift` - Current stats screen; starting point for redesign or replacement.
- `Sources/Domain/WatchV2/WatchV2.swift` - Primary watch aggregate model used by stats.
- `Sources/Domain/WatchV2/WatchValueObjects.swift` - Case, dial, movement, water, ownership objects.
- `Sources/Domain/WatchV2/WatchChildEntities.swift` - Service history, valuations, straps data.
- `Sources/Domain/Models/WearEntry.swift` - Day-level wear entries; multiple watches per day.
- `Sources/PersistenceV2/Repositories.swift` - `WatchRepositoryV2` API; queries for counts, streaks, wear entries.
- `Sources/DesignSystem` - Colors/typography tokens for editorial luxury styling.
- `Sources/Common` - Utilities and formatters potentially reused by stats.
- `Tests/Unit` - Unit tests; add tests for aggregation, filters, and formatting.

### Notes

- Keep everything offline and fast; prefer precomputed aggregates with cache invalidation on data changes.
- Normalize wear entries to home timezone at start-of-day for stable grouping.
- Finance is USD-only; format with `en_US` locale and round consistently.

## Tasks

- [ ] 1.0 Establish Stats architecture and navigation
  - [ ] 1.1 Define top-level tabs: Collection, Wearing, Finance, Fun, with shared filters/ranges.
  - [ ] 1.2 Implement shared filter and date-range state (7D/30D/90D/YTD/All + custom).
  - [x] 1.3 Provide drill-in routes for detail metrics from cards/charts.

- [ ] 2.0 Build aggregation and caching layer (offline, large datasets)
  - [x] 2.1 Implement day/month aggregates from `WearEntry` with home-TZ normalization.
  - [x] 2.2 Add brand/movement/complication/material tallies from `WatchV2`.
  - [x] 2.3 Add spend/value buckets from `WatchOwnership` and valuations.
  - [x] 2.4 Add cache with invalidation on watch or wear changes; background precompute.

- [ ] 3.0 Implement Collection tab modules
  - [x] 3.1 Summary cards: counts, unique brands, total purchase, total value.
  - [x] 3.2 Composition charts: brand/country/movement/complications/materials.
  - [x] 3.3 Distributions: case size, thickness, lug-to-lug, water resistance.
  - [x] 3.4 Acquisition timeline: count and spend by month/year; cadence.
  - [x] 3.5 Service overview: last service and upcoming based on service history.
  - [x] 3.6 Box/Papers completeness summary.

- [ ] 4.0 Implement Wearing tab modules
  - [x] 4.1 Most/least worn lists (by days) with tie-breakers.
  - [x] 4.2 Rotation balance index visualization.
  - [x] 4.3 Neglect index and days since last wear.
  - [x] 4.4 Streaks: daily, brand, no-repeat.
  - [x] 4.5 Calendar heatmap with multi-watch indicators.
  - [x] 4.6 Weekday vs weekend breakdown.

- [ ] 5.0 Implement Finance tab modules (USD only)
  - [x] 5.1 Spend by year/brand from acquisition data.
  - [x] 5.2 Portfolio value vs cost basis; delta and %.
  - [x] 5.3 Liquidity scenario: top-3 to sell estimation.
  - [x] 5.4 Unit tests for currency formatting and totals `Tests/Unit/FinanceFormattingTests.swift`.

- [ ] 6.0 Implement Fun tab modules (private-only)
  - [x] 6.1 Heatmap recap cards.
  - [x] 6.2 Rotation health score + tips.
  - [x] 6.3 Brand bingo/completion.
  - [x] 6.4 Complication radar chart.
  - [x] 6.5 "Top 5 events" story cards.
  - [x] 6.6 Neglected watches nudge and suggested schedule.
  - [x] 6.7 Achievements alignment where applicable.

- [ ] 7.0 Cross-cutting: customization, styling, and accessibility
  - [ ] 7.1 Module reorder/hide and preset save per tab.
  - [ ] 7.2 Editorial luxury styling using design tokens; dark/light.
  - [ ] 7.3 A11y pass: Dynamic Type/VoiceOver; finalize requirements if needed.

- [ ] 8.0 Validation and QA
  - [ ] 8.1 Verify calculations vs sample data; DST/timezone edge cases.
  - [ ] 8.2 Ensure filters/ranges sync across all modules.
  - [ ] 8.3 Performance checks on large datasets; cold vs warm timings.
  - [ ] 8.4 Unit tests for aggregation, filters, finance formatting; snapshot tests for charts where feasible.

### Detailed Sub-Tasks

- [ ] 1.0 Establish Stats architecture and navigation
  - [x] 1.1 Create `Sources/Features/Stats/StatsRootView.swift` with `TabView` (Collection, Wearing, Finance, Fun).
  - [x] 1.2 Create `Sources/Features/Stats/StatsFiltersState.swift` to hold date range, custom range, brand/movement/complication/condition filters.
  - [x] 1.3 Build `Sources/Features/Stats/Controls/StatsFilterBar.swift` with chips and date range picker; expose bindings.
  - [x] 1.4 Persist filters/range via `@AppStorage` keys and initialize from stored values.
  - [ ] 1.5 Define `StatsRoute` enum and placeholder detail views for drill-ins (e.g., brand composition detail, per-watch wear history).
  - [ ] 1.6 Replace or wrap existing `StatsView` to route into new architecture while preserving achievements section for now.

- [ ] 2.0 Build aggregation and caching layer (offline, large datasets)
  - [x] 2.1 Add `Sources/Domain/Stats/StatsAggregator.swift` to compute:
        - Wear day counts per watch/day/week/month with home-TZ start-of-day normalization.
        - Brand/movement/complication/material tallies from `WatchV2`.
        - Finance buckets: spend by year/brand, portfolio totals, deltas.
  - [ ] 2.2 Add `Sources/Domain/Stats/StatsCache.swift` keyed by `(filters, dateRange, granularity)` with LRU and explicit invalidation.
  - [ ] 2.3 Hook cache invalidation to repository writes: watch create/update/delete, wear increment.
  - [ ] 2.4 Add background precompute via `Task.detached` or an `actor StatsIndexer` for common ranges (7D/30D/90D/YTD/All).
  - [x] 2.5 Add unit tests `Tests/Unit/StatsAggregatorTests.swift` covering grouping, filters, DST boundaries.

- [ ] 3.0 Implement Collection tab modules
  - [x] 3.1 Create `Sources/Features/Stats/Tabs/CollectionTabView.swift` and wire to aggregator.
  - [x] 3.2 Summary cards view `CollectionSummaryCards.swift` (counts, unique brands, total purchase/value). Use `NumberFormatter` en_US.
  - [x] 3.3 Composition charts `CollectionCompositionCharts.swift` for brand/country/movement/complications/materials using Swift Charts.
  - [ ] 3.4 Distributions `CollectionDistributionsView.swift` (histograms of diameter, thickness, L2L, WR). Choose sensible binning.
  - [ ] 3.5 Acquisition timeline `CollectionAcquisitionTimeline.swift` (month buckets, YOY toggle).
  - [ ] 3.6 Service overview `CollectionServiceOverview.swift` computing last service and upcoming (fallback interval policy noted).
  - [ ] 3.7 Box/Papers summary `CollectionBoxPapersSummary.swift`.

- [ ] 4.0 Implement Wearing tab modules
  - [x] 4.1 Create `Sources/Features/Stats/Tabs/WearingTabView.swift`.
  - [x] 4.2 Most/least worn lists `WearingListsView.swift` using day counts; tie-break by last worn date.
  - [x] 4.3 Rotation balance index `RotationBalanceView.swift` (decide formula: Gini or entropy; implement helper in aggregator).
  - [x] 4.4 Neglect index `NeglectIndexView.swift` (days since last wear; threshold and sorting).
  - [x] 4.5 Streaks `StreaksView.swift` (daily, optional brand, no-repeat algorithms).
  - [x] 4.6 Calendar heatmap `WearHeatmapView.swift` with multi-watch indicators (stack/count badge) and range navigation.
  - [x] 4.7 Weekday vs weekend breakdown `WeekdayWeekendBreakdownView.swift`.

- [ ] 5.0 Implement Finance tab modules (USD only)
  - [ ] 5.1 Create `Sources/Features/Stats/Tabs/FinanceTabView.swift`.
  - [ ] 5.2 Spend by year/brand chart `SpendByPeriodView.swift` grouped by `ownership.dateAcquired`.
  - [ ] 5.3 Portfolio vs cost `PortfolioDeltaView.swift` with absolute and percentage deltas.
  - [ ] 5.4 Liquidity scenario `LiquidityScenarioView.swift` (heuristics: top estimated value or best delta; clear disclaimers).
  - [ ] 5.5 Unit tests for currency formatting and totals `Tests/Unit/FinanceFormattingTests.swift`.

- [ ] 6.0 Implement Fun tab modules (private-only)
  - [x] 6.1 Create `Sources/Features/Stats/Tabs/FunTabView.swift`.
  - [x] 6.2 Heatmap recap cards `FunHeatmapRecapCard.swift` (preset popular ranges).
  - [x] 6.3 Rotation health score `RotationHealthCard.swift` plus tips engine suggesting next wears.
  - [x] 6.3 Rotation health score `RotationHealthCard.swift` plus tips engine suggesting next wears.
  - [x] 6.4 Brand bingo `BrandBingoView.swift` (grid derived from manufacturers present).
  - [x] 6.5 Complication radar chart `ComplicationRadarView.swift` from `dial.complications` counts.
  - [x] 6.6 Top 5 events `TopEventsCards.swift` (most-worn month, longest streak, new brand unlocked, etc.).
  - [ ] 6.7 Achievements alignment: integrate with `AchievementRepository` and `AchievementEvaluator` where applicable.

- [ ] 7.0 Cross-cutting: customization, styling, and accessibility
  - [x] 7.1 Implement module reorder/hide UI `ModulesCustomizeView.swift`; persist per-tab presets.
  - [x] 7.2 Apply design tokens for editorial luxury style; verify dark/light variants and haptics on interactions.
  - [x] 7.3 Accessibility pass: Dynamic Type scaling, VoiceOver labels/descriptions for charts, contrast checks.

- [ ] 8.0 Validation and QA
  - [x] 8.1 Add sample data generator usage in tests; build golden assertions for aggregates.
  - [x] 8.2 Create DST/TZ boundary test cases (spring-forward/fall-back, TZ changes) for wear grouping.
  - [x] 8.3 Instrument performance with `os_signpost`; document cold vs warm timings; optimize cache.
  - [x] 8.4 Create UAT checklist mapping each FR to a verification step; run through on device.

## Additional Relevant Files (Created/Updated)

- `Sources/Features/Stats/StatsRootView.swift` - New root view hosting tabs and filters.
- `Sources/Features/Stats/StatsFiltersState.swift` - Centralized filter/date range state.
- `Sources/Features/Stats/Controls/StatsFilterBar.swift` - Filter chips and date range UI.
- `Sources/Features/Stats/Tabs/CollectionTabView.swift` - Collection tab container.
- `Sources/Features/Stats/Tabs/WearingTabView.swift` - Wearing tab container.
- `Sources/Features/Stats/Tabs/FinanceTabView.swift` - Finance tab container.
- `Sources/Features/Stats/Tabs/FunTabView.swift` - Fun tab container.
- `Sources/Domain/Stats/StatsAggregator.swift` - Aggregations across watches and wear entries.
- `Sources/Domain/Stats/CollectionTallies.swift` - Structs for collection composition tallies.
- `Sources/Domain/Stats/StatsCache.swift` - In-memory cache and invalidation.
- `Sources/Domain/Stats/FinanceBuckets.swift` - Finance aggregation result types.
- `Sources/Domain/Stats/AcquisitionTimeline.swift` - Types for acquisition timeline aggregation.
- `Sources/Domain/Stats/StatsIndexer.swift` - Background precompute for common ranges.
- `Sources/Features/Stats/Tabs/CollectionSummaryCards.swift` - Summary cards UI component.
- `Sources/Features/Stats/Tabs/CollectionCompositionCharts.swift` - Composition charts UI.
- `Sources/Features/Stats/Tabs/CollectionAcquisitionTimeline.swift` - Acquisition timeline chart UI.
- `Sources/Features/Stats/Tabs/WearHeatmapView.swift` - Calendar heatmap UI component.
- `Sources/Features/Stats/Tabs/WeekdayWeekendBreakdownView.swift` - Weekday vs weekend charts.
- `Sources/Domain/Stats/WeekdayWeekend.swift` - Weekday/weekend aggregation types.
- `Sources/Features/Stats/StatsRoute.swift`
- `Sources/Features/Stats/Tabs/FunHeatmapRecapCard.swift` - Fun tab heatmap card.
- `Sources/Features/Stats/Tabs/BrandBingoView.swift` - Brand bingo grid.
- `Sources/Features/Stats/Tabs/ComplicationRadarView.swift` - Radar chart for complications.
- `Sources/Features/Stats/Tabs/RotationHealthCard.swift` - Rotation health score and tips.
- `Sources/Features/Stats/Tabs/TopEventsCards.swift` - Top events cards.