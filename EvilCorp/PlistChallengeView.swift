import SwiftUI

struct PlistChallengeView: View {
    @State private var output = ""

    func storePlist() -> String {
        let data: [String: Any] = [
            "username": "root",
            "password": "evilcorp_admin_2024!",
            "role": "superadmin",
            "api_keys": ["stripe": "sk_live_evilcorp_7f3a9e1b", "aws": "AKIA_EVILCORP:wJalrXUtn"]
        ]
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = (paths[0] as NSString).appendingPathComponent("config.plist")
        (data as NSDictionary).write(toFile: path, atomically: true)
        return path
    }

    func readPlist() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = (paths[0] as NSString).appendingPathComponent("config.plist")
        guard let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else { return "Not found" }
        return dict.map { "[\($0.key)] \($0.value)" }.joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Sensitive configuration stored in plaintext plist files in the app sandbox. Extractable via filesystem access.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: {
                    let path = storePlist()
                    output = "[+] Config saved to:\n\(path)"
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.fill").font(.system(size: 10))
                        Text("STORE CONFIG PLIST").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button(action: {
                    output = readPlist()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.magnifyingglass").font(.system(size: 10))
                        Text("READ CONFIG PLIST").font(.system(size: 11, weight: .semibold, design: .monospaced))
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
