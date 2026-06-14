import SwiftUI

struct RandomGenChallengeView: View {
    @State private var token = ""
    @State private var sessionID = ""
    @State private var resetCode = ""
    @State private var output = ""

    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 12) {
            Text("Uses insecure random functions (arc4random, rand) instead of cryptographically secure random (SecRandomCopyBytes). Predictable tokens enable session hijacking.")
                .font(.subheadline).foregroundColor(.gray)
                .padding().background(Color.white.opacity(0.05)).cornerRadius(10)

            Button("Generate Insecure Tokens") {
                let t1 = arc4random()
                let t2 = arc4random()
                let t3 = arc4random()
                token = String(format: "auth_token_%08x", t1)
                sessionID = String(format: "sess_%08x_%08x", t2, arc4random())
                resetCode = String(format: "%06d", abs(Int32(bitPattern: t3)) % 1000000)
                output = """
                [INSECURE] arc4random(): \(token)
                [INSECURE] rand(): \(sessionID)
                [INSECURE] rand() 6-digit: \(resetCode)

                [!] arc4random() is NOT cryptographically secure
                [!] rand() is predictable with known seed
                [!] Use SecRandomCopyBytes for security tokens
                [!] Predictable tokens = session hijacking
                """
                EvilCorpNSLog("[INSECURE_RAND] Token: %@ Session: %@", token, sessionID)
            }
            .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(Color.orange).cornerRadius(8)

            if !output.isEmpty {
                Text(output).font(.system(size: 10, design: .monospaced)).foregroundColor(.green)
                    .padding().background(Color.black.opacity(0.5)).cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Fix:").font(.headline).foregroundColor(.green)
                Text("var bytes = [UInt8](repeating: 0, count: 32)\nSecRandomCopyBytes(kSecRandomDefault, 32, &bytes)\nlet token = Data(bytes).base64EncodedString()")
                    .font(.system(size: 10, design: .monospaced)).foregroundColor(.gray)
                    .padding().background(EC.card).cornerRadius(8)
            }
        }.padding() }.background(EC.bg)
    }
}
