# CSV Ops CLI

`csvops` is a small Ruby CLI for interactive CSV workflows.

## Requirements

- Ruby 3.3.0
- Bundler
- `rake`
- `minitest`

Install dependencies:

```bash
bundle install
```

## Usage

### 1. Start the CLI

```bash
csvtool menu
```

With Bundler:

```bash
bundle exec csvtool menu
```

### 2. Choose an action

```text
CSV Tool Menu
1. Extract column
2. Extract rows (range)
3. Exit
>
```

Select `1` to run extraction.

### 3. Follow prompts

Prompt flow:

- CSV file path
- Separator (`comma`, `tab`, `semicolon`, `pipe`, or `custom`)
- Optional header filter + column selection
- Skip blanks (`Y/n`, default `Y`)
- Preview + confirmation
- Output destination (`console` or `file`)

### 4. Example interaction (console output)

Legend: ` ` = prompt/menu, `+` = user input, `-` = tool output

```diff
 CSV file path: /path/to/file.csv
 Choose separator:
 1. comma (,)
 2. tab (\t)
 3. semicolon (;)
 4. pipe (|)
 5. custom
+Separator choice [1]: 1
 Filter columns (optional):
 Select column:
 1. name
 2. city
+Column number: 1
 Skip blank values? [Y/n]:
 Preview (first 3 values):
-Alice
-Bob
-Cara
 Print all values? [y/N]:
+y
 Output destination:
 1. console
 2. file
+Output destination [1]: 1
-Alice
-Bob
-Cara
```

### 5. Example interaction (file output)

```diff
 Output destination:
 1. console
 2. file
+Output destination [1]: 2
+Output file path: /tmp/names.csv
-Wrote output to /tmp/names.csv
```

### 6. Direct command mode

Extract a column without using the interactive menu:

```bash
csvtool column /path/to/file.csv column_name
```

With Bundler:

```bash
bundle exec csvtool column /path/to/file.csv column_name
```

## Testing

Run tests:

```bash
rake test
```

Or:

```bash
bundle exec rake test
```

## Alpha release

Current prerelease version: `0.3.0.alpha`

Install prerelease from RubyGems:

```bash
gem install csvops --pre
```

Release runbook:

- `docs/release-v0.3.0-alpha.md`

## Architecture

The codebase follows a DDD-lite layered structure:

- `domain/`: core domain models and invariants (`ColumnSession`, `RowSession`, `RandomizationSession`, and `CrossCsvDedupeSession` aggregates + supporting entities/value objects).
- `application/`: use-case orchestration (`RunExtraction`, `RunRowExtraction`, `RunRowRandomization`, `RunCrossCsvDedupe`).
- `infrastructure/`: CSV reading/streaming and output adapters (console/file), plus cross-CSV dedupe adapter.
- `interface/cli/`: menu, prompts, workflows, and user-facing error presentation.
- `Csvtool::CLI`: entrypoint wiring from command args to interface/application flow.

## Domain model

Bounded contexts: `Column Extraction`, `Row Extraction`, `Row Randomization`, and `Cross-CSV Dedupe`.

### Cross-CSV Dedupe (Large-file behavior)

- Workflow: remove rows from a source CSV when source key matches a key from a reference CSV.
- Scaling strategy:
  - Reference CSV keys are loaded into a `Set` for fast membership checks.
  - Source CSV rows are streamed directly to the selected output destination (console or file).
- Memory tradeoff:
  - Memory is dominated by the number of unique keys in the reference CSV.
  - Source-row memory stays bounded because retained rows are not accumulated in memory before writing.

### Column Extraction

- Aggregate root: `ColumnSession`
  - Controls extraction state transitions (`start`, `with_preview`, `confirm!`, `with_output_destination`).
  - Enforces session-level invariants.
- Entities:
  - `CsvSource` (file path + `Separator`)
  - `ColumnSelection` (chosen header)
- Value objects:
  - `Separator`
  - `ExtractionOptions` (`skip_blanks`, `preview_limit`)
  - `Preview` (list of `ExtractionValue`)
  - `ExtractionValue`
  - Shared `OutputDestination` (`console` or `file(path)`)
- Application service:
  - `Application::UseCases::RunExtraction` orchestrates one extraction request.
- Infrastructure adapters:
  - `Infrastructure::CSV::HeaderReader`
  - `Infrastructure::CSV::ValueStreamer`
  - `Infrastructure::Output::ConsoleWriter`
  - `Infrastructure::Output::CsvFileWriter`
- Interface adapters:
  - `Interface::CLI::MenuLoop`
  - `Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow`
  - `Interface::CLI::Prompts::*`
  - `Interface::CLI::Errors::Presenter`

```mermaid
flowchart LR
  UI["Interface CLI\n(Menu + Prompts + Errors)"] --> APP["Application Use Case\nRunExtraction"]
  APP --> AGG["Domain Aggregate\nColumnSession"]

  AGG --> E1["Entity\nCsvSource"]
  AGG --> E2["Entity\nColumnSelection"]
  AGG --> V1["Value Objects\nSeparator / ExtractionOptions / Preview / Shared OutputDestination / ExtractionValue"]

  APP --> INFCSV["Infrastructure CSV\nHeaderReader + ValueStreamer"]
  APP --> INFOUT["Infrastructure Output\nConsoleWriter + CsvFileWriter"]
```

### Row Extraction

Core DDD structure:

- Aggregate root: `RowSession`
  - Captures one row-range extraction request.
  - Holds selected source, requested range, and output destination.
