import SwiftUI

struct PhishingChallengeView: View {
    @State private var phishUser = ""
    @State private var phishPass = ""
    @State private var captured: [(String, String)] = []
    @State private var showFakeAlert = false
    @State private var showOverlay = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Multiple phishing vectors: fake system alert, UI redressing overlay, and URL scheme credential capture. Demonstrates how users are tricked into revealing credentials.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                // 1. Fake Alert
                Text("1. FAKE SECURITY ALERT").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.red)

                Button(action: { showFakeAlert = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 10))
                        Text("TRIGGER FAKE ALERT").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .alert("Security Breach Detected", isPresented: $showFakeAlert) {
                    SecureField("Password", text: $phishPass)
                    Button("Verify") { captured.append(("Fake Alert", phishPass)); phishPass = "" }
                    Button("Cancel", role: .cancel) {}
                } message: { Text("Your account was accessed from Moscow. Verify your password to secure it.") }

                // 2. UI Redressing
                Text("2. UI REDRESSING OVERLAY").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.red)

                ZStack {
                    VStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill").font(.title2).foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                        Text("Secure Banking").font(.system(size: 12, weight: .semibold, design: .monospaced)).foregroundColor(.white)
                        Text("Your account is safe").font(.system(size: 9, design: .monospaced)).foregroundColor(Color(white: 0.4))
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(Color(red: 0, green: 1, blue: 0.25).opacity(0.04))
                    .cornerRadius(8)

                    VStack(spacing: 8) {
                        Text("SESSION EXPIRED").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.red)
                        TextField("Username", text: $phishUser)
                            .textFieldStyle(.plain).padding(8)
                            .background(Color.white.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            .cornerRadius(6)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                            .font(.system(size: 11, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        SecureField("Password", text: $phishPass)
                            .textFieldStyle(.plain).padding(8)
                            .background(Color.white.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            .cornerRadius(6)
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                            .font(.system(size: 11, design: .monospaced))
                        Button(action: {
                            if !phishUser.isEmpty { captured.append((phishUser, phishPass)); phishUser = ""; phishPass = "" }
                        }) {
                            Text("SUBMIT").font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20).padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.12))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .background(Color(red: 0.04, green: 0.04, blue: 0.06).opacity(0.97))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 20)
                }

                // 3. URL Scheme
                Text("3. URL SCHEME PHISHING").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.red)

                Button(action: {
                    if let url = URL(string: "evilcorp://login?user=phished&pass=stolen123") {
                        UIApplication.shared.open(url)
                        captured.append(("URL Phishing: phished", "stolen123"))
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "link").font(.system(size: 10))
                        Text("evilcorp://login?user=phished&pass=stolen123").font(.system(size: 9, design: .monospaced)).lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if !captured.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("CAPTURED CREDENTIALS").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        ForEach(captured.indices, id: \.self) { i in
                            Text("[\(captured[i].0)] \(captured[i].1)")
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
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }
}
