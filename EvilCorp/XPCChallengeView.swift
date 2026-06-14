import SwiftUI

struct XPCChallengeView: View {
    @State private var output = ""
    @State private var services: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("IPC/XPC communication vulnerability. Apps can expose XPC services that other processes can connect to. Insecure XPC services allow unauthorized data access without user consent.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: simulateXPCLeak) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.branch").font(.system(size: 10))
                        Text("SIMULATE XPC LEAK").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button(action: discoverServices) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").font(.system(size: 10))
                        Text("DISCOVER XPC SERVICES").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if !services.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("EXPOSED XPC SERVICES:").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(.red)
                        ForEach(services, id: \.self) { svc in
                            Text("  > \(svc)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                        }
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
                    Text("Attack:\n1. List XPC services: launchctl print system\n2. Connect to service: NSXPCConnection\n3. Send unauthorized messages\n4. Extract sensitive data from service response\n\nFrida hook:\nObjC.classes.NSXPCConnection['- initWithMachServiceName:']")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }

    func simulateXPCLeak() {
        let dummyServices = [
            "com.evilcorp.ios.auth-service",
            "com.evilcorp.ios.data-sync",
            "com.evilcorp.ios.payment-handler"
        ]
        output = """
        [+] XPC communication simulated
        [+] Service: com.evilcorp.ios.auth-service
        [+] Message: getUserCredentials()
        [+] Response: {"user":"admin","token":"evilcorp_xpc_leaked_token"}
        [+] No authentication required on XPC endpoint!
        [+] Any process can connect and call methods
        """
        services = dummyServices
    }

    func discoverServices() {
        services = [
            "com.evilcorp.ios.auth-service (active)",
            "com.evilcorp.ios.data-sync (active)",
            "com.evilcorp.ios.payment-handler (active)",
            "com.evilcorp.ios.keychain-access (active)",
            "com.evilcorp.ios.location-tracker (active)"
        ]
        output = "[+] 5 XPC services discovered\n[+] None require authentication\n[+] All expose sensitive functionality"
    }
}
