## UAT Checklist - Stats Redesign

Use this checklist to verify each requirement on-device with representative data. Record pass/fail and notes.

### Global
- [ ] Filters/ranges apply across tabs (Collection/Wearing/Finance/Fun)
- [ ] Dark/Light theme styling consistent with design system
- [ ] Back navigation and drill-ins behave as expected

### Collection
- [ ] Summary shows counts and USD totals that match manual calculations
- [ ] Composition charts reflect brands/movements/complications present
- [ ] Distributions (diameter/thickness/L2L/WR) match watch specs
- [ ] Acquisition timeline counts/spend by month correct
- [ ] Service overview lists last service and any warranty dates
- [ ] Box/Papers summary matches ownership records

### Wearing
- [ ] Most/least worn lists match unique-day counts in range
- [ ] Rotation balance score adjusts when wearing patterns change
- [ ] Neglect index flags unworn-in-range watches correctly
- [ ] Streaks (daily/no-repeat/brand) update day-to-day
- [ ] Calendar heatmap matches by-day wear counts; multi-watch days indicated
- [ ] Weekday vs weekend totals reflect expected distribution

### Finance
- [ ] Spend by year/brand uses ownership.dateAcquired and purchase amounts
- [ ] Portfolio vs cost basis delta and percent correct
- [ ] Liquidity scenario (top 3) sums correctly and labels clearly

### Fun
- [ ] Heatmap recap cards match range-specific heatmaps
- [ ] Rotation health score + suggestions update as wear changes
- [ ] Brand bingo grid populated from current manufacturers
- [ ] Complication radar shows counts and scales correctly
- [ ] Top 5 events populate (streaks, most-worn month, first wear, newest brand, highest value)
- [ ] Neglected Nudge suggests future dates for neglected watches
- [ ] Achievements section displays cards with states

### Accessibility
- [ ] VoiceOver reads summary, charts, heatmap cells, and lists clearly
- [ ] Dynamic Type does not truncate critical content
- [ ] Contrast is sufficient in all modules

### Performance
- [ ] Initial Stats load feels responsive on realistic dataset
- [ ] Subsequent range/filter changes are near-instant
- [ ] No hitches when scrolling modules


