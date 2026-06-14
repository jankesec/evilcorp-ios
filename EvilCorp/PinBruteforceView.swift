import SwiftUI

struct PinBruteforceView: View {
    @State private var pinInput = ""
    @State private var attempts = 0
    @State private var isUnlocked = false
    @State private var vaultContent = ""
    @State private var isLocked = false

    let correctPin = "7384"
    let maxAttempts = 5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("A 4-digit PIN vault with NO rate limiting or lockout after failed attempts. Brute-force attack is trivial -- only 10,000 combinations to try.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: isUnlocked ? "lock.open.fill" : isLocked ? "lock.trianglebadge.exclamationmark.fill" : "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(isUnlocked ? Color(red: 0, green: 1, blue: 0.25) : isLocked ? .red : Color(white: 0.5))

                        HStack(spacing: 12) {
                            ForEach(0..<4) { i in
                                Circle()
                                    .strokeBorder(Color(red: 0, green: 1, blue: 0.25).opacity(0.3), lineWidth: 1)
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 10, height: 10)
                                            .opacity(i < pinInput.count ? 1 : 0)
                                    )
                            }
                        }

                        Text("Attempts: \(attempts) (No limit!)").font(.system(size: 9, design: .monospaced)).foregroundColor(Color(white: 0.4))
                    }
                    Spacer()
                }
                .padding(.vertical, 8)

                // Keypad
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 6) {
                    ForEach(["1","2","3","4","5","6","7","8","9","0"], id: \.self) { digit in
                        Button(action: {
                            if pinInput.count < 4 && !isUnlocked && !isLocked {
                                pinInput += digit
                                if pinInput.count == 4 { verifyPin() }
                            }
                        }) {
                            Text(digit)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button(action: { if !isUnlocked && !isLocked { pinInput = "" } }) {
                    HStack(spacing: 8) {
                        Image(systemName: "delete.left").font(.system(size: 10))
                        Text("CLEAR").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if isUnlocked {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text(vaultContent)
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

                if isLocked {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account locked? Actually NO -- there is no lockout! The app just pretends. Try more.")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.25))

                        Button(action: { isLocked = false; pinInput = ""; attempts = 0 }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise").font(.system(size: 10))
                                Text("RESET").font(.system(size: 11, weight: .semibold, design: .monospaced))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0, green: 1, blue: 0.25))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
                }

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("[!] No rate limiting -- unlimited attempts\n[!] No account lockout -- brute force in < 1 minute\n[!] 4-digit PIN = only 10,000 combinations\n[!] Frida: frida -U -l brute.js com.evilcorp.ios")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }

    func verifyPin() {
        attempts += 1
        if pinInput == correctPin {
            isUnlocked = true
            vaultContent = "[+] FLAG: EVILCORP{BRUT3_F0RC3_M4ST3R}\n[+] Vault PIN: \(correctPin)\n[+] Method: No rate limit allowed brute-force"
        } else if attempts >= maxAttempts {
            isLocked = true
            pinInput = ""
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { pinInput = "" }
        }
    }
}
