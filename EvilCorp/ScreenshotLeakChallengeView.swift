import SwiftUI

struct ScreenshotLeakChallengeView: View {
    @State private var showSensitive = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("iOS takes a screenshot when app backgrounds for the App Switcher. This app does NOT hide sensitive data, leaving it visible in the app switcher preview.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: { showSensitive.toggle() }) {
                    HStack(spacing: 8) {
                        Image(systemName: showSensitive ? "eye.slash.fill" : "eye.fill").font(.system(size: 10))
                        Text(showSensitive ? "HIDE DATA" : "SHOW SENSITIVE DATA").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if showSensitive {
                    VStack(spacing: 8) {
                        SensitiveField(label: "Account #", value: "9876-5432-1098-7654")
                        SensitiveField(label: "Routing #", value: "021000021")
                        SensitiveField(label: "SSN", value: "987-65-4321")
                        SensitiveField(label: "DOB", value: "03/15/1986")
                        SensitiveField(label: "API Key", value: "sk_live_evilcorp_banking_key")
                        SensitiveField(label: "Master Password", value: "EvilCorp.Vault.Master.2024!")
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.06))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.2), lineWidth: 1))

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.red).frame(width: 6, height: 6)
                            Text("WARNING").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text("PRESS HOME BUTTON NOW -> check App Switcher\nSensitive data will be VISIBLE in the preview!")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.red)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.2), lineWidth: 1))
                }

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("[!] Missing: UIApplication.willResignActiveNotification handler\n[!] No screen blur or content hiding on background\n[!] Data visible without authentication in App Switcher")
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

struct SensitiveField: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.system(size: 10, design: .monospaced)).foregroundColor(Color(white: 0.5)).frame(width: 100, alignment: .leading)
            Text(value).font(.system(size: 10, weight: .semibold, design: .monospaced)).foregroundColor(.red)
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}
