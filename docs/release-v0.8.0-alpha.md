# Release Checklist: v0.8.0-alpha

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

### CSV stats workflow (new in this release)

Use menu option `7` (`CSV stats summary`) and verify:
- happy path summary prints rows/columns/headers
- separator and header mode options work (CSV/TSV/headerless/custom)
- column completeness output is correct for blanks
- output destination supports console and file
- invalid output path returns friendly error

### Existing workflows regression pass

Use menu options `1-6` and verify:
- column extraction still works
- row-range extraction still works
- row randomization still works
- cross-CSV dedupe still works
- parity validation still works
- CSV split still works

## 6. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./csvops-0.8.0.alpha.gem
csvtool menu
```

## 7. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.8.0-alpha"
```

## 8. Tag release

```bash
git tag -a v0.8.0-alpha -m "v0.8.0-alpha"
git push origin main --tags
```

## 9. Publish gem

```bash
gem push csvops-0.8.0.alpha.gem
```

## 10. Create GitHub release

Create release `v0.8.0-alpha` with:
- New `CSV stats summary` workflow
- Stats-domain architecture (workflow steps, builder, presenter, use case, infrastructure adapters)
- Console/file output destination support for stats summary artifacts
- Streaming stats scanner coverage for large files
- Stats documentation updates in README + architecture guide
