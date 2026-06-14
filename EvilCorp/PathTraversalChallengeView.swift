import SwiftUI

struct PathTraversalChallengeView: View {
    @State private var filename = ""
    @State private var fileContent = ""
    @State private var output = ""

    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 12) {
            Text("File path constructed from user input without sanitization. Path traversal allows reading arbitrary files outside the intended directory.")
                .font(.subheadline).foregroundColor(.gray)
                .padding().background(Color.white.opacity(0.05)).cornerRadius(10)

            TextField("Enter filename...", text: $filename)
                .textFieldStyle(.plain).padding(12)
                .background(Color.white.opacity(0.08)).cornerRadius(8)
                .foregroundColor(.white).autocapitalization(.none)

            HStack(spacing: 10) {
                Button("Read File") { readFile() }
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(Color.red).cornerRadius(8)

                Button("Try: ../etc/hosts") {
                    filename = "../etc/hosts"; readFile()
                }
                .font(.system(size: 11)).foregroundColor(.orange)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color.orange.opacity(0.1)).cornerRadius(8)
            }

            if !fileContent.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("File Content:").font(.caption).fontWeight(.bold).foregroundColor(.green)
                    Text(fileContent).font(.system(size: 10, design: .monospaced)).foregroundColor(.yellow)
                        .padding().frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.5)).cornerRadius(8)
                }
            }

            if !output.isEmpty {
                Text(output).font(.system(size: 10, design: .monospaced)).foregroundColor(.green)
                    .padding().background(Color.black.opacity(0.5)).cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Payload Examples:").font(.caption).fontWeight(.bold).foregroundColor(.red)
                Text("../etc/hosts\n../../etc/passwd\n../var/mobile/Library/Preferences/com.evilcorp.ios.plist")
                    .font(.system(size: 10, design: .monospaced)).foregroundColor(.gray)
                    .padding().background(EC.card).cornerRadius(8)
            }
        }.padding() }.background(EC.bg)
    }

    func readFile() {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = (docs as NSString).appendingPathComponent(filename)
        output = "[!] Path constructed without sanitization\n[!] Requested: \(filePath)\n[!] Vulnerable to ../ traversal"

        if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
            fileContent = String(content.prefix(500))
        } else {
            fileContent = "(file not found or permission denied)\nTry: ../etc/hosts"
        }
        EvilCorpNSLog("[PATH_TRAVERSAL] Attempted: %@", filePath)
    }
}
