## EvilCorp iOS v1.2.0

A reliability release: progress tracking and CTF scoring now behave correctly, several
screens lost long-standing bugs, and CI runs the unit tests on an iOS Simulator. The
intentionally vulnerable behavior of the 30 named labs is unchanged.

### Highlights

- CTF score can no longer be inflated by toggling a challenge on and off.
- An active CTF session survives an app relaunch.
- "Reset Progress" resets every screen, not a hidden copy of the progress.
- Onboarding "Next" advances pages; Settings show the correct repository, count, and version.
- The SQLite lab no longer crashes on format specifiers in the username.
- Always-on location requests in the Excessive Permissions lab work again.
- The app uses the full display on current iPhones (launch screen definition added).
- Harvested contacts are masked before they reach the system log.
- New progress and scoring tests; CI runs them on an iOS Simulator.

### Asset notice

`EvilCorp-1.2.0-unsigned.ipa` is intentionally **unsigned**. It must be signed with your own
development identity before installation. Use only a dedicated simulator or disposable lab
device with synthetic data; do not install this intentionally vulnerable application on a
personal or production device.
