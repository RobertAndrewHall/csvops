# Release Checklist: v0.6.0-alpha

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

### CSV parity workflow

Use menu option `5` (`Validate parity`) and verify:
- matching files with reordered rows return parity success
- mismatch files return friendly mismatch summary with sample deltas
- separator and header-mode selections are respected

### Existing workflows regression pass

Run quick checks for menu options `1-4` and confirm:
- column extraction still works
- row-range extraction still works
- row randomization still works
- cross-CSV dedupe still works

## 6. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./releases/gems/csvops-0.6.0.alpha.gem
csvtool menu
```

## 7. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.6.0-alpha"
```

## 8. Tag release

```bash
git tag -a v0.6.0-alpha -m "v0.6.0-alpha"
git push origin main --tags
```

## 9. Publish gem

```bash
gem push releases/gems/csvops-0.6.0.alpha.gem
```

## 10. Create GitHub release

Create release `v0.6.0-alpha` with:
- Dedicated CSV parity validation workflow
- Header/separator parity options
- Friendly parity mismatch reporting
- Streaming delta-count parity comparator
- Parity architecture convergence (session model, workflow steps, presenter, docs)
