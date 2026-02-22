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
5. Exit
>
```

Select `1` for column extraction, `2` for row-range extraction, `3` for row randomization, or `4` for cross-CSV dedupe.

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

### 7. Dedupe interaction example

Legend: ` ` = prompt/menu, `+` = user input, `-` = tool output

```diff
 CSV Tool Menu
 1. Extract column
 2. Extract rows (range)
 3. Randomize rows
 4. Dedupe using another CSV
 5. Exit
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

Current prerelease version: `0.4.0.alpha`

Install prerelease from RubyGems:

```bash
gem install csvops --pre
```

Release runbook:

- `docs/release-v0.4.0-alpha.md`


## Architecture

Full architecture and domain documentation lives in:

- [`docs/architecture.md`](docs/architecture.md)
