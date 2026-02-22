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
3. Randomize rows
4. Dedupe using another CSV
5. Validate parity
6. Split CSV into chunks
7. CSV stats summary
8. Exit
>
```

Select `1` for column extraction, `2` for row-range extraction, `3` for row randomization, `4` for cross-CSV dedupe, `5` for parity validation, `6` for CSV splitting, or `7` for CSV stats.

### 3. Follow prompts

Each menu action runs through a dedicated CLI workflow (`interface/cli/workflows/*`) that handles prompts/output and delegates execution to an interface-agnostic application use case.

Workflow internals are split into small composable parts:

- `workflows/builders/*` for session construction
- `workflows/support/*` for shared mapping/dispatch utilities
- `workflows/presenters/*` for output formatting and summaries

Prompt flow by action:

- `Extract column`: file path, separator, optional header filter + column select, skip blanks, preview/confirm, output destination.
- `Extract rows (range)`: file path, separator, start row, end row, output destination.
- `Randomize rows`: file path, separator, headers present, optional seed, output destination.
- `Dedupe using another CSV`: source/reference files, separators, header modes, key selectors, match options, output destination.
- `Validate parity`: left/right files, separator, header mode, parity summary, mismatch samples.
- `Split CSV into chunks`: source file, separator, header mode, chunk size, output directory/prefix, overwrite policy, optional manifest.
- `CSV stats summary`: source file, separator, header mode, output destination.

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

### 7. Dedupe interaction example

Legend: ` ` = prompt/menu, `+` = user input, `-` = tool output

```diff
 CSV Tool Menu
 1. Extract column
 2. Extract rows (range)
3. Randomize rows
4. Dedupe using another CSV
5. Validate parity
6. Split CSV into chunks
 7. CSV stats summary
 8. Exit
+> 4
 CSV file path: /tmp/source.csv
 Source CSV separator:
 Choose separator:
 1. comma (,)
 2. tab (\t)
 3. semicolon (;)
 4. pipe (|)
 5. custom
+Separator choice [1]: 1
 Source headers present? [Y/n]:
 Reference CSV file path: /tmp/reference.csv
 Reference CSV separator:
 Choose separator:
 1. comma (,)
 2. tab (\t)
 3. semicolon (;)
 4. pipe (|)
 5. custom
+Separator choice [1]: 1
 Reference headers present? [Y/n]:
 Source key column name: customer_id
 Reference key column name: external_id
 Trim whitespace before matching? [Y/n]:
 Case-insensitive matching? [y/N]:
 Output destination:
 1. console
 2. file
+Output destination [1]: 1
-
-customer_id,name
-1,Alice
-3,Cara
-Summary: source_rows=5 removed_rows=3 kept_rows=2
```

### 8. Parity interaction example

Legend: ` ` = prompt/menu, `+` = user input, `-` = tool output

```diff
 CSV Tool Menu
 1. Extract column
 2. Extract rows (range)
3. Randomize rows
4. Dedupe using another CSV
5. Validate parity
 6. Split CSV into chunks
 7. CSV stats summary
 8. Exit
+> 5
 Left CSV file path: /tmp/left.csv
 Right CSV file path: /tmp/right.csv
 Choose separator:
 1. comma (,)
 2. tab (\t)
 3. semicolon (;)
 4. pipe (|)
 5. custom
+Separator choice [1]: 1
 Headers present? [Y/n]:
-MISMATCH
-Summary: left_rows=10 right_rows=10 left_only=2 right_only=2
-Left-only examples:
- 4,Dina (count +1)
-Right-only examples:
- 4,Dina-Updated (count +1)
```

### 9. Parity large-file behavior

- Parity uses a streaming count-delta strategy:
  - Stream left rows and increment row-key counts.
  - Stream right rows and decrement row-key counts.
- Exact duplicate semantics are preserved by count deltas per normalized row value.
- Memory scales with the number of distinct row keys in the parity map, not the total input row count.

### 10. Split interaction example

Legend: ` ` = prompt/menu, `+` = user input, `-` = tool output

```diff
 CSV Tool Menu
 1. Extract column
 2. Extract rows (range)
 3. Randomize rows
 4. Dedupe using another CSV
 5. Validate parity
 6. Split CSV into chunks
 7. CSV stats summary
 8. Exit
+> 6
 Source CSV file path: /tmp/people.csv
 Choose separator:
 1. comma (,)
 2. tab (\t)
 3. semicolon (;)
 4. pipe (|)
 5. custom
+Separator choice [1]: 1
 Headers present? [Y/n]:
+Rows per chunk: 1000
 Output directory [/tmp]:
 Output file prefix [people]:
 Overwrite existing chunk files? [y/N]:
 Write manifest file? [y/N]:
-Split complete.
-Chunk size: 1000
-Data rows: 25000
-Chunks written: 25
-/tmp/people_part_001.csv
```

### 11. CSV stats interaction example

Legend: ` ` = prompt/menu, `+` = user input, `-` = tool output

```diff
 CSV Tool Menu
 1. Extract column
 2. Extract rows (range)
 3. Randomize rows
 4. Dedupe using another CSV
 5. Validate parity
 6. Split CSV into chunks
 7. CSV stats summary
 8. Exit
+> 7
 CSV file path: /tmp/people.csv
 Choose separator:
 1. comma (,)
 2. tab (\t)
 3. semicolon (;)
 4. pipe (|)
 5. custom
+Separator choice [1]: 1
 Headers present? [Y/n]:
 Output destination:
 1. console
 2. file
+Output destination [1]: 1
-CSV Stats Summary
-Rows: 3
-Columns: 2
-Headers: name, city
-Column completeness:
-  name: non_blank=3 blank=0
-  city: non_blank=3 blank=0
```

### 12. CSV stats large-file behavior

- Stats scanning is streaming (`CSV.foreach`), processed in one pass.
- Memory grows with per-column aggregates (`column_stats`), not with total row count.

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

Current prerelease version: `0.7.0.alpha`

Install prerelease from RubyGems:

```bash
gem install csvops --pre
```

Release runbook:

- `docs/release-v0.7.0-alpha.md`


## Architecture

Full architecture and domain documentation lives in:

- [`docs/architecture.md`](docs/architecture.md)
