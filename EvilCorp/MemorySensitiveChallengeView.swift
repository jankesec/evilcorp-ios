import SwiftUI

struct MemorySensitiveChallengeView: View {
    @State private var isLoaded = false
    @State private var output = ""

    struct InMemoryData {
        static let apiKey = "sk_live_evilcorp_memory_dump_key_9f8e7d6c"
        static let jwtToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiJ9.evilcorp_memory_token"
        static let dbPassword = "EvilCorp.DB.Master.InMemory.2024!"
        static let encryptionKey: [UInt8] = [0xE, 0xC, 0x00, 0x72, 0x70, 0x00, 0x45, 0x6E, 0x63, 0x6B, 0x65, 0x79]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Sensitive data remains in process memory as static variables. Dump via Frida memory scan or lldb to extract API keys, tokens, and encryption keys.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: {
                    let _ = InMemoryData.apiKey
                    let _ = InMemoryData.jwtToken
                    let _ = InMemoryData.dbPassword
                    let _ = InMemoryData.encryptionKey
                    isLoaded = true
                    output = "[+] Secrets loaded into process memory\n[+] PID: \(getpid())\n[+] Scannable via Frida Memory.scan()"
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "memorychip").font(.system(size: 10))
                        Text("LOAD SECRETS INTO MEMORY").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if isLoaded {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RESIDENT IN MEMORY:").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(.red)
                        MemorySecretRow(label: "API Key", value: InMemoryData.apiKey)
                        MemorySecretRow(label: "JWT Token", value: String(InMemoryData.jwtToken.prefix(50)) + "...")
                        MemorySecretRow(label: "DB Password", value: InMemoryData.dbPassword)
                        MemorySecretRow(label: "Encryption Key", value: InMemoryData.encryptionKey.map { String(format: "%02X", $0) }.joined())
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.04))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.2), lineWidth: 1))
                }

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
                    Text("Frida scan:\nProcess.enumerateRanges({protection:'r--', onMatch: function(r) {\n  Memory.scan(r.base, r.size, 'sk_live_evilcorp_memory');\n}});\n\nlldb dump:\nmems read --outfile dump.bin --binary <start> <end>\nstrings dump.bin | grep -E 'sk_live|Bearer|EvilCorp'")
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

struct MemorySecretRow: View {
    let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, design: .monospaced)).foregroundColor(Color(white: 0.4))
            Text(value).font(.system(size: 10, design: .monospaced)).foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                .textSelection(.enabled)
        }.padding(.vertical, 2)
    }
}
