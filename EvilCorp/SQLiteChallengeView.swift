import SwiftUI
import SQLite3

struct SQLiteChallengeView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var output = ""
    @State private var db: OpaquePointer?

    func setupDB() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = (paths[0] as NSString).appendingPathComponent("evilcorp.db")
        guard sqlite3_open(path, &db) == SQLITE_OK else { return }
        sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT, password TEXT, role TEXT)", nil, nil, nil)
        sqlite3_exec(db, "INSERT OR IGNORE INTO users VALUES (1,'admin','EvilCorpAdmin2024!','admin')", nil, nil, nil)
        sqlite3_exec(db, "INSERT OR IGNORE INTO users VALUES (2,'root','evilcorp_root_pass','superadmin')", nil, nil, nil)
    }

    func login() {
        if db == nil { setupDB() }
        let query = "SELECT * FROM users WHERE username = '\(username)' AND password = '\(password)'"
        NSLog("[SQL] \(query)")
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                let u = String(cString: sqlite3_column_text(stmt, 1))
                let r = String(cString: sqlite3_column_text(stmt, 3))
                output = "[+] Login: \(u) (\(r))\n[!] VULN: Try: ' OR '1'='1' --"
            } else {
                output = "[-] Login failed"
            }
        }
        sqlite3_finalize(stmt)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Raw SQLite query with user input concatenation. Classic SQL injection vulnerability.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                TextField("Username", text: $username)
                    .textFieldStyle(.plain).padding(10)
                    .background(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .cornerRadius(6)
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                    .font(.system(size: 13, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .textFieldStyle(.plain).padding(10)
                    .background(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .cornerRadius(6)
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                    .font(.system(size: 13, design: .monospaced))

                Button(action: { login() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill").font(.system(size: 10))
                        Text("SQL LOGIN").font(.system(size: 11, weight: .semibold, design: .monospaced))
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
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
        .onAppear { setupDB() }
    }
}
