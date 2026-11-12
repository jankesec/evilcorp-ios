# Changelog

All notable changes to EvilCorp iOS are documented here. The project follows
[Semantic Versioning](https://semver.org/).

## [1.2.0] - 2026-11-12

### Fixed

- CTF score can no longer be inflated by toggling a challenge between solved and unsolved.
- An active CTF session (timer and score) now survives an app relaunch.
- "Reset Progress" in Settings now resets the progress shown on every screen; it previously
  cleared a separate, unused copy.
- Onboarding "Next" now advances to the next page instead of closing the onboarding, and the
  onboarding shows one page indicator instead of two.
- The CTF banner sits above the tabs instead of covering the home header.
- Settings show the correct repository link, challenge count, and app version.
- The SQLite lab no longer crashes when a username contains format specifiers such as `%@`.
- Requesting always-on location in the Excessive Permissions lab now works: the missing
  `NSLocationAlwaysAndWhenInUseUsageDescription` was added and the location manager is retained.
- Added a dark launch screen so the app uses the full display on current iPhones without a
  white flash at launch.
- The featured carousel no longer reshuffles on every redraw, the progress ring updates as
  challenges are solved, and console entries no longer collide when two lines are identical.

### Changed

- The Excessive Permissions lab masks names and numbers before writing harvested contacts to
  the system log, so a lab run never copies real address-book data into logs.
- Lab screens are resolved through a single `LabRegistry`; a test checks every catalog entry
  has a screen.
- Removed unused `DetailView` and `SplashScreenView` code.

### Added

- Progress and CTF scoring unit tests, and CI now runs the unit tests on an iOS Simulator.
- `make test` selects the first available iPhone simulator automatically.

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
[1.2.0]: https://github.com/jankesec/evilcorp-ios/releases/tag/v1.2.0
