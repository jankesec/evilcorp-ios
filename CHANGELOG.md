# Changelog

All notable changes to EvilCorp iOS are documented here. The project follows
[Semantic Versioning](https://semver.org/).

## [1.1.1] - 2026-11-06

### Changed

- Relicensed the project from GPL-3.0-or-later to the MIT License.
- Updated release metadata and documentation for the license change.

## [1.1.0] - 2026-11-06

### Added

- Reproducible XcodeGen project and committed Xcode project.
- Catalog, metadata, and CTF scoring tests.
- macOS CI that type-checks and compiles the app and test bundle.
- Central application metadata and visual design tokens.
- Contribution guidelines and an explicit security-reporting boundary.

### Fixed

- Corrected stale 25- and 27-challenge counts across the interface.
- Made “Show all” display the complete 30-challenge catalog.
- Corrected CTF scoring to use challenge difficulty.
- Added required training descriptions for requested iOS permissions.
- Replaced deprecated non-training API usage while retaining intentional weaknesses.

### Changed

- Rewrote the README around reproducible builds, lab safety, and verified scope.
- Formatted the Swift source consistently with `swift-format`.

## [1.0.0] - 2026-06-20

- Initial public release.

[1.0.0]: https://github.com/jankesec/evilcorp-ios/releases/tag/v1.0.0
[1.1.0]: https://github.com/jankesec/evilcorp-ios/releases/tag/v1.1.0
[1.1.1]: https://github.com/jankesec/evilcorp-ios/releases/tag/v1.1.1
