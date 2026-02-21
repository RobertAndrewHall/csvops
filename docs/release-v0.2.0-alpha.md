# Release Checklist: v0.2.0-alpha

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

Expected output for `column` command:

```text
Alice
Bob
Cara
```

## 5. Smoke test row extraction workflow

Use menu option `2` (`Extract rows (range)`), then verify:
- console output path works
- file output path works
- row-range validation errors are handled cleanly

## 6. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./csvops-0.2.0.alpha.gem
csvtool menu
```

## 7. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.2.0-alpha"
```

## 8. Tag release

```bash
git tag -a v0.2.0-alpha -m "v0.2.0-alpha"
git push origin main --tags
```

## 9. Publish gem (optional for alpha)

```bash
gem push csvops-0.2.0.alpha.gem
```

## 10. Create GitHub release

Create release `v0.2.0-alpha` with:
- Summary of supported commands (`menu`, `column`, `row range`)
- Notes on output destination support (`console`, `file`)
- Install instructions (`gem install csvops --pre`)
