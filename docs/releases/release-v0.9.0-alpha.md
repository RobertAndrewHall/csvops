# Release Checklist: v0.9.0-alpha

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
bundle exec csvtool stats test/fixtures/sample_people.csv --format text
bundle exec csvtool stats test/fixtures/sample_people.csv --format json
bundle exec csvtool stats test/fixtures/sample_people.csv --format csv
```

## 5. Smoke test output conventions across workflows

Verify in menu-driven workflows:
- prompts/menu/errors are on `stderr`
- data output is on `stdout`

Verify shared output behavior:
- formatter consistency (`text|json|csv`)
- color policy (`auto|always|never`, `NO_COLOR`)
- width-aware summary tables in stats/parity/split/dedupe

## 6. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./releases/gems/csvops-0.9.0.alpha.gem
csvtool menu
```

## 7. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.9.0-alpha"
```

## 8. Tag release

```bash
git tag -a v0.9.0-alpha -m "v0.9.0-alpha"
git push origin main --tags
```

## 9. Publish gem

```bash
gem push releases/gems/csvops-0.9.0.alpha.gem
```

## 10. Create GitHub release

Create release `v0.9.0-alpha` with:
- Shared output stream services across workflows (`stdout` data, `stderr` UI/errors)
- Shared formatter services and migrated presenters
- Shared color policy + colorizer across workflows
- Shared width-aware table rendering across summary presenters
- New output conventions documentation (`docs/cli-output-conventions.md`)
