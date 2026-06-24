# EvilCorp iOS

**Intentionally vulnerable iOS application for mobile security training — 30 challenges across OWASP MASVS categories.**

[![Swift](https://img.shields.io/badge/Swift-5.0-orange?style=flat&logo=swift)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16%2B-black?style=flat&logo=apple)](https://apple.com/ios)
[![License](https://img.shields.io/badge/license-GPLv3-blue?style=flat)](LICENSE)
[![Challenges](https://img.shields.io/badge/challenges-30-green?style=flat)]()
[![Size](https://img.shields.io/badge/binary-3.1MB%20arm64-lightgrey?style=flat)]()

EvilCorp is an intentionally vulnerable iOS application built for **mobile security training**. Each of the **30 challenges** maps to real-world vulnerability classes (CWE), OWASP MASVS requirements, and MASWE weaknesses — making it a hands-on lab for practicing iOS penetration testing, reverse engineering, and dynamic instrumentation with Frida.

The app features a modern SwiftUI interface with progress tracking, CTF mode, live console, per-challenge Frida scripts, and a multi-tab local data storage explorer — all in a single 3.3 MB arm64 binary.

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                   EvilCorp iOS                       │
├────────────┬────────────┬─────────────┬──────────────┤
│  Home      │  Labs      │  MASVS      │  Console     │
│  · Stats   │  · Search  │  · Checklist│ · Live logs  │
│  · CTF     │  · Filter  │  · Coverage │ · Filter     │
│  · Cards   │  · Tags    │  · Gaps     │ · Auto-scroll│
├────────────┴────────────┴─────────────┴──────────────┤
│              Challenge Detail (per vuln)             │
│    Lab  │  Hints (3 levels)  │  Frida Script         │
├──────────────────────────────────────────────────────┤
│  25 self-contained SwiftUI views + 5 service files   │
│  arm64 · 3.1 MB · parse-as-library · iOS 16+         │
└──────────────────────────────────────────────────────┘
```

---

## Screenshots

<div align="center">
  <img src="https://i.ibb.co/380Y5Hz/Console.jpg" alt="Home" width="150"/>
  <img src="https://i.ibb.co/tTmDMxh0/Device.jpg" alt="Labs" width="150"/>
  <img src="https://i.ibb.co/DDx3JyJX/Extras.jpg" alt="MASVS" width="150"/>
  <img src="https://i.ibb.co/vCXKFhvV/Home.jpg" alt="Progress" width="150"/>
  <img src="https://i.ibb.co/MyFP0jYm/Labs.jpg" alt="Console" width="150"/>
  <br>
  <sub>Home · Labs · MASVS · Progress · Console</sub>
  <br><br>
  <img src="https://i.ibb.co/3y0GPt18/MASVS.jpg" alt="Device" width="150"/>
  <img src="https://i.ibb.co/qYXb3yry/More.jpg" alt="Extras" width="150"/>
  <img src="https://i.ibb.co/kRYpGLp/Progress.jpg" alt="Resources" width="150"/>
  <img src="https://i.ibb.co/L4btCwD/Resources.jpg" alt="Settings" width="150"/>
  <img src="https://i.ibb.co/nMJC6f1F/Settings.jpg" alt="More" width="150"/>
  <br>
  <sub>Device · Extras · Resources · Settings · More</sub>
</div>

---

## Challenges

| # | Challenge | Category | Difficulty | CWE | MASVS | MASWE | CVSS |
|---|-----------|----------|------------|-----|-------|-------|------|
| 1 | NSUserDefaults Storage | Storage | Easy | CWE-312 | STORAGE-1 | MASWE-0010 | 5.0 |
| 2 | Keychain Misuse | Storage | Easy | CWE-922 | STORAGE-1 | MASWE-0011 | 6.8 |
| 3 | Property List Files | Storage | Easy | CWE-312 | STORAGE-1 | MASWE-0010 | 5.0 |
| 4 | SQLite Injection | Storage | Medium | CWE-89 | STORAGE-1 | MASWE-0015 | 7.5 |
| 5 | Jailbreak Detection | Auth | Medium | CWE-693 | RESILIENCE-1 | MASWE-0095 | 4.3 |
| 6 | SSL Pinning Bypass | Network | Medium | CWE-295 | NETWORK-2 | MASWE-0061 | 5.9 |
| 7 | WebView XSS | Network | Medium | CWE-79 | PLATFORM-2 | MASWE-0057 | 6.1 |
| 8 | Insecure Logging | Storage | Easy | CWE-532 | STORAGE-3 | MASWE-0005 | 4.0 |
| 9 | Hardcoded Secrets | Storage | Medium | CWE-798 | STORAGE-1 | MASWE-0062 | 7.8 |
| 10 | Biometric Bypass | Auth | Hard | CWE-287 | AUTH-1 | MASWE-0025 | 6.8 |
| 11 | Broken Cryptography | Crypto | Medium | CWE-327 | CRYPTO-1 | MASWE-0048 | 7.5 |
| 12 | Insecure Network (HTTP) | Network | Medium | CWE-319 | NETWORK-1 | MASWE-0046 | 6.5 |
| 13 | URL Scheme Hijacking | Network | Medium | CWE-939 | PLATFORM-2 | MASWE-0056 | 6.5 |
| 14 | Screenshot Leakage | Storage | Easy | CWE-200 | STORAGE-3 | MASWE-0042 | 3.3 |
| 15 | Anti-Debugging Bypass | Auth | Hard | CWE-693 | RESILIENCE-4 | MASWE-0096 | 5.5 |
| 16 | Pasteboard Leakage | Storage | Easy | CWE-200 | STORAGE-3 | MASWE-0042 | 2.4 |
| 17 | iTunes File Sharing | Storage | Medium | CWE-200 | STORAGE-2 | MASWE-0010 | 4.6 |
| 18 | Keyboard Cache Leak | Storage | Easy | CWE-200 | STORAGE-3 | MASWE-0042 | 2.4 |
| 19 | Binary Patching | Crypto | Hard | CWE-1275 | RESILIENCE-4 | MASWE-0096 | 6.5 |
| 20 | Vulnerable Vault (PIN) | Auth | Hard | CWE-307 | AUTH-1 | MASWE-0025 | 7.5 |
| 21 | NSURLSession Cache | Network | Medium | CWE-200 | STORAGE-3 | MASWE-0010 | 5.0 |
| 22 | Excessive Permissions | Storage | Medium | CWE-863 | PLATFORM-1 | MASWE-0098 | 5.5 |
| 23 | Phishing & UI Redressing | Network | Medium | CWE-1021 | PLATFORM-2 | MASWE-0099 | 6.5 |
| 24 | Memory Sensitive Data | Storage | Hard | CWE-316 | STORAGE-3 | MASWE-0043 | 6.8 |
| 25 | XPC/IPC Communication | Network | Hard | CWE-306 | PLATFORM-2 | MASWE-0056 | 7.5 |

---

## Quick Start

### Option 1: Download IPA (Recommended)

Download the latest IPA from [Releases](https://github.com/byjanke/evilcorp-iosios/releases/latest).

**Jailbroken Device (rootless: Dopamine, palera1n, XinaA15):**
```bash
unzip EvilCorp-v1.0.ipa
scp -r Payload/EvilCorp.app root@<DEVICE_IP>:/var/root/
ssh root@<DEVICE_IP>
cp -r /var/root/EvilCorp.app /var/jb/Applications/
ldid -S ent.plist /var/jb/Applications/EvilCorp.app/EvilCorp
uicache -a && killall -9 SpringBoard
```

**Non-Jailbroken Device (Sideload):**

| Method | Duration | Guide |
|--------|----------|-------|
| **AltStore** | 7 days (free) / 1 year (paid) | [altstore.io](https://altstore.io) |
| **Sideloadly** | 7 days (free) | [sideloadly.io](https://sideloadly.io) |
| **TrollStore** | Permanent (iOS 14-16.5) | [github.com/opa334/TrollStore](https://github.com/opa334/TrollStore) |
| **Xcode** | 7 days (free Apple ID) | Xcode → Devices → Install |

> Sideloaded apps require re-signing every 7 days with a free Apple ID. TrollStore provides permanent installation on compatible iOS versions.

### Option 2: Build from Source

```bash
git clone https://github.com/byjanke/evilcorp-iosios
cd evilcorp-ios

# Single-command build
swiftc -sdk $(xcrun --sdk iphoneos --show-sdk-path) \
  -target arm64-apple-ios16.0 -O -parse-as-library \
  -framework SwiftUI WebKit LocalAuthentication Security \
  AVFoundation Contacts CoreLocation Photos \
  -o EvilCorp.app/EvilCorp EvilCorp/*.swift

# Package as IPA
mkdir -p Payload/EvilCorp.app
cp EvilCorp.app/EvilCorp EvilCorp/Info.plist EvilCorp/evilcorp.jpg Payload/EvilCorp.app/
zip -r EvilCorp.ipa Payload/
```

---

## Features

### Core
- **25 vulnerabilities** across Storage, Network, Crypto, Auth
- **Self-contained SwiftUI** — zero external dependencies
- **Single-file build** — `swiftc EvilCorp/*.swift`
- **3.1 MB** arm64 binary, iOS 16+

### Interactive
- **5 tabs**: Home · Labs · MASVS · Progress · Console
- **Live Console** — in-app NSLog viewer with filter
- **CTF Mode** — timed challenges with scoring (100/200/300 pts)
- **Progress Tracking** — persistent completion state, ring chart, per-category bars
- **Smart Search** — CWE, MASVS, MASWE, keyword filtering

### Per-Challenge
- **Lab** — interactive vulnerability demo
- **Hints** — 3 progressive reveal levels
- **Frida Script** — copy-paste ready bypass scripts

### Security Config (Deliberately Vulnerable)
- `NSAllowsArbitraryLoads = true` — ATS disabled
- `UIFileSharingEnabled = true` — USB file access
- `evilcorp://` URL scheme — no input validation
- `kSecAttrAccessibleAlways` — Keychain accessible when locked

---

## Pentest Quick Wins

```bash
# Extract hardcoded secrets from binary
grep -ao 'sk_live_evilcorp\|AKIA_EVILCORP\|EvilCorp_Super' EvilCorp

# Read UserDefaults plist
cat /var/mobile/Containers/Data/*/Library/Preferences/com.evilcorp.ios.plist | plutil -p -

# Dump SQLite database
sqlite3 /var/mobile/Containers/Data/*/Documents/evilcorp.db "SELECT * FROM users;"

# Intercept HTTP traffic (ATS disabled)
mitmproxy --mode transparent

# Capture credentials from system logs
idevicesyslog | grep EVILCORP_AUTH

# Bypass SSL pinning
objection -g com.evilcorp.ios run ios sslpinning disable

# Dump Keychain
./keychain_dumper -a | grep evilcorp
```



## Project Structure

```
EvilCorp-iOS/
├── README.md
├── LICENSE
├── .gitignore
├── EvilCorp/
│   ├── EvilCorpApp.swift              # @main entry point
│   ├── ContentView.swift              # All UI (tabs, detail, components)
│   ├── EvilCorpChallenge.swift        # 25 challenge data model
│   ├── Info.plist                     # ATS bypass + URL scheme
│   ├── evilcorp.jpg                   # App logo
│   ├── UserDefaultsChallengeView.swift
│   ├── KeychainChallengeView.swift
│   ├── PlistChallengeView.swift
│   ├── SQLiteChallengeView.swift
│   ├── JailbreakChallengeView.swift
│   ├── SSLPinningChallengeView.swift
│   ├── WebViewXSSChallengeView.swift
│   ├── LoggingChallengeView.swift
│   ├── HardcodedSecretsChallengeView.swift
│   ├── BiometricBypassChallengeView.swift
│   ├── CryptoChallengeView.swift
│   ├── NetworkChallengeView.swift
│   ├── URLSchemeChallengeView.swift
│   ├── ScreenshotLeakChallengeView.swift
│   ├── AntiDebugChallengeView.swift
│   ├── PasteboardChallengeView.swift
│   ├── FileSharingChallengeView.swift
│   ├── KeyboardCacheChallengeView.swift
│   ├── BinaryPatchingChallengeView.swift
│   ├── PinBruteforceView.swift
│   ├── URLCacheChallengeView.swift
│   ├── ExcessivePermsChallengeView.swift
│   ├── PhishingChallengeView.swift
│   ├── MemorySensitiveChallengeView.swift
│   └── XPCChallengeView.swift
```

---

## Vulnerability-to-MASVS Mapping

| MASVS | Challenges |
|-------|-----------|
| STORAGE-1 | #1, #2, #3, #4, #9 |
| STORAGE-2 | #17 |
| STORAGE-3 | #8, #14, #16, #18, #21, #24 |
| CRYPTO-1 | #11 |
| NETWORK-1 | #12 |
| NETWORK-2 | #6 |
| AUTH-1 | #10, #20 |
| RESILIENCE-1 | #5 |
| RESILIENCE-4 | #15, #19 |
| PLATFORM-1 | #22 |
| PLATFORM-2 | #7, #13, #23, #25 |

---

## Tools Used

| Category | Tools |
|----------|-------|
| Static Analysis | Hopper, Ghidra, IDA Pro, radare2, class-dump, strings |
| Dynamic Analysis | Frida, Objection, lldb |
| Network | Burp Suite, mitmproxy, Wireshark |
| Data Extraction | Keychain-Dumper, SQLite CLI, plutil |
| Deployment | ldid, scp, uicache |

---

## Disclaimer

This application is **for educational purposes only**. Do not deploy on production devices or use on systems you do not own. The developers assume no liability for misuse.

## Support

If you found this project helpful:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sevbandonmez-FFDD00?style=flat&logo=buymeacoffee&logoColor=black)](https://www.buymeacoffee.com/sevbandonmez)

## License

GPLv3 — see [LICENSE](LICENSE)
