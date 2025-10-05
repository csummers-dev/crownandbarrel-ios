## Watch Object Redesign & Implementation Plan — PRD

### 1. Introduction / Overview

Redesign and implement watch objects with a structured, expandable schema that achieves clarity, modularity, and maintainability. This is a greenfield implementation (no legacy migration) that fully integrates with collection management. The application is offline-only and fully on-device.

Platform scope: iOS 26.0+ only.

### 2. Goals

- Establish a clear domain model for `watch` with well-defined child entities (photos, service_history, valuations, straps).
- Separate "Core" vs. "Additional Details" in the UI; Additional Details collapsed by default.
- Enforce consistent validation for numeric ranges and enums with an "Other" free-text fallback where applicable.
- Keep internal-only metadata (`id`, `created_at`, `updated_at`) hidden from users.
- Date fields are empty by default and only set via explicit user action.
- Photos are local-only, square, max 10 per watch; enforce square crop; generate 1000 px thumbnails; downscale originals to max 3000 px.
- Implement robust CRUD using SQLite with GRDB. Prioritize performance for list views and galleries.
- Provide basic accessibility (labels and traits). Use default iOS data protections.
- Support collection management: sort, filter, and performant thumbnails in lists.

### 3. User Stories

- As a user, I can create a new watch by entering core identity fields (manufacturer, model_name) and optionally add more details later.
- As a user, I can view and edit all watch attributes with Additional Details collapsed by default for readability.
- As a user, I can add up to 10 photos, crop to square, reorder them, set a primary photo, and delete photos.
- As a user, I can record service history, valuations, and straps as separate collections, each with its own default sorting.
- As a user, I can browse my watch list sorted by manufacturer > line > model_name and filter using common attributes (e.g., movement, water resistance, condition, tags).
- As a user, I expect date fields to remain empty unless I explicitly choose a date.
- As a user, I can use the app fully offline with my data stored on-device only.

### 4. Functional Requirements

FR-1 Schema & Validation
1. The system must define a `watch` entity with sub-objects: `case`, `dial`, `crystal`, `movement`, `water`, `strap_current`, `ownership` and child arrays: `service_history[]`, `valuations[]`, `straps[]`, `photos[]`.
2. The system must validate numeric and enum fields per the constraints below, and allow an "Other" free-text fallback for enum fields.
3. The canonical primary key for `watch` and child entities must be `UUID`.
4. The system must store `created_at` and `updated_at` timestamps for watches (hidden from users).

FR-2 Required Fields
1. On create, the required fields are `manufacturer` and `model_name`.
2. All other fields are optional unless otherwise stated in this PRD.

FR-3 UI Structure
1. Create/Edit screen must show core fields at the top: `manufacturer`, `line`, `model_name`, `reference_number`, `nickname`, and `photos`.
2. All other attributes must live within an "Additional Details" expandable section (collapsed by default).
3. Watch details pages must show all values (sections collapsed by default).
4. Array/collection fields must render as collapsible rows with an "Add New" control to append items.

FR-4 Photos
1. Storage: Photos must be stored locally in the app sandbox (FileManager).
2. Import pipeline: Pick → attempt PhotosUI square edit; if unavailable, present in-app square cropper → optional downscale → store → generate thumbnail(s) → persist references.
3. Square enforcement: The system must enforce square crops for saved photos.
4. Limits: Max 10 photos per watch. Show a counter (e.g., "7 / 10"); disable Add when at limit with an explanatory message.
5. Primary: Exactly one primary photo per watch; enforce via UI (reorder or explicit "Set as Primary").
6. Reorder: Long-press drag to reorder; first item becomes primary unless explicitly set otherwise.
7. Delete: Provide delete with confirmation.
8. Processing: Downscale very large images to max dimension of 3000 px; generate 1000 px thumbnails; cache decoded thumbnails for performance.
9. Privacy & Permissions: Request Photos permission only when needed; explain on-device, offline usage; store all data on-device.

FR-5 Collections (Child Arrays) Behavior
1. Service history default sort: date descending.
2. Valuations default sort: date descending.
3. Straps default sort: newest added first.
4. Each collection item renders as a collapsible row; support add, edit, and delete.

FR-6 List Views & Filters
1. Default watch list sort: manufacturer > line > model_name.
2. Initial filters include: manufacturer; line/collection; movement.type; water_resistance_m range; tags; condition; country_of_origin; purchase date range; has photos.
3. Use thumbnails in list cells for performance.

FR-7 Tags
1. Tags are free-text with auto-slugging to lowercase.
2. Users can choose from prior tags or create new ones.

FR-8 Date Handling
1. All date fields must be empty by default and only populated upon explicit user selection.
2. The UI must clearly display empty-state controls for dates and avoid auto-population.

