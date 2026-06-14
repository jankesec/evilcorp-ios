import SwiftUI

struct MoreTabView: View {
    @ObservedObject var progress = ChallengeProgress()
    @State private var showResetAlert = false
    @State private var selectedSection = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedSection) {
                Text("Frida").tag(0); Text("Resources").tag(1); Text("Settings").tag(2)
            }.pickerStyle(.segmented).padding(.horizontal).padding(.vertical, 8)

            TabView(selection: $selectedSection) {
                FridaLibraryView().tag(0)
                ResourcesView().tag(1)
                SettingsView(progress: progress, showResetAlert: $showResetAlert).tag(2)
            }.tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(EC.bg)
        .alert("Reset All Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                progress.completed.removeAll()
                progress.bookmarks.removeAll()
                progress.ctfScore = 0
                progress.ctfMode = false
                UserDefaults.standard.removeObject(forKey: "evilcorp_completed")
                UserDefaults.standard.removeObject(forKey: "evilcorp_bookmarks")
            }
        } message: { Text("This will clear all completed challenges, bookmarks, and CTF progress. This cannot be undone.") }
    }
}

// MARK: - Frida Library
struct FridaLibraryView: View {
    @State private var search = ""

    var scripts: [(String, String, String)] {
        EvilCorpChallenge.all.map { ($0.title, $0.id, $0.fridaSnippet) }
    }

    var filtered: [(String, String, String)] {
        search.isEmpty ? scripts : scripts.filter { $0.0.localizedCaseInsensitiveContains(search) || $0.2.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search scripts...", text: $search).foregroundColor(.white)
                if !search.isEmpty { Button { search = "" } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.gray) } }
            }.padding(10).background(EC.card).cornerRadius(10).padding(.horizontal).padding(.vertical, 6)

            ScrollView {
                LazyVStack(spacing: 10) {
                    Text("\(filtered.count) scripts").font(.caption).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)

                    ForEach(filtered, id: \.1) { title, id, snippet in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(title).font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                                Spacer()
                                Text("frida -U -l bypass.js com.evilcorp.ios").font(.system(size: 9, design: .monospaced)).foregroundColor(.gray)
                            }
                            Text(snippet)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.orange)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange.opacity(0.15)))
                            Text("Copy and run on your computer — not on the phone").font(.caption2).foregroundColor(.gray)
                        }
                        .padding().background(EC.card).cornerRadius(12)
                    }
                }.padding()
            }
        }.background(EC.bg)
    }
}

// MARK: - Resources
struct ResourcesView: View {
    let sections: [(String, String, [(String, String)])] = [
        ("Documentation", "book.fill", [
            ("OWASP MASVS", "https://mas.owasp.org"),
            ("OWASP MASTG", "https://mas.owasp.org/MASTG"),
            ("Frida Docs", "https://frida.re/docs"),
            ("Apple Security", "https://developer.apple.com/security"),
        ]),
        ("Tools", "wrench.and.screwdriver.fill", [
            ("Frida", "https://frida.re"),
            ("Objection", "https://github.com/sensepost/objection"),
            ("Ghidra", "https://ghidra-sre.org"),
            ("Hopper", "https://hopperapp.com"),
            ("Burp Suite", "https://portswigger.net/burp"),
            ("mitmproxy", "https://mitmproxy.org"),
        ]),
        ("Jailbreak Tools", "lock.open.fill", [
            ("Keychain-Dumper", "https://github.com/ptoomey3/Keychain-Dumper"),
            ("class-dump", "http://stevenygard.com/projects/class-dump"),
            ("ldid", "https://github.com/sbingner/ldid"),
            ("Clutch", "https://github.com/KJCracks/Clutch"),
        ]),
        ("Learning", "graduationcap.fill", [
            ("HackerOne iOS Reports", "https://hackerone.com/hacktivity?querystring=ios"),
            ("OST2 iOS RE", "https://ost2.fyi"),
            ("iOS Security Guide", "https://www.apple.com/business/docs/iOS_Security_Guide.pdf"),
        ]),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Learning Resources & Toolkit").font(.title2).fontWeight(.bold).foregroundColor(.white).padding(.top, 4)

                ForEach(sections, id: \.0) { title, icon, items in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: icon).foregroundColor(.white)
                            Text(title).font(.headline).foregroundColor(.white)
                        }
                        ForEach(items, id: \.0) { name, url in
                            Link(destination: URL(string: url)!) {
                                HStack {
                                    Text(name).font(.subheadline).foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.gray)
                                }
                                .padding(.vertical, 6).padding(.horizontal, 10)
                                .background(EC.card).cornerRadius(8)
                            }
                        }
                    }
                }

                Text("Setup Guide").font(.headline).foregroundColor(.white).padding(.top)
                Text("""
                1. Connect iPhone via USB
                2. Install Frida: pip3 install frida-tools
                3. Start frida-server on jailbroken device
                4. Run: frida-ps -U to verify connection
                5. Use scripts from Frida Library tab
                """).font(.caption).foregroundColor(.gray).padding().background(EC.card).cornerRadius(12)

                Spacer()
            }.padding()
        }.background(EC.bg)
    }
}

// MARK: - Settings
struct SettingsView: View {
    @ObservedObject var progress: ChallengeProgress
    @Binding var showResetAlert: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Settings").font(.title2).fontWeight(.bold).foregroundColor(.white).padding(.top, 4)

                SettingsRow(icon: "arrow.counterclockwise", title: "Reset Progress", subtitle: "Clear all completions, bookmarks, CTF", color: .red) {
                    showResetAlert = true
                }

                SettingsRow(icon: "link", title: "GitHub Repository", subtitle: "github.com/byjanke/evilcorp-ios", color: .white) {
                    if let url = URL(string: "https://github.com/byjanke/evilcorp-ios") { UIApplication.shared.open(url) }
                }

                SettingsRow(icon: "square.and.arrow.up", title: "Share App", subtitle: "Tell others about EvilCorp", color: .blue) {
                    let text = "Check out EvilCorp iOS — 27 vulnerable iOS challenges for security training: https://github.com/byjanke/evilcorp-ios"
                    let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        root.present(av, animated: true)
                    }
                }

                SettingsRow(icon: "info.circle", title: "Version", subtitle: "v1.0 · 27 Challenges · 3.3 MB", color: .gray) {}

                SettingsRow(icon: "cup.and.saucer.fill", title: "Support", subtitle: "buymeacoffee.com/sevbandonmez", color: .orange) {
                    if let url = URL(string: "https://buymeacoffee.com/sevbandonmez") { UIApplication.shared.open(url) }
                }
            }.padding()
        }.background(EC.bg)
    }
}

struct SettingsRow: View {
    let icon: String; let title: String; let subtitle: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundColor(color).frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline).foregroundColor(.white)
                    Text(subtitle).font(.caption).foregroundColor(.gray)
                }
                Spacer()
                if icon != "info.circle" { Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray) }
            }
            .padding(12).background(EC.card).cornerRadius(10)
        }
    }
}
