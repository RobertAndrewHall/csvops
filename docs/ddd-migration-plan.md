# DDD-Lite Migration Plan

## Goal

Move `csvops` from flow-centric orchestration to a clearer Domain-Driven structure while preserving current CLI behavior.

## Target layering

- `domain/`: business concepts, invariants, pure behavior
- `application/`: use-case orchestration and policy coordination
- `infrastructure/`: CSV/file/output adapters
- `interface/cli/`: prompts, menu, user interaction

## Target model (initial)

### Aggregate

- `ExtractionSession` (aggregate root)
  - Owns extraction lifecycle state
  - Applies confirmation + destination decisions
  - Enforces extraction invariants

### Entities

- `CsvSource`
  - Path + separator selection context
  - Validity/readability checks delegated via adapters
- `ColumnSelection`
  - Selected header from discovered header set

### Value Objects

- `Separator`
- `ExtractionOptions` (`skip_blanks`, preview_limit)
- `OutputDestination` (`console` or `file(path)`)
- `Preview` (first N extracted values)
- `ExtractionValue`

### Domain services

- `PreviewPolicy` (preview window handling)
- `ExtractionPolicy` (blank filtering behavior)

## Current-to-target mapping

- `Csvtool::ExtractColumnWorkflow` -> split into:
  - `application/use_cases/run_extraction.rb`
  - domain aggregate + value objects
- `services/header_reader.rb`, `services/value_streamer.rb` -> move under `infrastructure/csv/`
- `output/console_writer.rb`, `output/csv_file_writer.rb` -> move under `infrastructure/output/`
- prompt classes -> move under `interface/cli/prompts/`
- `errors/presenter.rb` -> `interface/cli/errors/presenter.rb`

## Incremental migration phases

### Phase 1: Introduce domain types (no behavior change)

- Add `domain/extraction_session/` with value objects and aggregate skeleton.
- Keep existing workflow active; adapt it to instantiate domain objects.
- Add unit tests for each new domain type.

### Phase 2: Add application use-case

- Create `application/use_cases/run_extraction.rb`.
- Move orchestration from `ExtractColumnWorkflow` into use-case.
- Keep CLI prompts as input providers; map prompt results into domain/application types.

### Phase 3: Formalize infrastructure adapters

- Move CSV and output classes into `infrastructure/`.
- Depend on interfaces from application/domain boundary, not concrete CLI classes.
- Keep behavior and messages unchanged.

### Phase 4: Interface cleanup

- Keep `MenuLoop` + prompts in `interface/cli`.
- Reduce workflow class to wiring only (or remove if replaced by use-case wiring).
- Keep `bin/tool` and `Csvtool::CLI` minimal.

### Phase 5: Stabilize and document

- Update README architecture + domain model sections.
- Ensure full test suite remains green.
- Add migration notes for contributors.

## Test strategy

- Preserve existing integration tests as regression safety net.
- Add unit tests per new domain class:
  - constructors/invariants
  - policy behavior
  - aggregate transitions
- Add use-case tests:
  - happy path
  - cancel path
  - file output path
  - invalid input/error mapping

## Non-goals (for this migration)

- Changing CLI UX text/output format
- Adding new extraction features
- Introducing heavy framework dependencies

## Definition of done

- Layer boundaries are explicit in folders and dependencies.
- Domain classes are pure and independently testable.
- Application use-case orchestrates behavior without prompt/IO coupling.
- Infrastructure adapters handle external concerns only.
- Existing user-visible behavior remains consistent.
