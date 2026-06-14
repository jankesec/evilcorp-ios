import SwiftUI

struct FileSharingChallengeView: View {
    @State private var output = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("UIFileSharingEnabled = true in Info.plist allows iTunes/Finder file sharing. Sensitive app files become accessible via USB without authentication.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: createSensitiveFiles) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.badge.plus").font(.system(size: 10))
                        Text("CREATE SENSITIVE FILES").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button(action: listFiles) {
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet").font(.system(size: 10))
                        Text("LIST SHARED FILES").font(.system(size: 11, weight: .semibold, design: .monospaced))
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

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("[!] Connect iPhone via USB -> Finder -> Files -> EvilCorp\n[!] All Documents/ files are accessible without passcode\n[!] UIFileSharingEnabled = true in Info.plist")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }

    func createSensitiveFiles() {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let files: [(String, String)] = [
            ("credentials.txt", "admin:EvilCorpAdmin2024!\nroot:evilcorp_root_pass"),
            ("database_backup.sql", "CREATE TABLE users (id, user, pass, role);\nINSERT INTO users VALUES (1,'admin','EvilCorpAdmin2024!','admin');"),
            ("api_keys.json", "{\"stripe\":\"sk_live_evilcorp_7f3a9e1b\",\"aws\":\"AKIA_EVILCORP_EXAMPLE\"}"),
            ("financial_data.csv", "account,routing,balance\n9876543210,021000021,1500000.00"),
        ]
        for (name, content) in files {
            try? content.write(toFile: (docs as NSString).appendingPathComponent(name), atomically: true, encoding: .utf8)
        }
        output = "[+] 4 sensitive files created in Documents/\n[+] Accessible via iTunes File Sharing\n[+] No authentication required via USB"
    }

    func listFiles() {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: docs) else { return }
        output = "[Documents/]\n" + files.map { "  > \($0)" }.joined(separator: "\n")
    }
}
