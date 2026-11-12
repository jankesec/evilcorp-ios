import SwiftUI

/// Maps a catalog identifier to its lab screen.
///
/// This is the only place that knows which view belongs to which challenge. A unit test checks
/// that every catalog entry is registered here, so adding a challenge without a screen fails CI
/// instead of silently showing a placeholder.
enum LabRegistry {
  static let registeredIDs: Set<String> = [
    "userdefaults", "keychain", "plist", "sqlite", "jailbreak", "sslpinning", "webviewxss",
    "logging", "hardcodedsecrets", "biometricbypass", "cryptography", "network", "urlscheme",
    "screenshot", "antidebug", "pasteboard", "filesharing", "keyboard", "binarypatch",
    "pinbruteforce", "urlcache", "excessiveperms", "phishing", "memorysensitive", "xpc",
    "localdata", "deviceinfo", "randomgen", "pathtraversal", "bgfetch",
  ]

  @ViewBuilder
  static func view(for id: String) -> some View {
    switch id {
    case "userdefaults": UserDefaultsChallengeView()
    case "keychain": KeychainChallengeView()
    case "plist": PlistChallengeView()
    case "sqlite": SQLiteChallengeView()
    case "jailbreak": JailbreakChallengeView()
    case "sslpinning": SSLPinningChallengeView()
    case "webviewxss": WebViewXSSChallengeView()
    case "logging": LoggingChallengeView()
    case "hardcodedsecrets": HardcodedSecretsChallengeView()
    case "biometricbypass": BiometricBypassChallengeView()
    case "cryptography": CryptoChallengeView()
    case "network": NetworkChallengeView()
    case "urlscheme": URLSchemeChallengeView()
    case "screenshot": ScreenshotLeakChallengeView()
    case "antidebug": AntiDebugChallengeView()
    case "pasteboard": PasteboardChallengeView()
    case "filesharing": FileSharingChallengeView()
    case "keyboard": KeyboardCacheChallengeView()
    case "binarypatch": BinaryPatchingChallengeView()
    case "pinbruteforce": PinBruteforceView()
    case "urlcache": URLCacheChallengeView()
    case "excessiveperms": ExcessivePermsChallengeView()
    case "phishing": PhishingChallengeView()
    case "memorysensitive": MemorySensitiveChallengeView()
    case "xpc": XPCChallengeView()
    case "localdata": LocalDataStorageView()
    case "randomgen": RandomGenChallengeView()
    case "pathtraversal": PathTraversalChallengeView()
    case "bgfetch": BackgroundFetchChallengeView()
    case "deviceinfo": DeviceInfoView()
    default:
      Text("This challenge has no lab screen yet.").font(.caption).foregroundColor(.gray)
    }
  }
}
