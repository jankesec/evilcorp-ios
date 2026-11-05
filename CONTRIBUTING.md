# Contributing

EvilCorp is intentionally vulnerable training software. Contributions should improve
teaching quality, correctness, accessibility, documentation, or reproducibility without
presenting the app as safe for production use.

## Development workflow

1. Use Xcode 16 or newer and install [XcodeGen](https://github.com/yonaskolb/XcodeGen).
2. Run `make project` after changing `project.yml`.
3. Run `make check` before opening a pull request.
4. Keep challenge identifiers stable so existing progress data remains valid.
5. Update the catalog tests and README when adding or removing a challenge.

Deliberately vulnerable behavior must stay contained within its named challenge. Do not
add real credentials, production endpoints, third-party data, or undeclared background
activity. Use synthetic values and local-only demonstrations whenever possible.
