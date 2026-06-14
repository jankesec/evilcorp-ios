import SwiftUI

struct KeyboardCacheChallengeView: View {
    @State private var textInput = ""
    @State private var output = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("iOS keyboard autocorrect and predictive text cache sensitive input. UITextField without secureTextEntry stores input in keyboard cache, discoverable via forensic tools.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Text("VULNERABLE FIELD (PLAIN TEXTFIELD):").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(.red)

                TextField("Enter password...", text: $textInput)
                    .textFieldStyle(.plain).padding(10)
                    .background(Color.red.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    .cornerRadius(6)
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                    .font(.system(size: 13, design: .monospaced))

                Text("SECURE FIELD (SECUREFIELD):").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(red: 0, green: 1, blue: 0.25))

                SecureField("Enter password...", text: .constant(""))
                    .textFieldStyle(.plain).padding(10)
                    .background(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
                    .cornerRadius(6)
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                    .font(.system(size: 13, design: .monospaced))
                    .disabled(true)

                Button(action: {
                    output = "[+] TextField value logged to keyboard cache\n[+] Path: Library/Keyboard/*.dat\n[+] Extract with forensic tools (Cellebrite, Magnet AXIOM)\n[+] Value: '\(textInput)' discoverable\n[!] Fix: Use SecureField + disable autocorrection"
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "keyboard").font(.system(size: 10))
                        Text("SIMULATE CACHE LEAK").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.12))
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

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("[!] UITextField caches input for autocorrect\n[!] Plain TextField is NOT suitable for passwords\n[!] Always use SecureField + disable autocorrection\n[!] Consider UITextContentType for sensitive fields")
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