FR-9 Accessibility & Security
1. Provide basic accessibility support (labels and traits) for all new UI.
2. Use default iOS data protections (no additional at-rest encryption layer required).

FR-10 Persistence & Domain Logic
1. Use SQLite with GRDB for all persistence.
2. Implement domain-level validation with UI guidance.
3. Greenfield only: Do not migrate legacy data into the new schema.

FR-11 Testing
1. Unit tests must cover models, validators, and the photo pipeline.
2. UI tests must cover adding, reordering, deleting photos, square-crop enforcement, and the max-limit behavior.
3. E2E tests must cover create → edit → details flows, including verification that date fields remain empty unless set.

### 5. Detailed Schema

Core Entity: `watch`
- id: UUID (auto-generated; hidden)
- manufacturer: string
- line: string
- model_name: string
- reference_number: string (allow slashes/dashes; e.g., "311.30.42.30.01.005")
- serial_number: string (allow duplicates)
- production_year: integer (4-digit, 1900–current year; allow empty)
- country_of_origin: string (ISO 3166 code or free-text)
- limited_edition_number: string (e.g., "123/500")
- nickname: string
- notes: text
- tags: string[] (lowercase, slugged)
- photos: photo[] (local-only, max 10, square)
- created_at: datetime (auto-set; hidden)
- updated_at: datetime (auto-set; hidden)

Case (`watch.case`)
- material: enum/string (steel, titanium, gold, ceramic, bronze, carbon, two-tone; allow Other)
- finish: enum/string (polished, brushed, mixed, bead-blasted; allow Other)
- shape: enum/string (round, cushion, tonneau, rectangular, square, oval; allow Other)
- diameter_mm: number (16–60; 1 decimal)
- thickness_mm: number (0–25; 1 decimal)
- lug_to_lug_mm: number (0–70; 1 decimal)
- lug_width_mm: number (6–30; integer preferred)
- bezel.type: enum/string (fixed, dive (uni), bi-directional, GMT, tachymeter; allow Other)
- bezel.material: enum/string (steel, ceramic, aluminum, sapphire, gold; allow Other)
- caseback.type: enum/string (solid, exhibition, engraved; allow Other)
- caseback.material: enum/string (steel, titanium, sapphire, gold; allow Other)

Dial & Hands (`watch.dial`)
- color: string (hex, named, or common term, e.g., "sunburst blue")
- finish: enum/string (sunburst, matte, enamel, lacquer, fumé, guilloché; allow Other)
- indices.style: enum/string (applied, painted, Roman, Arabic, baton, mixed; allow Other)
- indices.material: enum/string (metal, lume, ceramic; allow Other)
- hands.style: enum/string (dauphine, baton, sword, Mercedes, cathedral; allow Other)
- hands.material: enum/string (steel, gold, blued steel, lume; allow Other)
- lume.type: enum/string (none, Super-LumiNova (C3/BGW9/etc.), tritium; allow Other)
- complications: string[] (e.g., date, day, month, moonphase, chronograph, GMT, power reserve, small seconds, annual/perpetual calendar, world time, alarm, regatta)

Crystal (`watch.crystal`)
- material: enum/string (sapphire, mineral, acrylic/hesalite; allow Other)
- shape_profile: enum/string (flat, domed, double-domed, boxed; allow Other)
- ar_coating: enum/string (none, inside, both sides; allow Other)

Movement (`watch.movement`)
- type: enum (automatic, manual, quartz, solar, spring_drive, mechaquartz, kinetic, tuning_fork, smart/hybrid)
- caliber: string (e.g., "Omega 1861", "ETA 2824-2")
- power_reserve_hours: number (0–2000)
- frequency_vph: integer (e.g., 21600, 28800; allow 0 for quartz)
- jewel_count: integer (0–60)
- accuracy_spec_ppd: number (seconds/day, +/-)
- chronometer_cert: enum/string (none, COSC, METAS/Master Chronometer, JIS, in-house; allow Other)

Water & Crown (`watch.water`)
- water_resistance_m: integer (0, 30, 50, 100, 200, 300, 600, 1000…)
- crown.type: enum/string (push/pull, screw-down, locking system; allow Other)
- crown.guard: boolean

Strap / Bracelet (Current Fit) (`watch.strap_current`)
- type: enum/string (bracelet, leather, rubber, silicone, fabric/NATO, FKM, integrated; allow Other)
- material: enum/string (steel, titanium, gold, leather (calf/alligator), rubber, nylon; allow Other)
- color: string
- end_links: enum/string (solid, hollow, fitted, straight, integrated; allow Other)
- clasp.type: enum/string (pin buckle, deployant, folding, butterfly, micro-adjust; allow Other)
- bracelet.link_count: integer
- quick_release: boolean

