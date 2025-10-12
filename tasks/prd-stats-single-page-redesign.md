## Single-Page Stats Redesign PRD

### 1. Introduction / Overview
Redesign the Stats experience into a single, long, scrollable page that presents all core statistics in visible sections (Collection, Wearing, Finance, Fun). Remove all global/local filters and remove drill-ins. Each statistic selects its own appropriate time basis (e.g., all-time totals, per-year charts) so the page conveys a comprehensive overview without interaction.

### 2. Goals
- Present a complete, at-a-glance overview of the collection and usage in one continuous page.
- Eliminate navigation and filters; reduce user effort to zero for discovery.
- Maintain a visual style closely aligned to the Collection entry views (cards, spacing, typography).
- Preserve performance and smooth scrolling even for large datasets.

### 3. User Stories
- As a collector, I want to scroll one page to see all relevant stats (no filters, no drill-ins).
- As an enthusiast, I want wearing frequency, streaks, and neglected pieces visible without taps.
- As an owner, I want financial totals and historical spend visible immediately.
- As a planner, I want composition and distributions visible to inform future acquisitions.

### 4. Functional Requirements
1) Page Structure (Single View)
   - FR-1.1: Replace tab-based Stats with a single `StatsSingleView` using a vertical `ScrollView`.
   - FR-1.2: Title area at top; no filter bar, no chips, no date-range controls.
   - FR-1.3: Sections rendered in order: Collection, Wearing, Finance, Fun.
   - FR-1.4: No drill-ins; all stats are visible in-line.

2) Time Bases (No Filters)
   - FR-2.1: Totals: use all-time (e.g., total purchase, total estimated value, unique brands).
   - FR-2.2: Historical charts: use all-time by default, grouped per-month/per-year as appropriate and bounded by available data.
   - FR-2.3: Wearing analytics: compute based on all recorded wear entries (calendar heatmap: per-day across all years with condensed visualization).

3) Collection Section (All visible in-line)
   - FR-3.1: Summary cards: total watches, unique brands, total purchase (USD), total estimated value (USD).
   - FR-3.2: Composition charts: brand, movement type, complications, case materials (Top-N with “Others” rollup to keep charts legible).
   - FR-3.3: Distributions: case diameter, thickness, lug-to-lug, water resistance (reasonable binning).
   - FR-3.4: Acquisition timeline: count and spend per month/year (all-time series).
   - FR-3.5: Service overview: last service and any upcoming warranty deadlines (per watch list, condensed).
   - FR-3.6: Box/Papers summary: counts by category.

4) Wearing Section (All visible in-line)
   - FR-4.1: Most/least worn (by unique days) lists (Top-N; ties broken by last worn date).
   - FR-4.2: Rotation balance score (Gini or chosen formula) with brief explanation.
   - FR-4.3: Neglect index list: watches with zero days worn in recent periods (e.g., last 90 days), including days since last wear.
   - FR-4.4: Streaks: current daily streak, brand streaks, and no-repeat streak.
   - FR-4.5: Calendar heatmap: full-history compressed day grid (per-year bands; all years included; ensure legible aggregation).
   - FR-4.6: Weekday vs weekend bar chart.

5) Finance Section (All visible in-line)
   - FR-5.1: Portfolio vs cost basis: totals, delta, and percentage (USD only).
   - FR-5.2: Spend by year and by brand (Top-N with “Others”).
   - FR-5.3: Liquidity scenario: top 3 watches by estimated value (with total proceeds) – visible in-line with disclaimer.

6) Fun Section (All visible in-line)
   - FR-6.1: Rotation Health card with brief suggestions (e.g., wear neglected items soon).
   - FR-6.2: Brand Bingo 5×5 (deduplicated brands; fill blanks as needed).
   - FR-6.3: Complication radar chart (deduplicated/normalized labels).
   - FR-6.4: Top 5 events (e.g., most-worn month, first wear, newest brand, highest value).
   - FR-6.5: Neglected Nudge (upcoming suggested dates for neglected pieces).
   - FR-6.6: Achievements strip (cards) – visible list (no toggle).

7) Visual Style
   - FR-7.1: Adopt the Collection entry view’s card style (padding, corner radius, hierarchical text).
   - FR-7.2: Ensure consistent spacing rhythm across sections (headlines, subtitles, content blocks).
   - FR-7.3: Keep the luxury/editorial aesthetic (colors/typography consistent with the app).

8) Accessibility
   - FR-8.1: VoiceOver labels/values on summaries and chart elements (brand + value, date + count).
   - FR-8.2: Dynamic Type support without truncation of key data.
   - FR-8.3: Contrast ratios meet guidelines.

### 5. Non-Goals (Out of Scope)
- Filters or date-range controls (global or local).
- Drill-in flows / detail pages.
- Excluding any of the current sections or metrics.

### 6. Design Considerations
- One continuous scroll page with sections: Collection, Wearing, Finance, Fun.
- Use Top-N + “Others” for dense charts to maintain readability.
- Calendar heatmap must remain legible across multi-year histories; consider grouping years into rows (year label + condensed grid) and small multiples.
- Provide a compact “Jump to section” index (top sticky bar or first screen anchors) if needed for navigation ergonomics while keeping all content on the page.

### 7. Technical Considerations
- Data aggregation
  - Reuse existing aggregations; compute once per view-appearance.
  - Precompute common aggregates (all-time per-day, per-month, per-year; tallies; finance totals) in background to avoid blocking first paint.
  - Use caching keyed only by “all-time” since there are no filters.
- Rendering
  - Render in section order and show skeleton placeholders until data is ready (progressive rendering).
  - Ensure smooth scrolling by bounding heavy lists (e.g., show Top-N and allow “Show more” expansion inline if necessary, still in-page).
- Performance targets (initial; refine in UAT)
  - Initial render < 500ms from cached aggregates on a large dataset.
  - Smooth 60fps scrolling on a long page.
  - Background precompute finalized within a few seconds on cold start for large datasets.
- Architecture
  - Implement `StatsSingleView` with subviews for each section; reuse existing section components by removing tab containers.
  - Remove tab-based Stats container after migration.

### 8. Success Metrics
- The single-page Stats renders successfully and matches expected totals on representative sample data.
- Users report improved comprehension (informal testing) without needing interaction.
- Scrolling and loading performance meets targets for large datasets.

### 9. Open Questions
- Performance constraints: do we need an explicit budget (e.g., initial paint < 300ms)?
- Calendar heatmap length: if history exceeds N years, should we auto-collapse older years by default (still visible inline, just minimized)?
- Liquidity scenario heuristics: strictly top estimated value or include delta-over-cost logic?


