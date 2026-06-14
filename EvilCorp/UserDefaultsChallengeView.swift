import SwiftUI

struct UserDefaultsChallengeView: View {
    @State private var output = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Sensitive data stored in NSUserDefaults without encryption. Extractable via plist file.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: {
                    let prefs = UserDefaults.standard
                    prefs.set("admin@evilcorp.local", forKey: "user_email")
                    prefs.set("EvilCorp_Super_Secret_2024!", forKey: "user_password")
                    prefs.set("4532123456789012", forKey: "credit_card_number")
                    prefs.set("123", forKey: "credit_card_cvv")
                    prefs.set("sk_live_evilcorp_api_key_7f3a9e1b", forKey: "api_secret")
                    prefs.synchronize()
                    output = "[+] Credentials stored\n[+] Path: Library/Preferences/com.evilcorp.ios.plist\n[+] Extract: scp from device or use objection"
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down.fill").font(.system(size: 10))
                        Text("STORE CREDENTIALS").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button(action: {
                    let prefs = UserDefaults.standard
                    let items: [(String, Any?)] = [
                        ("user_email", prefs.string(forKey: "user_email")),
                        ("user_password", prefs.string(forKey: "user_password")),
                        ("credit_card_number", prefs.string(forKey: "credit_card_number")),
                        ("credit_card_cvv", prefs.string(forKey: "credit_card_cvv")),
                        ("api_secret", prefs.string(forKey: "api_secret"))
                    ]
                    output = items.map { "[\($0.0)] \($0.1 ?? "nil")" }.joined(separator: "\n")
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.magnifyingglass").font(.system(size: 10))
                        Text("READ STORED DATA").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if !output.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text(output)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                            .textSelection(.enabled)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }
}
