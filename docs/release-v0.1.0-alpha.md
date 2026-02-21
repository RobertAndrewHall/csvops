# Release Checklist: v0.1.0-alpha

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
printf '2\n' | bundle exec csvtool menu
bundle exec csvtool column test/fixtures/sample_people.csv name
```

Expected output for `column` command:

```text
Alice
Bob
Cara
```

## 5. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./csvops-0.1.0.alpha.gem
csvtool column test/fixtures/sample_people.csv name
```

## 6. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.1.0-alpha"
```

## 7. Tag release

```bash
git tag -a v0.1.0-alpha -m "v0.1.0-alpha"
git push origin main --tags
```

## 8. Publish gem (optional for alpha)

```bash
gem push csvops-0.1.0.alpha.gem
```

## 9. Create GitHub release

Create release `v0.1.0-alpha` with:
- Summary of supported commands (`menu`, `column`)
- Known limitations
- Install instructions (`gem install csvops --pre`)
