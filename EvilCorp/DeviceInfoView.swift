import SwiftUI
import UIKit

struct DeviceInfoView: View {
    @State private var info: [(String, String)] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Device Intelligence").font(.title2).fontWeight(.bold).foregroundColor(.white).padding(.top, 8)

                ForEach(info, id: \.0) { key, value in
                    HStack {
                        Text(key).font(.subheadline).foregroundColor(.gray).frame(width: 120, alignment: .leading)
                        Text(value).font(.subheadline).foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(8)
                }

                if info.isEmpty {
                    Button("Collect Device Info") { collect() }
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(Color.blue).cornerRadius(8)
                } else {
                    Button("Refresh") { collect() }
                        .font(.caption).foregroundColor(.blue).padding(.top, 4)
                }

                Spacer()
            }.padding()
        }
        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
        .onAppear { collect() }
    }

    func collect() {
        let device = UIDevice.current
        let fm = FileManager.default
        let jbPaths = ["/var/jb", "/Applications/Cydia.app", "/usr/sbin/sshd", "/bin/bash"]
        let isJB = jbPaths.contains { fm.fileExists(atPath: $0) }

        var result: [(String, String)] = [
            ("Device Name", device.name),
            ("Model", device.model),
            ("System", "iOS \(device.systemVersion)"),
            ("Identifier", UIDevice.current.identifierForVendor?.uuidString.prefix(12).description ?? "N/A"),
        ]

        if let info = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] {
            result.append(("Environment", "Simulator — \(info)"))
        } else {
            result.append(("Environment", "Physical Device"))
            result.append(("Jailbroken", isJB ? "Yes (rootless)" : "No"))
            if isJB {
                result.append(("JB Type", fm.fileExists(atPath: "/var/jb") ? "Rootless (Dopamine/palera1n)" : "Rootful"))
                result.append(("SSH", fm.fileExists(atPath: "/usr/sbin/sshd") ? "Available" : "Not found"))
                result.append(("Frida", fm.fileExists(atPath: "/var/jb/usr/sbin/frida-server") ? "Available" : "Not found"))
            }
        }

        result.append(("Screen", "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))"))
        result.append(("Scale", "@\(Int(UIScreen.main.scale))x"))
        result.append(("App PID", "\(getpid())"))
        result.append(("App Sandbox", NSHomeDirectory()))
        result.append(("Bundle ID", "com.evilcorp.ios"))

        info = result
        EvilCorpNSLog("[DEVICE] Info collected: iOS \(device.systemVersion), JB: \(isJB), PID: \(getpid())")
    }
}

func EvilCorpNSLog(_ format: String, _ args: CVarArg...) {
    let msg = String(format: format, arguments: args)
    NSLog("%@", msg)
    LogStore.shared.append(msg)
}
