---
id: AgDR-0001
timestamp: 2026-09-30T13:30:00Z
agent: claude
model: claude-opus-5-5
trigger: user-prompt
status: executed
---

# Narrow runtime dependencies, fix packaging, and add CI

> In the context of the rails_routes_to_collections gem, facing failing specs, a gem that ships development scripts, and no CI, I decided to depend on railties and activesupport, list gem files explicitly, and add a GitHub Actions spec run to achieve a small, tested release, accepting that users who relied on this gem to pull in all of Rails must add it themselves.

## Context

- 12 of 15 specs failed with `undefined method 'humanize'`. The library called ActiveSupport core extensions without loading them.
- The 0.2.0 gem shipped `demo_test.rb`, `simple_demo.rb`, `test_installation.rb`, `install.rb`, `setup.sh`, `SETUP_GUIDE.md`, and `.rspec`.
- The gemspec depended on the full `rails` gem. The code uses only `Rails::Railtie`, the route set, and ActiveSupport string and object extensions.
- The repo had no CI workflow.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Depend on `railties` + `activesupport`, glob gem files explicitly, add CI | Smallest dependency set that the code uses. The gem contents are predictable. Regressions show up on each PR | A user app that is not a full Rails app gets fewer transitive gems |
| Keep `rails`, only add the missing requires | Smallest diff | Installs Action Cable, Active Storage, and the rest for no reason. Packaging and CI problems remain |
| Do nothing | No work | The gem stays broken outside a loaded Rails app and keeps shipping scripts |

## Decision

Chosen: **depend on `railties` + `activesupport`, glob gem files explicitly, and add CI**, because it fixes each observed problem with the dependencies the code actually uses. The gem is a dev tool that runs inside a Rails app, and that app already has the full Rails stack.

## Consequences

- `spec.files` lists `lib/**/*`, `exe/*`, `README.md`, `CHANGELOG.md`, and `LICENSE.txt`. The install scripts stay in the repo for the documented `ruby install.rb` usage.
- CI runs RSpec on Ruby 3.2, 3.3, and 3.4 for each push to `main` and each PR.
- The dependency floors stay open-ended (`>= 6.0`), as before. `gem build` warns about this.
- RuboCop offenses and duplicate generator code are out of scope.

## Artifacts

- https://github.com/a-abdellatif98/rails_routes_to_collections/issues/1
