# Release Checklist: v0.5.0-alpha

## 1. Verify environment

```bash
ruby -v
bundle -v
```

Expected:
- Ruby `3.3.x`

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

### Row extraction workflow

Use menu option `2` (`Extract rows (range)`) and verify:
- headered CSV rows print correctly in console mode
- out-of-bounds row range shows friendly message
- file output mode writes expected CSV rows

### Row randomization workflow

Use menu option `3` (`Randomize rows`) and verify:
- seeded mode is reproducible
- headered and headerless modes both work
- file output path writes valid randomized CSV

### Cross-CSV dedupe workflow

Use menu option `4` (`Dedupe using another CSV`) and verify:
- expected retained rows for headered source/reference files
- separator/header-mode combinations still work
- file output mode writes expected deduped CSV

## 6. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./releases/gems/csvops-0.5.0.alpha.gem
csvtool menu
```

## 7. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.5.0-alpha"
```

## 8. Tag release

```bash
git tag -a v0.5.0-alpha -m "v0.5.0-alpha"
git push origin main --tags
```

## 9. Publish gem (optional for alpha)

```bash
gem push releases/gems/csvops-0.5.0.alpha.gem
```

## 10. Create GitHub release

Create release `v0.5.0-alpha` with:
- Use-case file-write boundary cleanup across all workflows
- New infrastructure file-writer adapters for row randomization and cross-CSV dedupe
- Final architecture boundary audit with guard test for direct write APIs in use cases
- Updated architecture diagrams to reflect current writer adapter dependencies
