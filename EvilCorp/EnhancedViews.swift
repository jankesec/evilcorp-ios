import SwiftUI

// MARK: - Achievements
// MARK: - Security Status Bar
struct SecurityStatusBar: View {
    let jbCheck = FileManager.default.fileExists(atPath: "/var/jb")
    
    var body: some View {
        HStack(spacing: 14) {
            StatusChip(icon: "lock.open.fill", label: "ATS OFF", color: .red, active: true)
            StatusChip(icon: "antenna.radiowaves.left.and.right", label: "HTTP OK", color: .orange, active: true)
            StatusChip(icon: jbCheck ? "exclamationmark.shield.fill" : "checkmark.shield.fill", label: jbCheck ? "JB" : "CLEAN", color: jbCheck ? .red : .green, active: true)
            StatusChip(icon: "doc.fill", label: "FILESHARE", color: .orange, active: true)
            StatusChip(icon: "link", label: "evilcorp://", color: .cyan, active: true)
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(EC.card)
    }
}

struct StatusChip: View {
    let icon: String; let label: String; let color: Color; let active: Bool
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 7)).foregroundColor(active ? color : .gray)
            Text(label).font(.system(size: 7, weight: .bold, design: .monospaced)).foregroundColor(active ? color : .gray)
        }
    }
}

// MARK: - Onboarding
struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var page = 0
    
    let pages: [(String, String, String)] = [
        ("flask.fill", "Welcome to EvilCorp", "27 deliberately vulnerable iOS challenges for mobile security training. Each maps to CWE, MASVS, and MASWE standards."),
        ("square.grid.2x2.fill", "Learn by Exploiting", "Discover hardcoded secrets, bypass SSL pinning, exploit SQL injection, crack weak crypto — all in a safe lab environment."),
        ("terminal.fill", "Frida & Tools Ready", "Every challenge includes Frida scripts and progressive hints. Track progress, compete in CTF mode, and master iOS pentesting.")
    ]
    
    var body: some View {
        ZStack {
            EC.bg.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                TabView(selection: $page) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        VStack(spacing: 20) {
                            Image(systemName: pages[i].0).font(.system(size: 56)).foregroundColor(.white)
                            Text(pages[i].1).font(.title2).fontWeight(.bold).foregroundColor(.white)
                            Text(pages[i].2).font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal, 32)
                        }.tag(i)
                    }
                }.tabViewStyle(.page)
                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle().fill(i == page ? Color.white : Color.gray).frame(width: 6, height: 6)
                    }
                }
                
                Button(action: { withAnimation { showOnboarding = false } }) {
                    Text(page < pages.count - 1 ? "Next" : "Get Started")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.black)
                        .padding(.horizontal, 40).padding(.vertical, 12)
                        .background(Color.white).cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Achievements
struct AchievementBadge: View {
    let title: String; let icon: String; let unlocked: Bool; let count: Int; let total: Int
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(unlocked ? Color.white.opacity(0.15) : Color.gray.opacity(0.08)).frame(width: 56, height: 56)
                Image(systemName: unlocked ? icon : "lock.fill").font(.system(size: 22)).foregroundColor(unlocked ? .white : .gray)
            }
            Text(title).font(.system(size: 10, weight: .medium)).foregroundColor(unlocked ? .white : .gray)
            Text("\(count)/\(total)").font(.system(size: 9)).foregroundColor(unlocked ? .green : .gray)
        }
    }
}

// MARK: - Swipe Challenge Nav
struct SwipeableChallengeView: View {
    let challenge: EvilCorpChallenge
    @ObservedObject var progress: ChallengeProgress
    let onBack: () -> Void
    let onNext: () -> Void
    let onPrev: () -> Void
    @State private var section = 0
    @State private var hintLevel = 0
    @State private var showBookmark = false
    
