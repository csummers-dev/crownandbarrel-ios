## Introduction / Overview

This PRD defines a comprehensive codebase cleanup and modernization initiative for the Crown & Barrel project. The objective is to improve readability, maintainability, performance, and quality across the entire repository while aligning with iOS 26 and modern SwiftUI practices. Architecture will follow a Hybrid approach: MVVM for most features with TCA (The Composable Architecture) applied to complex, state-heavy modules.

Target platform and references: iOS 26.0 with SwiftUI. See Apple’s platform updates for context: [About iOS 26 Updates](https://support.apple.com/en-in/123075).


## Goals

- Improve overall code readability and maintainability across the entire repo.
- Remove dead code, eliminate duplication, and enforce consistent naming.
- Add missing documentation (doc comments) and explanatory comments for complex logic.
- Normalize file/module structure and strengthen architectural boundaries.
- Adopt SwiftUI best practices and simplify overly complex views.
- Improve error handling consistency with clear user-facing/localized messages where applicable.
- Address performance risks (expensive layouts, unnecessary recomputation, blocking I/O on main thread).
- Tighten security and privacy handling (sensitive data, logging, permissions).
- Raise accessibility baseline (VoiceOver, Dynamic Type, contrast, labels).
- Enforce lint/style rules to keep quality high.


## User Stories

- As a developer, I want a consistent module structure so that I can navigate and modify code quickly without surprises.
- As a developer, I want comprehensive doc comments on public types and complex functions so that onboarding and maintenance are easier.
- As a developer, I want clear and centralized error handling so that failures are predictable and recoverable.
- As a developer, I want performance-sensitive views and reducers profiled and optimized so that UI stays responsive.
- As a QA engineer, I want predictable state management in complex features so that tests are reliable and flakiness is reduced.
- As a product owner, I want accessibility improvements so that the app meets a minimum bar of usability for all users.


## Functional Requirements

1. Repository Scope and Branching
   1.1. Create a new working branch off `main` (e.g., `cleanup/hybrid-architecture-ios26`).
   1.2. Apply changes across the entire repository, including `Sources/**`, `Tests/**`, and `docs/**`.

2. Architecture and Structure
   2.1. Adopt Hybrid architecture: MVVM for most features; TCA for complex, state-heavy modules (e.g., Stats, long-running side effects, multi-step flows).
   2.2. Introduce lightweight Dependency Injection (protocol-first, factory/initializer injection) at composition roots.
   2.3. Introduce targeted Coordinators only for multi-step navigation flows that exceed simple stack usage.
   2.4. Define and document module boundaries (Domain, Features, DesignSystem, Common, Persistence) and dependency directions.

3. Documentation and Comments
   3.1. Add `docs/style-guide.md` covering naming, file layout, doc comment conventions (`///`), and `MARK:` region usage.
   3.2. Ensure all public types and complex functions have concise doc comments explaining rationale and key invariants.
   3.3. Update existing `docs/**` where outdated; add cross-links to architecture and style guides.

4. Naming, Dead Code, and Duplication
   4.1. Remove dead/unused files, types, functions, and imports; add a removal log in PR description.
   4.2. Unify naming: types (PascalCase), methods/properties (camelCase), constants (lowerCamelCase with `static let`), enums (cases lowerCamelCase).
   4.3. Extract duplicated logic into shared utilities in `Common/` or domain-specific helpers.

5. SwiftUI Best Practices and View Simplification
   5.1. Break up very large views into focused subviews; avoid deep nesting.
   5.2. Prefer value-type state (`@State`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`) applied with clear ownership.
   5.3. Minimize side effects in view bodies; move effects to view models/reducers.
   5.4. Optimize lists/grids with stable IDs, on-demand loading, and memoization where appropriate.

6. State Management (TCA where applicable)
   6.1. For complex modules (e.g., Stats), introduce Reducers, Actions, State, and Effects; co-locate tests.
   6.2. Encapsulate side effects using dependency clients; ensure deterministic tests.
   6.3. Provide migration notes for any API changes impacting other features.

7. Error Handling and Logging
   7.1. Define a centralized error taxonomy and user-facing error surfaces.
   7.2. Ensure fallbacks and recovery actions exist for common failures; avoid silent catches.
   7.3. Sanitize logs to avoid leaking sensitive data; route logs through a single logging utility.

8. Performance
   8.1. Identify heavy computations and move off main thread; use async/await.
   8.2. Audit view rendering hot paths and reduce unnecessary recomposition (e.g., prefer `EquatableView`, memoized derived values).
   8.3. Add lightweight performance checks to CI (build-time metrics and simple smoke benchmarks where feasible).

9. Security and Privacy
   9.1. Audit storage of secrets and PII; ensure least-privilege access.
   9.2. Review Info.plist permissions strings and usage.
   9.3. Avoid logging secrets and tokens; scrub crash reports.

10. Accessibility and Localization
   10.1. Ensure Dynamic Type support and sufficient color contrast.
   10.2. Provide VoiceOver labels/hints for interactive controls.
   10.3. Enforce localization readiness: wrap user-facing strings with `NSLocalizedString` (or equivalent) and maintain `.strings` files.

11. Linting and Style
   11.1. Add/Update `SwiftLint` configuration with rules for naming, complexity, documentation, and unused code.
   11.2. Add format/lint scripts callable locally and in CI (non-blocking to start; see Technical Considerations for CI guidance).

12. Testing
   12.1. Define minimum coverage targets for critical modules and reducers.
   12.2. Add unit tests for reducers (TCA) and view models (MVVM) covering success/error paths.
   12.3. Stabilize flaky UI tests; prefer deterministic data and dependency injection.


## Non-Goals (Out of Scope)

- Major changes to the existing CI pipeline; keep current lanes and jobs largely intact.
- Large visual redesigns unrelated to code quality or iOS 26 conformance.
- Introducing third-party state libraries beyond TCA if not already in use.


## Design Considerations (Optional)

- Follow iOS 26 design directions and SwiftUI idioms; avoid UIKit fallbacks unless necessary.
- Keep `DesignSystem/` the single source of truth for typography, colors, and components.
- Use Coordinators only where navigation complexity warrants it; otherwise prefer `NavigationStack` and stack-driven flows.


## Technical Considerations (Optional)

- Target iOS 26.0 and ensure compatibility with contemporary Xcode toolchains; see [About iOS 26 Updates](https://support.apple.com/en-in/123075).
- DI: prefer initializer injection and protocol-based clients; avoid singletons except for immutable configuration.
- SwiftLint: provide a repo-level `.swiftlint.yml` with curated rules and exceptions; integrate as a non-blocking CI job initially.
- CI: minimal changes only (format/lint can run as optional checks); do not alter existing release/testflight lanes.
- Performance profiling: use Instruments and lightweight benchmarks during the cleanup PRs.


## Success Metrics

- Warnings reduced by X% (target to be finalized in the first milestone).
- Build time decreased by N% on CI runner baseline.
- Test coverage increased on critical modules (reducers, view models) to at least T%.
- Lint errors trend to near-zero with agreed rule set.
- Accessibility checks pass for key flows; no critical A11y blockers.


## Open Questions

1. Which specific modules should be prioritized for TCA beyond Stats (e.g., Watch detail flows, sync, import/export)?
2. Are there any PII or compliance constraints that require additional security hardening?
3. What are the exact targets for warnings reduction, build time, and coverage improvements?
4. Any platform-specific constraints (e.g., watchOS companions) that must be considered early?