Ownership & Provenance (`watch.ownership`)
- date_acquired: date (empty by default)
- purchased_from: string (dealer, boutique, AD, private, auction, marketplace name)
- purchase_price.amount: number (≥ 0)
- purchase_price.currency: string (ISO 4217, e.g., USD, EUR)
- condition: enum/string (new, unworn, excellent, very good, good, fair, poor; allow Other)
- box_papers: enum/string (full set, watch only, partial, box only, papers only; allow Other)
- current_estimated_value.amount: number
- current_estimated_value.currency: string
- insurance.provider: string
- insurance.policy_number: string
- insurance.renewal_date: date (empty by default)

Photo (`photo`)
- id: UUID
- local_identifier: string (local file URL or app-managed identifier)
- is_primary: boolean (exactly one true per watch)

Service History (`service_history[]`)
- id: UUID
- date: date (empty by default)
- provider: string (brand service center / watchmaker)
- work_description: text
- cost.amount: number
- cost.currency: string
- warranty_until: date (empty by default)

Valuations (`valuations[]`)
- id: UUID
- date: date (empty by default)
- source: enum/string (insurer, appraisal, market est., auction comp; allow Other)
- value.amount: number
- value.currency: string

Straps Inventory (`straps[]`)
- id: UUID
- type: enum/string (bracelet, leather, rubber, NATO, integrated; allow Other)
- material: enum/string
- color: string
- width_mm: integer (match lug width)
- clasp.type: enum/string
- quick_release: boolean

### 6. Non-Goals (Out of Scope)

- No cloud sync or remote services; offline-only, on-device.
- No migration of legacy data; greenfield only.
- No schema versioning in this phase.
- No advanced accessibility beyond basic labels/traits.
- No encrypted DB layer beyond default iOS data protections.

### 7. Design Considerations (UI/UX)

- Offline-first UX with clear separation of core vs. additional details; Additional Details collapsed by default.
- Photos: primary photo near the top of the create/edit screen; details page has a horizontally swipeable gallery with pagination dots and a full-screen viewer.
- Reorder photos via long-press drag; provide "Set as Primary" action.
- Disable Add Photo at 10 and explain why; show counter.
- Array sections (service history, valuations, straps) are collapsible; each item row also collapsible for dense but readable screens.
- Form validation should guide without blocking free-text "Other" inputs where allowed.

### 8. Technical Considerations

- Architecture: Offline-first; domain logic validates inputs, UI provides guidance.
- Persistence: SQLite + GRDB. Prefer WAL mode. Add indexes for common filters/sorts (manufacturer, line, movement.type, water_resistance_m, condition, tags presence, updated_at).
- Data Modeling: Nullable date fields; store ISO-8601 timestamps for created/updated. Maintain referential integrity for child rows (FK on delete cascade where appropriate).
- Photos: Store originals in sandbox; downscale to 3000 px max dimension; generate 1000 px thumbnails. Consider NSCache for thumbnail caching. Use unique file naming (UUID-based) and per-watch subdirectories.
- Image Pipeline: Attempt PhotosUI square editor; fallback to in-app square cropper before saving. Lazy-load full-size images; load thumbnails for lists.
- Security & Privacy: Default iOS protections (NSFileProtection defaults). Request Photos permission only when needed with clear rationale.
- Performance: Cache frequently accessed data; use lazy loading for images. Target P95 list screen load < 300 ms using thumbnails.
- Accessibility: Basic VoiceOver labels/traits and Dynamic Type where trivial; deeper work deferred.
- Testing: Unit (models, validators, photo pipeline), UI (photos CRUD, square enforcement, limit), E2E (create/edit/details with date behavior).

### 9. Success Metrics

- 0 crashes from photo pipeline within 7 days of usage.
- 100% of date fields remain empty unless explicitly set (sample audit passes).
- P95 watch list screen load < 300 ms with thumbnails.
- Users can complete create → edit → details without validation blockers.

### 10. Open Questions

1. Enumerations: Finalize the exact enum lists shown in pickers (current lists are examples); confirm any brand-specific additions.
2. Thumbnail variants: Is a single 1000 px thumbnail sufficient for both grid and list, or do we also want a smaller (e.g., 400 px) micro-thumbnail for compact lists?
3. Primary photo behavior: When reordering, should the first item always become primary, or should primary be independent of order once explicitly set?
4. Tag management: Should we surface tag suggestions aggressively (typeahead) or limit to a small, recently-used set?
5. Any constraints for storage quotas we should respect (e.g., cap per-user media storage)?


