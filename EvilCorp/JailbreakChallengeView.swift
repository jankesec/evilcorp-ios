import SwiftUI
import UIKit

struct JailbreakChallengeView: View {
    @State private var results: [(String, Bool)] = []
    @State private var verdict = ""

    func canOpen(url: String) -> Bool {
        guard let u = URL(string: url) else { return false }
        return UIApplication.shared.canOpenURL(u)
    }

    func runChecks() {
        let fm = FileManager.default
        results = [
            ("Rootless JB (/var/jb)", fm.fileExists(atPath: "/var/jb")),
            ("/Applications/Cydia.app", fm.fileExists(atPath: "/Applications/Cydia.app")),
            ("/var/jb/Applications", fm.fileExists(atPath: "/var/jb/Applications")),
            ("/bin/bash", fm.fileExists(atPath: "/bin/bash")),
            ("/usr/sbin/sshd", fm.fileExists(atPath: "/usr/sbin/sshd")),
            ("cydia:// scheme", canOpen(url: "cydia://")),
            ("sileo:// scheme", canOpen(url: "sileo://")),
            ("Frida server", fm.fileExists(atPath: "/var/jb/usr/sbin/frida-server")),
        ]
        let isJB = results.contains(where: { $0.1 })
        verdict = isJB ? "[!] DEVICE IS JAILBROKEN\n[!] Use Frida to bypass" : "[+] Device appears clean"
        NSLog("[JAILBREAK] Detection result: %@", verdict)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Multiple jailbreak detection techniques. Bypass with Frida: Interceptor.attach(ObjC.classes...['- checkJailbreak'].implementation, { onLeave: function(r) { r.replace(0); } })")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: { runChecks() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled").font(.system(size: 10))
                        Text("RUN JAILBREAK DETECTION").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                ForEach(results, id: \.0) { item in
                    HStack(spacing: 8) {
                        Image(systemName: item.1 ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .foregroundColor(item.1 ? .red : Color(red: 0, green: 1, blue: 0.25))
                            .font(.system(size: 12))
                        Text(item.0).font(.system(size: 10, design: .monospaced)).foregroundColor(.white)
                    }
                }

                if !verdict.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text(verdict)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(verdict.contains("JAILBROKEN") ? .red : Color(red: 0, green: 1, blue: 0.25))
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
