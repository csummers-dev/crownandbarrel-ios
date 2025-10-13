## Milestone 1: Codebase Cleanup Foundations

Scope: Establish baseline standards, docs, and low-risk cleanups across the repo. No CI changes beyond optional linting. Branch off `main`.

### Objectives
- Standards and documentation in place
- Gentle linting baseline
- Identify and remove obvious dead code
- Normalize naming in top-level modules
- Prepare Stats module for TCA migration

### Tasks
1) Branching and Setup
- Create `cleanup/hybrid-architecture-ios26` from `main`.
- Ensure Xcode project builds on iOS 26 toolchain.

2) Documentation
- Verify `docs/style-guide.md` is complete; add examples as needed.
- Add `docs/architecture-overview.md` explaining Hybrid MVVM+TCA boundaries and module dependencies.

3) Linting & Formatting
- Adopt `.swiftlint.yml` baseline; run locally and fix obvious issues (unused imports, unused declarations).
- Add non-blocking lint job in CI (optional): do not modify release/testflight lanes.

4) Dead Code & Duplication
- Search for unused files/types/methods in `Sources/**`; remove and note in PR.
- Extract duplicated helpers into `Common/` with focused names and tests.

5) Naming Consistency
- Unify type and file names where mismatched; fix imports and references.
- Normalize enum case naming and constant patterns.

6) SwiftUI Best Practices
- Split large views into smaller subviews (top 3 offenders by line count/complexity).
- Remove side effects from view bodies; move to view models.

7) Error Handling
- Introduce an `AppError` taxonomy in `Common/` and migrate 2–3 key call sites.
- Centralize user-facing error mapping (localized strings).

8) Accessibility & Localization
- Ensure Dynamic Type compliance on top navigation flows.
- Add missing VoiceOver labels in primary views.
- Wrap obvious user-facing strings with localization helpers.

9) TCA Preparation for Stats
- Create `Features/Stats/Store/` with `State`, `Action`, `Reducer` skeleton and tests.
- Identify dependencies and define clients (protocols) for data sources.

10) Testing
- Add unit tests for new utilities and initial reducer scaffolding.
- Stabilize 1 flaky UI test if easily addressable.

### Deliverables
- PR: "M1 – Cleanup Foundations (Hybrid MVVM+TCA, iOS 26)"
- Change log summarizing removals, renames, and structure changes
- Passing builds; lint warnings reduced; tests green

### Out of Scope
- Full TCA migration of Stats (planned M2)
- Major refactors that would break public APIs without migration notes