    init(challenge: EvilCorpChallenge, progress: ChallengeProgress, onBack: @escaping () -> Void, onNext: @escaping () -> Void, onPrev: @escaping () -> Void) {
        self.challenge = challenge; self.progress = progress; self.onBack = onBack; self.onNext = onNext; self.onPrev = onPrev
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onPrev) { Image(systemName: "chevron.left").font(.body).foregroundColor(.white) }
                    .opacity(EvilCorpChallenge.all.first?.id == challenge.id ? 0.3 : 1)
                Spacer()
                VStack(spacing: 2) {
                    Text(challenge.title).font(.headline).foregroundColor(.white)
                    HStack(spacing: 6) {
                        BadgeView(challenge.cwe); BadgeView(challenge.masvs)
                        BadgeView(challenge.maswe, color: .cyan); BadgeView(challenge.cvss, color: .yellow)
                        BadgeView(challenge.difficulty, color: .orange)
                    }
                }
                Spacer()
                Button(action: onNext) { Image(systemName: "chevron.right").font(.body).foregroundColor(.white) }
                    .opacity(EvilCorpChallenge.all.last?.id == challenge.id ? 0.3 : 1)
            }.padding(.horizontal).padding(.vertical, 8)
            
            HStack(spacing: 16) {
                Button(action: { withAnimation { progress.toggle(challenge.id) } }) {
                    HStack(spacing: 4) {
                        Image(systemName: progress.isCompleted(challenge.id) ? "checkmark.seal.fill" : "checkmark.seal")
                            .foregroundColor(progress.isCompleted(challenge.id) ? .green : .gray)
                        Text(progress.isCompleted(challenge.id) ? "Solved" : "Mark Solved").font(.caption).foregroundColor(.gray)
                    }
                }
                Spacer()
                Button(action: { progress.toggleBookmark(challenge.id); showBookmark.toggle() }) {
                    Image(systemName: progress.isBookmarked(challenge.id) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(progress.isBookmarked(challenge.id) ? .orange : .gray)
                }
                Button(action: onBack) {
                    HStack(spacing: 2) { Image(systemName: "xmark"); Text("Close").font(.caption) }.foregroundColor(.gray)
                }
            }.padding(.horizontal).padding(.vertical, 4).background(EC.bg)
            
            Picker("", selection: $section) { Text("Lab").tag(0); Text("Hints").tag(1); Text("Frida").tag(2) }.pickerStyle(.segmented).padding(.horizontal).padding(.vertical, 4)
            
            TabView(selection: $section) {
                ScrollView { VStack(alignment: .leading, spacing: 12) {
                    Text(challenge.description).font(.subheadline).foregroundColor(.white).padding().frame(maxWidth: .infinity, alignment: .leading).background(EC.card).cornerRadius(10)
                    Text("Category: \(challenge.category) · Difficulty: \(challenge.difficulty)").font(.caption).foregroundColor(.gray)
                    Text("CWE: \(challenge.cwe) · MASVS: \(challenge.masvs)").font(.caption).foregroundColor(.gray)
                    Text("MASWE: \(challenge.maswe) · CVSS: \(challenge.cvss)").font(.caption).foregroundColor(.gray)
                    Divider().background(Color.white.opacity(0.1))
                    labView.padding(.top, 4)
                }.padding() }.tag(0)
                
                hintsScrollView.tag(1)
                fridaScrollView.tag(2)
            }.tabViewStyle(.page(indexDisplayMode: .never))
        }.background(EC.bg)
    }
    
    @ViewBuilder var labView: some View {
        switch challenge.id {
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
        default: Text("...").foregroundColor(.gray)
        }
    }
    
    var hintsScrollView: some View {
        ScrollView { VStack(alignment:.leading,spacing:16) {
            Text("Hints").font(.title2).fontWeight(.bold).foregroundColor(.white)
            ForEach(0..<min(hintLevel+1,challenge.hints.count),id:\.self){i in
                VStack(alignment:.leading,spacing:8) {
                    Text("Hint \(i+1)").font(.caption).fontWeight(.bold).foregroundColor(.orange).padding(.horizontal,6).padding(.vertical,2).background(Color.orange.opacity(0.15)).cornerRadius(4)
                    Text(challenge.hints[i]).font(.subheadline).foregroundColor(.white).padding().frame(maxWidth:.infinity,alignment:.leading).background(Color.white.opacity(0.04)).cornerRadius(10)
                }
            }
            if hintLevel < challenge.hints.count - 1 {
                Button{withAnimation{hintLevel+=1}}label:{ HStack{Image(systemName:"lightbulb.fill").foregroundColor(.yellow);Text("Reveal Hint \(hintLevel+2)").foregroundColor(.white)}.font(.subheadline).padding(.horizontal,16).padding(.vertical,10).background(Color.yellow.opacity(0.15)).cornerRadius(8) }
            }
            Spacer()
        }.padding() }.background(EC.bg)
    }
    
    var fridaScrollView: some View {
        ScrollView { VStack(alignment:.leading,spacing:16) {
            Text("Frida Script").font(.title2).fontWeight(.bold).foregroundColor(.white)
            Text("Run this on your computer (not on the phone):").font(.caption).foregroundColor(.orange)
            Text(challenge.fridaSnippet).font(.system(size:10,design:.monospaced)).foregroundColor(.white).padding(12).frame(maxWidth:.infinity,alignment:.leading).background(Color.black.opacity(0.5)).cornerRadius(10).overlay(RoundedRectangle(cornerRadius:10).stroke(Color.white.opacity(0.1)))
            VStack(alignment:.leading,spacing:6) {
                HStack(alignment:.top,spacing:6){Text("·").foregroundColor(.white);Text("Connect iPhone via USB to your Mac/PC").font(.subheadline).foregroundColor(.gray)}
                HStack(alignment:.top,spacing:6){Text("·").foregroundColor(.white);Text("Run: frida -U -l bypass.js com.evilcorp.ios").font(.subheadline).foregroundColor(.gray)}
            }
            Spacer()
        }.padding() }.background(EC.bg)
    }
}
