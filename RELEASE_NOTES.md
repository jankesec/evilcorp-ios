## EvilCorp iOS v1.1.1

This release turns the repository into a reproducible, tested iOS training project while
preserving the intentionally vulnerable behavior of its 30 named labs.

### Highlights

- Ready-to-open Xcode project generated from a committed XcodeGen specification.
- Correct, catalog-driven challenge totals throughout the interface.
- Fixed “Show all” behavior and difficulty-based CTF scoring.
- Deterministic catalog validation and XCTest coverage.
- macOS CI that type-checks and compiles the application and test bundle.
- Central application metadata and visual design tokens.
- Repository-owned screenshots and a complete 30-challenge README catalog.
- MIT license, changelog, contribution guidance, and security policy.

### Asset notice

`EvilCorp-1.1.1-unsigned.ipa` is intentionally **unsigned**. It must be signed with your own
development identity before installation. Use only a dedicated simulator or disposable lab
device with synthetic data; do not install this intentionally vulnerable application on a
personal or production device.