- Entity:
  - `RowSource` (file path + separator)
- Value objects:
  - `RowRange` (`start_row`, `end_row`) plus row-range validation errors
  - Shared `OutputDestination` (`console` or `file(path)`)
- Application service:
  - `Application::UseCases::RunRowExtraction` orchestrates row-range extraction.
- Infrastructure adapters:
  - `Infrastructure::CSV::HeaderReader`
  - `Infrastructure::CSV::RowStreamer`
  - `Infrastructure::Output::CsvRowConsoleWriter`
  - `Infrastructure::Output::CsvRowFileWriter`
- Interface adapters:
  - `Interface::CLI::MenuLoop`
  - `Interface::CLI::Prompts::*`
  - `Interface::CLI::Errors::Presenter`

```mermaid
flowchart LR
  UI2["Interface CLI\n(Menu + Prompts + Errors)"] --> APP2["Application Use Case\nRunRowExtraction"]
  APP2 --> AGG2["Domain Aggregate\nRowSession"]

  AGG2 --> E3["Entity\nRowSource"]
  AGG2 --> V2["Value Objects\nRowRange / Shared OutputDestination"]

  APP2 --> INFCSV2["Infrastructure CSV\nHeaderReader + RowStreamer"]
  APP2 --> INFOUT2["Infrastructure Output\nCsvRowConsoleWriter + CsvRowFileWriter"]
```

### Row Randomization

Core DDD structure:

- Aggregate root: `RandomizationSession`
  - Captures one randomization request from source + options + output destination.
- Entity:
  - `RandomizationSource` (file path + separator + header mode)
- Value objects:
  - `RandomizationOptions` (optional deterministic `seed`)
  - Shared `OutputDestination` (`console` or `file(path)`)
- Application service:
  - `Application::UseCases::RunRowRandomization` orchestrates row randomization.
- Infrastructure adapters:
  - `Infrastructure::CSV::HeaderReader`
  - `Infrastructure::CSV::RowRandomizer` (external chunked `RAND + sort` + merge)
- Interface adapters:
  - `Interface::CLI::MenuLoop`
  - `Interface::CLI::Prompts::*`
  - `Interface::CLI::Errors::Presenter`

```mermaid
flowchart LR
  UI3["Interface CLI\n(Menu + Prompts + Errors)"] --> APP3["Application Use Case\nRunRowRandomization"]
  APP3 --> AGG3["Domain Aggregate\nRandomizationSession"]

  AGG3 --> E4["Entity\nRandomizationSource"]
  AGG3 --> V3["Value Objects\nRandomizationOptions / Shared OutputDestination"]

  APP3 --> INFCSV3["Infrastructure CSV\nHeaderReader + RowRandomizer"]
```

### Cross-CSV Dedupe

Core DDD structure:

- Aggregate root: `CrossCsvDedupeSession`
  - Captures one dedupe request with source/reference profiles, key mapping, match options, and output destination.
- Entities:
  - `CsvProfile` (path + separator + header mode) for source and reference CSVs.
  - `KeyMapping` (source selector + reference selector).
- Value objects:
  - `ColumnSelector` (header name or 1-based index mode)
  - `MatchOptions` (`trim_whitespace`, `case_insensitive`, plus normalization behavior)
  - Shared `OutputDestination` (`console` or `file(path)`)
- Application service:
  - `Application::UseCases::RunCrossCsvDedupe` orchestrates dedupe workflow.
- Infrastructure adapters:
  - `Infrastructure::CSV::HeaderReader`
  - `Infrastructure::CSV::CrossCsvDeduper` (streams source rows while checking membership against reference key set)
- Interface adapters:
  - `Interface::CLI::MenuLoop`
  - `Interface::CLI::Prompts::*`
  - `Interface::CLI::Errors::Presenter`

```mermaid
flowchart LR
  UI4["Interface CLI\n(Menu + Prompts + Errors)"] --> WF4["CLI Workflow\nRunCrossCsvDedupeWorkflow"]
  WF4 --> APP4["Application Use Case\nRunCrossCsvDedupe"]
  APP4 --> AGG4["Domain Aggregate\nCrossCsvDedupeSession"]

  AGG4 --> E5["Entities\nCsvProfile(source/reference) + KeyMapping"]
  AGG4 --> V4["Value Objects\nColumnSelector / MatchOptions / Shared OutputDestination"]

  APP4 --> INFCSV4["Infrastructure CSV\nHeaderReader + CrossCsvDeduper"]
```

## Project layout

```text
bin/tool              # CLI entrypoint
lib/csvtool/cli.rb
lib/csvtool/domain/column_session/*
lib/csvtool/domain/row_session/*
lib/csvtool/domain/row_randomization_session/*
lib/csvtool/application/use_cases/run_extraction.rb
lib/csvtool/application/use_cases/run_row_extraction.rb
lib/csvtool/application/use_cases/run_row_randomization.rb
lib/csvtool/application/use_cases/run_cross_csv_dedupe.rb
lib/csvtool/infrastructure/csv/*
lib/csvtool/infrastructure/output/*
lib/csvtool/domain/shared/output_destination.rb
lib/csvtool/interface/cli/menu_loop.rb
lib/csvtool/interface/cli/workflows/*
lib/csvtool/interface/cli/prompts/*
lib/csvtool/interface/cli/errors/presenter.rb
test/csvtool/cli_test.rb         # end-to-end workflow tests
test/csvtool/**/*_test.rb        # focused unit tests by component folder
test/test_helper.rb
```
