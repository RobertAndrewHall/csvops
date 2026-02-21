# CSV Ops CLI

`csvops` is a small Ruby CLI for interactive CSV workflows.

## Requirements

- Ruby (tested with Ruby 2.6+)
- `rake`
- `minitest`

Install dependencies:

```bash
bundle install
```

## Usage

Run the interactive menu:

```bash
./bin/tool menu
```

You should see:

```text
CSV Tool Menu
1. Extract column
2. Exit
>
```

Choose `1` to extract a column:

```text
CSV file path: /path/to/file.csv
Choose separator:
1. comma (,)
2. tab (\t)
3. semicolon (;)
4. pipe (|)
5. custom
Separator choice [1]: 1
Filter columns (optional):
Select column:
1. name
2. city
Column number: 1
Skip blank values? [Y/n]:
Preview (first 3 values):
Alice
Bob
Cara
Print all values? [y/N]: y
Output destination:
1. console
2. file
Output destination [1]: 1
Alice
Bob
Cara
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

## Architecture

The codebase follows a DDD-lite layered structure:

- `domain/`: core domain model and invariants (`ExtractionSession` aggregate + value objects/entities).
- `application/`: use-case orchestration (`RunExtraction`).
- `infrastructure/`: CSV reading/streaming and output adapters (console/file).
- `interface/cli/`: menu, prompts, and user-facing error presentation.
- `Csvtool::CLI`: entrypoint wiring from command args to interface/application flow.

## Domain model

The core domain is "extract values from one selected CSV column with safe interactive controls."

- `ExtractionSession` (aggregate root): owns extraction workflow state and decisions.
- `CsvSource`: source file path plus separator.
- `ColumnSelection`: selected header/column name.
- `ExtractionOptions`: extraction behavior (`skip_blanks`, `preview_limit`).
- `Preview`: first `N` extracted values shown before execution.
- `OutputDestination`: destination decision (`console` or `file(path)`).
- `ExtractionValue`: normalized extracted value object.

```mermaid
flowchart TD
  A["CsvSource (path + separator)"] --> B["HeaderSet"]
  B --> C["ColumnSelection"]
  C --> D["ExtractionOptions (skip_blanks)"]
  D --> E["ValueStream (row-by-row)"]
  E --> F["Preview (first N values)"]
  F --> G{"Confirm extraction?"}
  G -->|"No"| H["Cancel + return to menu"]
  G -->|"Yes"| I["OutputDestination"]
  I -->|"Console"| J["Console output (stream values)"]
  I -->|"File"| K["CSV file output (header + one value per row)"]
```

## Project layout

```text
bin/tool              # CLI entrypoint
lib/csvtool/cli.rb
lib/csvtool/domain/extraction_session/*
lib/csvtool/application/use_cases/run_extraction.rb
lib/csvtool/infrastructure/csv/*
lib/csvtool/infrastructure/output/*
lib/csvtool/interface/cli/menu_loop.rb
lib/csvtool/interface/cli/prompts/*
lib/csvtool/interface/cli/errors/presenter.rb
test/csvtool/cli_test.rb         # end-to-end workflow tests
test/csvtool/**/*_test.rb        # focused unit tests by component folder
test/test_helper.rb
```
