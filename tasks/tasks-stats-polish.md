## Stats Redesign – Polishing Follow-ups

### Visual & Interaction
- [ ] Fine-tune spacing/typography rhythm across modules (titles, section paddings)
- [ ] Align chart palettes with design tokens (dark/light tuned; ensure legibility)
- [ ] Add subtle animation on chart transitions and tab switches
- [ ] Increase tap targets on list rows/chips to 44pt minimum
- [ ] Add pull-to-refresh affordance hints where useful

### Filters UX
- [ ] Build filter sheet to pick brands/movements/complications/conditions (multi-select)
- [ ] Show active filter count badge on filter icon
- [ ] Add quick presets (e.g., “This Month”, “Last Quarter”)
- [ ] Persist per-tab presets (save/load named presets)
- [ ] Improve empty/filter-zero states copy and visuals

### Drill-ins
- [ ] Implement Brand Composition detail with full list + search
- [ ] Implement Watch Wear History detail (sparklines + table with jump-to-date)
- [ ] Add share-as-image for a single stat card (private-only, watermark)

### Finance Accuracy & UX
- [ ] Liquidity scenario: switch to top-N watches by estimated value/delta (not brand total)
- [ ] Portfolio view: add donut (value vs cost) and tooltips
- [ ] Spend by brand: add “Others” rollup above N entries
- [ ] Explicit disclaimers for estimates; link to valuation edit screen

### Wearing Analytics Depth
- [ ] Rotation balance: expose formula tip; allow toggling Gini vs entropy
- [ ] Neglect index: allow threshold tuning (e.g., show > X days)
- [ ] Streaks: add historical longest streaks panel
- [ ] Calendar: add month dividers + jump-to-month controls

### Fun Modules
- [ ] Rotation Health: tune scoring weights and copy suggestions
- [ ] Brand Bingo: optional 5×5 shuffle and free-center option
- [ ] Complication Radar: normalize labels; collapse near-duplicates
- [ ] Top Events: allow pinning an event to home of Fun
- [ ] Neglected Nudge: add “Remind me tomorrow/this weekend” actions

### Performance & Caching
- [ ] Precompute aggregates on app idle/launch for last 90D/YTD
- [ ] Add memory footprint guardrails for large datasets
- [ ] Cache busting: hook to repo writes more granularly (child tables)
- [ ] Off-main decoding where applicable; audit actors/Task usage

### Accessibility
- [ ] VoiceOver custom labels for all chart bars/marks (brand + value)
- [ ] Dynamic Type stress-test: ensure no truncation/wrapping issues
- [ ] High contrast mode pass; verify heatmap color ramps

### Internationalization
- [ ] Double-check date formats; respect user calendar/regional settings where safe
- [ ] Confirm USD labels are explicit; suppress locale currency switches intentionally

### QA & Tests
- [ ] Snapshot tests for charts/cards (where feasible, with stable providers)
- [ ] Unit tests for: rotation balance (Gini), neglect index, streaks, finance deltas
- [ ] Golden tests using `SampleData.makeWatches` for deterministic totals
- [ ] Performance budget doc: target cold/warm timings; add signpost marks to Wearing/Finance tabs

### Tech Debt / Cleanup
- [ ] Remove old `StatsView` reference points/components once parity confirmed
- [ ] Centralize number/date formatters for reuse and consistency
- [ ] Extract shared list row styles into design system components


