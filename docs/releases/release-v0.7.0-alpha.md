# Release Checklist: v0.7.0-alpha

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

### CSV split workflow (new in this release)

Use menu option `6` (`Split CSV into chunks`) and verify:
- happy path split (`N=10`) writes expected chunk files and counts
- separator and header mode options work (CSV/TSV/headerless/custom)
- output directory + file prefix options produce expected paths
- overwrite protection blocks existing chunk paths unless allowed
- optional manifest output writes valid CSV metadata

### Existing workflows regression pass

Use menu options `1-5` and verify:
- column extraction still works
- row-range extraction still works
- row randomization still works
- cross-CSV dedupe still works
- parity validation still works

## 6. Build and validate gem package

```bash
gem build csvops.gemspec
gem install ./releases/gems/csvops-0.7.0.alpha.gem
csvtool menu
```

## 7. Commit release prep

```bash
git add -A
git commit -m "chore(release): prepare v0.7.0-alpha"
```

## 8. Tag release

```bash
git tag -a v0.7.0-alpha -m "v0.7.0-alpha"
git push origin main --tags
```

## 9. Publish gem

```bash
gem push releases/gems/csvops-0.7.0.alpha.gem
```

## 10. Create GitHub release

Create release `v0.7.0-alpha` with:
- New `Split CSV into chunks` workflow
- Split-domain architecture (workflow steps, builder, presenter, use case, infrastructure adapters)
- Output strategy improvements (directory/prefix/overwrite controls)
- Optional split manifest output
- Large-file streaming split coverage and docs updates
