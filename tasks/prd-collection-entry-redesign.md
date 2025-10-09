# Product Requirements Document: Collection Entry Visual Redesign

## Introduction/Overview

The collection view entries (both grid and list views) currently display watch entries with inconsistent sizing, spacing, alignment, and colors. This leads to a visually fragmented user experience where entries look different from one another based on their content. This PRD defines a redesign that creates a uniform, clean, and visually appealing presentation for all collection entries, regardless of the data they contain.

**Problem:** Collection entries lack visual consistency in size, spacing, alignment, and colors, resulting in a disjointed user experience.

**Goal:** Create a unified visual design for collection entries that is clean, simple, visually appealing, and consistent with the application's existing design principles and styles.

## Goals

1. Achieve visual consistency across all collection entries regardless of content (name, model, nickname, or other values)
2. Implement a clean, simple design that aligns with the app's overall design principles
3. Ensure consistent sizing for all grid items (fixed square dimensions, two items horizontally)
4. Apply single-line text display with ellipses for all text fields in both grid and list views
5. Maintain uniform font colors across grid and list views
6. Create clear visual hierarchy for displayed information (manufacturer, model, nickname)

## User Stories

1. **As a collector**, I want all my watch entries to have the same size and layout so that my collection looks organized and professional.

2. **As a user browsing my collection**, I want to see manufacturer, model, and nickname information clearly displayed with visual hierarchy so I can quickly identify each watch.

3. **As a user with watches that have long names**, I want text to be truncated with ellipses so that the grid layout remains consistent and doesn't break.

4. **As a user switching between grid and list views**, I want the same visual styling and font colors in both views so the experience feels cohesive.

5. **As a user with watches that may or may not have nicknames**, I want optional fields to display gracefully without breaking the layout.

## Functional Requirements

### Grid View Requirements

1. All grid items **must** be fixed square dimensions
2. Grid layout **must** display exactly two items horizontally
3. Each grid item **must** display an image for the watch entry
4. Each grid item **must** display text fields in the following order: manufacturer (first), model (second), nickname (third)
5. Text fields **must** implement visual hierarchy:
   - Manufacturer: Large font size
   - Model: Medium font size
   - Nickname: Small font size
6. All text fields **must** be limited to a single line with ellipses (`...`) if the text exceeds the available space
7. Grid items **must** have no borders or shadows (flat design)
8. All grid items **must** maintain consistent spacing and alignment regardless of content
9. Font colors **must** be consistent across all grid items
10. If a watch entry is missing the optional nickname field, the space should remain empty but not break the layout

### List View Requirements

11. List view **must** use the exact same font colors as grid view
12. List view **must** apply the same single-line text truncation rule with ellipses
13. All list items **must** be the same height/size
14. List view **must** display the same visual hierarchy (manufacturer large, model medium, nickname small)
15. List view **must** display an image for each watch entry
16. List view **must** maintain consistent spacing and alignment

### Data Requirements

17. Manufacturer field is **required** and must always display
18. Model field is **required** and must always display
19. Nickname field is **optional** - display only if it exists, otherwise show empty space
20. If optional fields are missing, only show the fields that exist without breaking layout consistency

### Design Consistency Requirements

21. The redesigned entries **must** maintain visual consistency with the application's existing design principles and styles
22. Typography choices **must** align with the app's existing typography system
23. Color choices **must** align with the app's existing color palette
24. Spacing and padding **must** follow the app's existing spacing guidelines

## Non-Goals (Out of Scope)

1. Adding hover/tap functionality to reveal full text of truncated fields (truncated display is sufficient for now)
2. Implementing specific accessibility features beyond standard text display (no accessibility considerations for this iteration)
3. Performance optimizations for text truncation (no specific performance considerations needed)
4. Adding new data fields beyond manufacturer, model, and nickname
5. Adding interactive elements (buttons, actions) to grid/list items
6. Implementing custom animations or transitions
7. Creating design mockups or prototypes as part of this feature

## Design Considerations

### Layout Structure

- **Grid View:** Fixed square items, 2 columns, equal spacing between items
- **List View:** Full-width items, equal height, stacked vertically
- **Image Placement:** Image should be prominently displayed within each entry
- **Text Layout:** Text fields should be stacked vertically in order (manufacturer, model, nickname)

### Typography Hierarchy

- **Manufacturer:** Large, bold/prominent
- **Model:** Medium, regular weight
- **Nickname:** Small, possibly lighter weight or secondary color

### Text Truncation

- Use native SwiftUI text truncation (`.lineLimit(1)` with `.truncationMode(.tail)`)
- Ensure ellipses appear at the end of truncated text
- Apply to all text fields consistently

### Color Consistency

- Establish a single color scheme for text that works in both light and dark modes
- Font colors should remain consistent between grid and list views
- Consider using semantic colors from the app's design system

### Spacing and Alignment

- All text should be left-aligned (or follow app convention)
- Consistent padding/margins within each grid/list item
- Equal spacing between text fields within an item

## Technical Considerations

1. **Component Reuse:** Consider creating a shared component for entry display that can be used in both grid and list views to ensure consistency
2. **SwiftUI Views:** Use SwiftUI's built-in layout tools (LazyVGrid, List) for grid and list implementations
3. **Text Truncation:** Use `.lineLimit(1)` and `.truncationMode(.tail)` modifiers
4. **Fixed Sizing:** Use `.frame(width:height:)` modifiers to enforce fixed square dimensions in grid view
5. **Image Handling:** Ensure image aspect ratio and sizing is handled consistently
6. **Theme Integration:** Integrate with the existing theme system for colors and typography
7. **Data Binding:** Ensure the component properly handles optional fields (nickname) without breaking layout

## Success Metrics

1. **Visual Consistency:** 100% of collection entries display with uniform sizing, spacing, and alignment
2. **Text Truncation:** All text fields properly truncate with ellipses when content exceeds one line
3. **Layout Stability:** No layout breaking or inconsistent sizing regardless of data content
4. **Design System Alignment:** Redesigned entries visually align with app's existing design principles (validated through design review)
5. **View Parity:** Grid and list views maintain identical font colors and text truncation behavior

## Open Questions

1. What specific font sizes (in points or using system font styles like .title, .body, .caption) should be used for manufacturer, model, and nickname?
2. Should the image be displayed at the top, left side, or as a background of each entry?
3. What should be the exact dimensions (in points) for the square grid items?
4. Should there be any minimum spacing between grid items, and if so, what value?
5. Are there specific color values or semantic color names from the design system that should be used for text?
6. Should the entries support dark mode with different colors, or use the same colors in both modes?
7. How should the image be sized/cropped if it doesn't fit the designated space?

