import SwiftUI

struct URLSchemeChallengeView: View {
    @State private var receivedURL = ""
    @State private var params: [String: String] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Custom URL scheme vulnerability. The app registers evilcorp:// and processes parameters without validation. Attack via web pages, SMS, or other apps.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                VStack(spacing: 6) {
                    ForEach(["evilcorp://login?user=admin&pass=hacked",
                             "evilcorp://transfer?to=attacker&amount=9999",
                             "evilcorp://debug?cmd=dump_secrets",
                             "evilcorp://reset?email=victim@evilcorp.com"], id: \.self) { url in
                        Button(action: {
                            if let u = URL(string: url) {
                                UIApplication.shared.open(u)
                                receivedURL = url
                                let comps = URLComponents(url: u, resolvingAgainstBaseURL: false)
                                params = [:]
                                comps?.queryItems?.forEach { params[$0.name] = $0.value ?? "" }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "link").font(.system(size: 10))
                                Text(url).font(.system(size: 9, design: .monospaced)).lineLimit(1)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !receivedURL.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text("Intercepted URL:").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                        Text(receivedURL).font(.system(size: 10, design: .monospaced)).foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                        ForEach(Array(params.keys.sorted()), id: \.self) { key in
                            Text("  \(key) = \(params[key] ?? "")")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("[!] No input validation on URL parameters\n[!] Sensitive actions triggered without user confirmation\n[!] Attack vector: <a href='evilcorp://...'> on any webpage")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }
}
