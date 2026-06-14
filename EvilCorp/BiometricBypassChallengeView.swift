import SwiftUI
import LocalAuthentication

struct BiometricBypassChallengeView: View {
    @State private var status = "Not authenticated"
    @State private var isUnlocked = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Biometric auth via LAContext. Client-side only check, bypassable with Frida.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(isUnlocked ? Color(red: 0, green: 1, blue: 0.25) : .red)
                        Text(status).font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(isUnlocked ? Color(red: 0, green: 1, blue: 0.25) : .red)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)

                Button(action: {
                    let ctx = LAContext()
                    guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
                        status = "Biometrics not available"; return
                    }
                    ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock EvilCorp Vault") { ok, _ in
                        DispatchQueue.main.async {
                            isUnlocked = ok
                            status = ok ? "Unlocked! Access granted." : "Auth failed"
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid").font(.system(size: 10))
                        Text("AUTHENTICATE").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if isUnlocked {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text("VAULT CONTENTS:\nAPI_KEY=sk_evilcorp_protected_7f3a9e1b\nDB_PASS=evilcorp_db_master_2024\nENCRYPTION_KEY=evilcorp_aes_key_256bit")
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

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Bypass: Frida hook LAContext['- evaluatePolicy:localizedReason:reply:'] -> force success callback")
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
