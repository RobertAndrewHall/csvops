# CLI Output Conventions

This document defines the output contract for all CLI workflows.

## 1. Stream contract

- `stdout` is for data output only.
- `stderr` is for prompts, menu UI, status, and errors.
- Commands should be pipe-safe: redirecting `stdout` must not capture prompts/errors.

## 2. Format contract

- Supported formats: `text`, `json`, `csv`.
- `text` is human-readable and may include tables/colors.
- `json` and `csv` are machine-readable and should remain stable over time.
- Structured formats must avoid decorative output.

## 3. Color policy

- Supported modes: `auto`, `always`, `never`.
- `auto` colors only when output target is a TTY.
- `NO_COLOR` disables color in `auto` mode.
- `always` overrides `NO_COLOR`.
- Structured formats (`json`, `csv`) are not colorized.

## 4. Table rendering rules

- Use shared table renderer for summary-style text output.
- Render within terminal width constraints.
- Truncate long cells with ellipsis when necessary.
- Avoid broken/overlapping columns in narrow terminals.

## 5. Shared services usage

All workflows should use shared output services under:

- `lib/csvtool/interface/cli/output/streams.rb`
- `lib/csvtool/interface/cli/output/formatters/*`
- `lib/csvtool/interface/cli/output/color_policy.rb`
- `lib/csvtool/interface/cli/output/colorizer.rb`
- `lib/csvtool/interface/cli/output/table_renderer.rb`

Prefer these services over ad-hoc formatting in presenters/workflows.

## 6. Testing expectations

- Add focused unit tests for each output service.
- Add workflow/CLI tests for stream separation and representative formatting behavior.
- Keep acceptance assertions centered on contract semantics rather than fragile spacing where possible.
