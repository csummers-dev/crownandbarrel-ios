## Relevant Files

- `Sources/Features/StatsSingle/StatsSingleView.swift` - New single-page stats container (scroll view with all sections).
- `Sources/Features/StatsSingle/Sections/CollectionSection.swift` - Collection section (summary, composition, distributions, acquisition, service, box/papers).
- `Sources/Features/StatsSingle/Sections/WearingSection.swift` - Wearing section (most/least, balance, neglect, streaks, heatmap, weekday/weekend).
- `Sources/Features/StatsSingle/Sections/FinanceSection.swift` - Finance section (portfolio vs cost, spend by year/brand, liquidity).
- `Sources/Features/StatsSingle/Sections/FunSection.swift` - Fun section (rotation health, brand bingo, complication radar, top events, nudge, achievements).
- `Sources/Domain/Stats/*` - Aggregations reused (ensure all-time, no-filter assumptions and caching paths).
- `Sources/CrownAndBarrelApp/RootView.swift` - Replace Stats tab to present the new single-page `StatsSingleView`.
- `Sources/Features/Stats/StatsView.swift` - Old tabbed Stats entry (to remove).
- `Sources/CrownAndBarrelApp/StatsRootViewShim.swift` - Temporary shim used during migration (to remove).
- `Sources/Features/Stats/**` - Old multi-tab modules (collection/wearing/finance/fun tab containers) to decommission after port.

### Notes

- No filters and no drill-ins; all content is visible inline with sensible Top-N + "Others" rollups.
- Aggregations should compute once per appearance; precompute/caching for all-time ranges only.
- Style should match collection entry cards (spacing/typography/colors) for visual cohesion.

## Tasks

- [ ] 1.0 Create single-page Stats container
  - [x] 1.1 Implement `StatsSingleView` with a vertical scroll view and a page title/header (no filters).
  - [x] 1.2 Add section anchors/ids for optional jump-to-section index (non-sticky; simple inline index at top).

- [ ] 2.0 Build sections (reusing/porting existing components)
  - [ ] 2.1 CollectionSection: summary cards; composition charts (Top-N + Others); distributions; acquisition timeline (all-time); service overview; box/papers.
  - [ ] 2.2 WearingSection: most/least worn (unique days); rotation balance (with brief explanatory text); neglect index; streaks; calendar heatmap (multi-year, compact); weekday vs weekend.
  - [ ] 2.3 FinanceSection: portfolio vs cost (delta/%); spend by year/brand (Top-N + Others); liquidity scenario (top 3 by estimated value) with disclaimer.
  - [ ] 2.4 FunSection: rotation health with suggestions; brand bingo; complication radar (normalized labels); top 5 events; neglected nudge; achievements strip.

- [ ] 3.0 Aggregation and data flow (no filters)
  - [ ] 3.1 Consolidate/ensure aggregations support all-time without filters (reuse existing `StatsAggregator`).
  - [ ] 3.2 Add an all-time precompute/caching path (no filter keys) and warm on first load.
  - [ ] 3.3 Stream results to sections (placeholders/skeletons until data is ready) and avoid blocking first paint.

- [ ] 4.0 Visual design pass (align to collection entry views)
  - [ ] 4.1 Apply consistent card layout, spacing rhythm, and headings across all sections.
  - [ ] 4.2 Normalize chart palettes/legends and ensure density is legible (Top-N + Others).
  - [ ] 4.3 Ensure compact list layouts for service, neglect, achievements, etc., to keep scroll length reasonable.

- [ ] 5.0 Accessibility and a11y labels
  - [ ] 5.1 Add VoiceOver labels/values for summaries and key chart marks (brand/value, date/count).
  - [ ] 5.2 Verify Dynamic Type and contrast; fix any truncation.

- [ ] 6.0 Performance and scrolling
  - [ ] 6.1 Precompute all-time aggregates in background on app launch/first visit.
  - [ ] 6.2 Target smooth scrolling on large datasets; bound heavy lists with Top-N and inline "Show more" expanders (still in-page).
  - [ ] 6.3 Add signposts for initial render and per-section load.

- [ ] 7.0 Migrate navigation and remove old stats experience
  - [ ] 7.1 Update `RootView.swift` Stats tab to present `StatsSingleView`.
  - [ ] 7.2 Remove old `Sources/Features/Stats/StatsView.swift` and tab containers under `Sources/Features/Stats/Tabs/*` after parity is verified.
  - [ ] 7.3 Remove app-target `StatsRootViewShim.swift` and any temporary Local* shims added during migration.
  - [ ] 7.4 Clean up unused design components and references.

- [ ] 8.0 QA & UAT
  - [ ] 8.1 Verify all totals/charts against sample data and existing validation tests.
  - [ ] 8.2 Multi-year calendar heatmap: verify legibility and correctness on long histories.
  - [ ] 8.3 Performance: confirm initial render and scrolling performance within targets.
  - [ ] 8.4 A11y pass: VO reads, Dynamic Type, contrast.


