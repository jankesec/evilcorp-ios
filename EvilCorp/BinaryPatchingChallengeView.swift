import SwiftUI

let LICENSE_VALID_KEY = "license_valid"
let PREMIUM_ACTIVE_KEY = "premium_active"

struct BinaryPatchingChallengeView: View {
    @State private var licenseStatus = checkLicense()
    @State private var premiumStatus = checkPremium()
    @State private var isPatched = false
    @State private var flagOutput = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Binary patching challenge: runtime checks for license & premium status. Patch the Mach-O binary or use Frida to modify return values at runtime.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                VStack(spacing: 8) {
                    StatusCard(title: "License Validation", status: licenseStatus, icon: "checkmark.seal")
                    StatusCard(title: "Premium Features", status: premiumStatus, icon: "star.fill")
                }

                HStack(spacing: 8) {
                    Button(action: {
                        licenseStatus = checkLicense()
                        premiumStatus = checkPremium()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise").font(.system(size: 10))
                            Text("RE-CHECK").font(.system(size: 11, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        isPatched = true
                        flagOutput = "[+] FLAG: EVILCORP{B1N4RY_P4TCH1NG_M4ST3R}\n[+] Premium unlocked!\n[+] Method: Patch IsLicenseValid() -> return true\n[+] Method: Patch IsPremiumActive() -> return true\n[+] Tools: Hopper/IDA -> MOV X0, #1 ; RET"
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "hammer.fill").font(.system(size: 10))
                            Text("SIMULATE PATCH").font(.system(size: 11, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0, green: 1, blue: 0.25))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }

                if isPatched {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text(flagOutput)
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
                    Text("Frida bypass:\nvar ptr = Module.findExportByName(null, 'IsLicenseValid');\nInterceptor.attach(ptr, { onLeave: function(r) { r.replace(1); } });")
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

struct StatusCard: View {
    let title: String
    let status: Bool
    let icon: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(status ? Color(red: 0, green: 1, blue: 0.25) : .red)
                .font(.system(size: 12))
            Text(title).font(.system(size: 11, weight: .medium, design: .monospaced)).foregroundColor(.white)
            Spacer()
            Text(status ? "VALID" : "LOCKED")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(status ? Color(red: 0, green: 1, blue: 0.25) : .red)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background((status ? Color(red: 0, green: 1, blue: 0.25) : Color.red).opacity(0.12))
                .cornerRadius(4)
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
    }
}

func checkLicense() -> Bool { return false }
func checkPremium() -> Bool { return false }
