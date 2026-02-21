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

## Project layout

```text
bin/tool              # CLI entrypoint
lib/csvtool/cli.rb    # CLI behavior
test/cli_test.rb      # unit tests for menu behavior
test/test_helper.rb   # test setup
```
