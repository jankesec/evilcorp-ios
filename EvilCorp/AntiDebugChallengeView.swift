import SwiftUI

struct AntiDebugChallengeView: View {
    @State private var isDebugged = false
    @State private var hasFrida = false
    @State private var hasTracer = false
    @State private var output = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Anti-debugging and anti-hooking detection. The app checks for debuggers, Frida, and tracing tools. Bypass these checks using Frida or binary patching.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: runChecks) {
                    HStack(spacing: 8) {
                        Image(systemName: "ant.fill").font(.system(size: 10))
                        Text("RUN DETECTION CHECKS").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                VStack(spacing: 6) {
                    DetectionRow(name: "Debugger (P_TRACED)", detected: isDebugged)
                    DetectionRow(name: "Frida Server", detected: hasFrida)
                    DetectionRow(name: "DTrace/Tracing", detected: hasTracer)
                }
                .padding(12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

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
                    Text("Bypass: frida -U -l bypass.js com.evilcorp.ios\nHook sysctl, check for 'frida' in /proc, patch binary at IsDebuggerPresent()")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }

    func runChecks() {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        isDebugged = (info.kp_proc.p_flag & P_TRACED) != 0
        hasFrida = (FileManager.default.fileExists(atPath: "/usr/sbin/frida-server") ||
                     FileManager.default.fileExists(atPath: "/var/jb/usr/sbin/frida-server"))
        hasTracer = (info.kp_proc.p_flag & P_TRACED) != 0
        output = isDebugged || hasFrida ? "[!] Debugging tools DETECTED!\n[!] App may refuse to run sensitive operations\n[!] Use Frida to bypass: retval.replace(0)" : "[+] No debuggers detected"
    }
}

struct DetectionRow: View {
    let name: String
    let detected: Bool
    var body: some View {
        HStack {
            Image(systemName: detected ? "xmark.shield.fill" : "checkmark.shield.fill")
                .foregroundColor(detected ? .red : Color(red: 0, green: 1, blue: 0.25))
                .font(.system(size: 12))
            Text(name).font(.system(size: 11, design: .monospaced)).foregroundColor(.white)
            Spacer()
            Text(detected ? "DETECTED" : "CLEAR")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(detected ? .red : Color(red: 0, green: 1, blue: 0.25))
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background((detected ? Color.red : Color(red: 0, green: 1, blue: 0.25)).opacity(0.12))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}
