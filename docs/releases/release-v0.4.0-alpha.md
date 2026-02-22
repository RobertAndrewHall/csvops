# Release Checklist: v0.4.0-alpha

## 1. Verify environment

```bash
ruby -v
bundle -v
```

Expected:
- Ruby `3.3.0`

## 2. Install dependencies

```bash
bundle install
```

## 3. Run quality checks

```bash
bundle exec rake test
```

## 4. Smoke test CLI commands

```bash
bundle exec csvtool menu
bundle exec csvtool column test/fixtures/sample_people.csv name
```

## 5. Smoke test workflows

### Row randomization workflow

Use menu option `3` (`Randomize rows`) and verify:
- headered CSV output keeps header in first row
- seeded mode is reproducible
- file output path writes valid CSV
- headerless mode randomizes all rows

### Cross-CSV dedupe workflow

Use menu option `4` (`Dedupe using another CSV`) and verify:
- headered + comma happy path produces expected retained rows
- headerless + index selectors work
- TSV separators work
- normalization toggles (`trim`, `case-insensitive`) behave as expected
- diagnostics render for `no matches` and `all removed`
- file output mode writes expected CSV

## 6. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./releases/gems/csvops-0.4.0.alpha.gem
csvtool menu
```

## 7. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.4.0-alpha"
```

## 8. Tag release

```bash
git tag -a v0.4.0-alpha -m "v0.4.0-alpha"
git push origin main --tags
```

## 9. Publish gem (optional for alpha)

```bash
gem push releases/gems/csvops-0.4.0.alpha.gem
```

## 10. Create GitHub release

Create release `v0.4.0-alpha` with:
- Cross-CSV dedupe workflow with normalization options and large-file streaming behavior
- Dedupe domain model (`CrossCsvDedupeSession`) with stronger invariants
- Shared-kernel `OutputDestination` value object across workflows
- Architecture/docs split (`README` + `docs/architecture.md`) with UML diagrams
- Dedupe boundary cleanup: CLI workflow (`RunCrossCsvDedupeWorkflow`) and application use-case separation
