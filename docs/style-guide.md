## Purpose

This document defines Crown & Barrel's coding conventions and architectural guidelines for Swift/SwiftUI on iOS 26. It aims to maximize readability, maintainability, performance, and consistency across the entire codebase.

See platform context: [About iOS 26 Updates](https://support.apple.com/en-in/123075).


## Target Platform

- iOS 26.0
- Swift and SwiftUI-first; avoid UIKit unless necessary.
- Prefer modern concurrency (async/await) and value semantics.


## Naming Conventions

- Types, protocols: PascalCase (e.g., `WatchDetailView`, `StatsAggregator`)
- Methods, properties, variables: camelCase (e.g., `fetchWatches`, `isSelected`)
- Enums: PascalCase type, lowerCamelCase cases
- Constants: `static let` with camelCase
- Avoid abbreviations; prefer descriptive names (clarity over brevity)
- Acronyms as words (e.g., `Url` -> `URL`, `Id` -> `ID` in type names)


## File and Module Organization

- Top-level directories: `Domain/`, `Features/`, `DesignSystem/`, `Common/`, `PersistenceV2/`, `Tests/`, `docs/`.
- One primary type per file where possible; name the file after the primary type.
- Keep dependency directions clean:
  - `DesignSystem` has no feature dependencies
  - `Common` is foundational utilities; no feature dependencies
  - `Domain` has core models/use-cases; avoid depending on features
  - `Features` depend on Domain, Common, and DesignSystem
  - `PersistenceV2` depends on Domain/Common; avoid feature dependencies


## Documentation & Comments

- Use `///` for doc comments on all public types/APIs and complex helpers.
- Explain non-obvious rationale, invariants, and edge cases. Avoid obvious comments.
- Organize large files with `// MARK: -` sections; prefer logical grouping over long files.


## SwiftUI Guidelines

- Keep view bodies simple; derive computed values outside the body when possible.
- Avoid heavy work in `body`. Use view models or reducers for side effects and async work.
- Prefer `NavigationStack`; minimize ad-hoc navigation state scattered across views.
- Use stable IDs for lists and avoid unnecessary `onAppear` work per row.
- Extract subviews to reduce nesting; use input models that isolate rendering data.
- Prefer small, composable modifiers/functions over large conditional trees.
- Respect environment values (Dynamic Type, color scheme, accessibility sizes).


## MVVM (Default for most features)

- View: declarative UI; no business logic; forwards user intents.
- ViewModel: state, derived state, orchestration of use cases; minimal side effects.
- Model: domain entities and value types.
- Inject dependencies via initializers (protocol-based). Avoid singletons.
- Keep view models testable (no direct global state, deterministic behavior).


## TCA (For complex, state-heavy modules)

- Use Reducer/State/Action/Effect structure for modules with complex flows, deep navigation, or many effects (e.g., Stats).
- Co-locate tests with reducers; cover success, failure, and cancellation paths.
- Model dependencies as clients; pass via DependencyValues or initializer injection.
- Prefer small, composable reducers over large monoliths; use `.combined`/composition.


## Dependency Injection

- Use protocols for external services and data sources.
- Provide concrete implementations at composition roots.
- Favor initializer injection; avoid service locators and hidden globals.


## Error Handling & Logging

- Define an error taxonomy (domain, network, persistence, decoding, unknown).
- Propagate typed errors; avoid `catch {}` without handling.
- Show user-friendly messages via a centralized surface; localize strings.
- Route logs through a single logger; never log secrets or PII.


## Performance

- Move expensive work off the main thread using async/await.
- Be mindful of view invalidations; use memoized derived values and `Equatable` views when suitable.
- Avoid synchronous disk/network access on the main thread.
- Profile with Instruments for hot paths before micro-optimizing.


## Accessibility

- Support Dynamic Type and large content sizes.
- Provide VoiceOver labels and traits for interactive elements.
- Maintain sufficient contrast and hit targets.


## Localization

- Wrap user-facing strings with `NSLocalizedString` (or a typed wrapper).
- Keep `.strings` files organized; avoid string duplication.
- Include localization notes for ambiguous phrases.


## Testing

- Unit test view models and reducers. Cover error paths and edge cases.
- Prefer deterministic tests using injected dependencies and fakes.
- Keep flaky UI tests minimal; stabilize critical user journeys.


## Pull Requests

- Keep edits focused and incremental; include a brief rationale and screenshots for UI changes.
- Reference related PRD/tasks; list breaking changes and migration notes.
- Ensure lint and format checks pass locally before pushing.
