## Relevant Files

- `Sources/Domain/Models/Watch.swift` - Current domain model; reference for migrating to new schema.
- `Sources/Persistence/CoreDataStack.swift` - Existing Core Data stack to be replaced/deprecated in favor of SQLite + GRDB.
- `Sources/Persistence/Mappers.swift` - Illustrates mapping patterns to persistence; will inform GRDB record <-> domain mapping.
- `Sources/Persistence/WatchRepositoryCoreData.swift` - Current repository; guides repository interface while replacing backend.
- `Sources/Common/Utilities/ImageStore.swift` - On-disk image handling; extend/replace for multi-photo, thumbnails, and square crop.
- `Sources/CrownAndBarrelApp/CrownAndBarrelApp.swift` - App entry; integration points for dependency wiring (DB, repositories).
- `Sources/Features` - Forms, list views, and details screens; targets for UI implementation (create/edit/details, filters, galleries).
- `Tests/Unit` - Add model/validator/photo pipeline unit tests.
- `Tests/UITests` - Add UI tests for photos CRUD, crop enforcement, max limit, and flows.

### Notes

- Use SQLite + GRDB with WAL mode; define records and migrations explicitly. Keep domain models separate from record structs.
- Store images in the app sandbox under a per-watch folder; generate 1000 px thumbnails and downscale originals to 3000 px max.
- Enforce one primary photo per watch via UI and repository invariants.
- All date fields remain nil until explicitly set by the user.
- Basic accessibility (labels/traits); default iOS data protections only.

## Tasks

- [ ] 1.0 Define domain models and validation rules for watch and child entities
  - [x] 1.1 Define `Watch` with metadata and core fields (id UUID, manufacturer, line, model_name, reference_number, nickname, created_at, updated_at)
  - [x] 1.2 Define nested value types: `WatchCase`, `WatchDial`, `WatchCrystal`, `WatchMovement`, `WatchWater`, `WatchStrapCurrent`, `WatchOwnership`
  - [x] 1.3 Define child array models: `WatchPhoto`, `ServiceHistoryEntry`, `ValuationEntry`, `StrapInventoryItem`
  - [x] 1.4 Add enums with "Other" fallback where applicable; expose `.other(String)` cases or separate free-text field
  - [x] 1.5 Implement validators for numeric ranges and formats (diameter/thickness/lug sizes; year 1900–current; vph/jewel counts; currency >= 0)
  - [x] 1.6 Implement tag slugging (lowercase, hyphenated) and uniqueness per watch
  - [x] 1.7 Add invariants: exactly one `is_primary` photo per watch; enforce at domain layer
  - [x] 1.8 Ensure all date fields default to nil and only set via explicit assignment

- [ ] 2.0 Implement SQLite + GRDB schema, migrations, and repositories
  - [x] 2.1 Add GRDB dependency and database bootstrap (file path, WAL mode, busy timeout)
  - [x] 2.2 Design tables: `watches`, `watch_photos`, `service_history`, `valuations`, `straps_inventory` with FKs and ON DELETE CASCADE
  - [x] 2.3 Add indices for sorting/filtering: manufacturer, line, model_name, movement_type, water_resistance_m, condition, updated_at, has_photos flag
  - [x] 2.4 Write initial migration (v1) to create schema; include reversible down where practical
  - [x] 2.5 Implement GRDB Records and mappers between Records and domain models
  - [x] 2.6 Implement repositories: `WatchRepository`, `PhotoRepository`, `ServiceHistoryRepository`, `ValuationRepository`, `StrapRepository`
  - [x] 2.7 Implement CRUD operations, batch inserts/updates for children, and transactional save of a full watch aggregate
  - [x] 2.8 Implement query methods for list default sort and all specified filters
  - [x] 2.9 Provide migration launcher and integrity checks (FKs, unique constraints as required)

- [ ] 3.0 Build local photo pipeline (import, square crop, downscale, thumbnails, reorder, primary)
  - [x] 3.1 Implement per-watch directory structure and file naming (UUID-based)
  - [x] 3.2 Integrate PhotosUI square edit when available; detect support by OS/capabilities
  - [x] 3.3 Build in-app square cropper fallback; ensure exact square output
  - [x] 3.4 Downscale originals to max dimension 3000 px; preserve EXIF orientation
  - [x] 3.5 Generate and store 1000 px thumbnails; consider additional tiny preview if needed
  - [x] 3.6 Implement NSCache-based thumbnail cache and disk lookup fallback
  - [x] 3.7 Enforce max 10 photos per watch; display counter and disable Add beyond limit
  - [x] 3.8 Implement reorder persistence (position column) and primary photo enforcement
  - [x] 3.9 Implement delete with confirmation and on-disk cleanup

- [ ] 4.0 Implement UI: create/edit with Core vs Additional Details, details screen, and collections
  - [x] 4.1 Create/edit form: show core fields (manufacturer, line, model_name, reference_number, nickname) and photos at top
  - [x] 4.2 Additional Details section: collapsible by default with all other attributes grouped by category
  - [x] 4.3 Collections UI: collapsible rows for service history, valuations, and straps; add/edit/delete flows
  - [x] 4.4 Photos UI: grid of thumbnails, Add Photo button (disabled at 10), reorder via drag, Set as Primary, delete
  - [x] 4.5 Details screen: collapsed sections by default; horizontally swipeable photo gallery with pagination and full-screen viewer
  - [x] 4.6 Date inputs: explicit pickers; render empty by default; clear action to unset
  - [x] 4.7 Enum pickers with "Other" path to free-text input
  - [x] 4.8 Basic accessibility (labels/traits) for new controls

- [ ] 5.0 Implement list views with sorting, filtering, and thumbnail performance
  - [x] 5.1 Default sort manufacturer > line > model_name; persist user override if needed
  - [x] 5.2 Implement filters: manufacturer, line, movement.type, water_resistance_m range, tags, condition, country_of_origin, purchase date range, has photos
  - [x] 5.3 Use 1000 px thumbnails in list cells; lazy-load full-size only on demand
  - [x] 5.4 Add empty states and loading placeholders; ensure smooth scrolling performance
  - [x] 5.5 Telemetry hooks or debug overlay to verify P95 list load < 300 ms (dev builds)

- [ ] 6.0 Integrate wiring and configuration (dependency injection, permissions, caching)
  - [x] 6.1 Initialize GRDB database on app launch; inject repositories via environment/dependency container
  - [x] 6.2 Request Photos permission on first use with rationale text; handle denied/limited states gracefully
  - [x] 6.3 Configure image cache and cleanup policies; background purge of orphaned files
  - [x] 6.4 Remove/disable Core Data stack and repository usage paths; migrate feature code to new repos
  - [x] 6.5 Add lightweight data seed/dev fixtures behind debug flag (optional)

- [ ] 7.0 Testing: unit (models/validators/photos), UI (photos CRUD/enforcement/limits), E2E flows
  - [x] 7.1 Unit: validators (ranges/enums), tag slugging, date defaults, primary photo invariant
  - [x] 7.2 Unit: repositories (CRUD, filters, sorting, transactions, cascade deletes)
  - [x] 7.3 Unit: photo pipeline (crop to square, downscale, thumbnail generation, cache)
  - [ ] 7.4 UI: add/reorder/delete photos; enforce square crop; enforce 10-photo limit
  - [ ] 7.5 UI: create/edit Additional Details collapsed by default; date empty until set
  - [ ] 7.6 E2E: create → edit → details flow validation; verify list sort and filters; confirm dates remain empty unless set
  - [ ] 7.7 Test utilities: temporary DB setup/teardown; image fixtures; sandbox cleanup


