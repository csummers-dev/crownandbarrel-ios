## Architecture Overview (Hybrid MVVM + TCA)

This document outlines the high-level architecture and module boundaries for Crown & Barrel, targeting iOS 26 with SwiftUI.

Reference: [About iOS 26 Updates](https://support.apple.com/en-in/123075)


## Principles
- Prefer simple solutions first (MVVM), escalate complexity only when justified.
- Keep side effects explicit and testable.
- Maintain clear module boundaries and dependency directions.
- Favor value semantics and modern concurrency (async/await).


## Modules and Dependencies
- `DesignSystem/`: Typography, colors, components. No dependencies on app features.
- `Common/`: Cross-cutting utilities (logging, error types, helpers). No feature dependencies.
- `Domain/`: Core models and use cases; minimal dependencies on `Common`.
- `PersistenceV2/`: Storage/clients; depends on `Domain` and `Common`.
- `Features/`: Screens and flows; depends on `Domain`, `Common`, and `DesignSystem`.
- `Tests/`: Unit/UI tests; may include fakes/mocks per module.

Dependency direction: DesignSystem/Common <- Domain <- PersistenceV2 <- Features (Features do not depend on other features directly when avoidable; prefer protocol boundaries).


## MVVM (Default)
- Views are declarative renderers with minimal logic.
- ViewModels own state, orchestrate use cases, and expose derived state.
- Inject dependencies via initializers (protocol-based).


## TCA (Complex Modules)
Use TCA for state-heavy flows such as Stats or multi-step navigation with side effects.
- Structure: `State`, `Action`, `Reducer`, `Effect`.
- Dependencies: model as clients and provide via dependency injection.
- Testing: co-locate reducer tests; verify effect timing, cancellations, and error paths.


## Navigation
- Prefer `NavigationStack` for simple flows.
- Use lightweight Coordinators only for multi-step or cross-feature flows.


## Error Handling
- Central error taxonomy in `Common/` (e.g., `AppError`).
- Map to user-facing messages via a single surface; localize strings.


## Performance & A11y
- Avoid blocking work on main; profile hot paths.
- Respect Dynamic Type, VoiceOver, and contrast; ensure accessible labels.


## Composition Roots
- Root setup wires concrete implementations to protocol-based dependencies.
- Keep global state minimal; avoid singletons unless immutable.


## Migration Notes
- New complex features should consider TCA; existing simple features remain MVVM.
- Provide migration notes in PRs when changing public interfaces.
