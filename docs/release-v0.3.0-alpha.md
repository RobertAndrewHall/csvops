# Release Checklist: v0.3.0-alpha

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

## 5. Smoke test row randomization workflow

Use menu option `3` (`Randomize rows`) and verify:
- headered CSV output keeps header in first row
- seeded mode is reproducible
- file output path writes valid CSV
- headerless mode randomizes all rows

## 6. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./csvops-0.3.0.alpha.gem
csvtool menu
```

## 7. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.3.0-alpha"
```

## 8. Tag release

```bash
git tag -a v0.3.0-alpha -m "v0.3.0-alpha"
git push origin main --tags
```

## 9. Publish gem (optional for alpha)

```bash
gem push csvops-0.3.0.alpha.gem
```

## 10. Create GitHub release

Create release `v0.3.0-alpha` with:
- Randomize rows workflow support
- Seeded deterministic randomization
- External chunked randomization strategy for large files
- Updated domain model (`RowRandomizationSession`)
