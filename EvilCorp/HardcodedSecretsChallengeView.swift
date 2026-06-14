import SwiftUI

struct HardcodedSecretsChallengeView: View {
    @State private var output = ""

    struct EvilCorpSecrets {
        static let googleMapsKey = "AIzaSyD-evilcorp-maps-key-7f3a9e1b"
        static let stripeSecretKey = "sk_live_evilcorp_stripe_7f3a9e1b"
        static let awsAccessKey = "AKIA_EVILCORP_EXAMPLE"
        static let awsSecretKey = "evilcorp_s3cr3t_k3y_2024"
        static let adminPassword = "EvilCorp_SuperAdmin_2024!"
        static let apiEndpoint = "http://api.evilcorp.local:8080"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("API keys and secrets hardcoded in the binary. Extract with: strings EvilCorp | grep -E '(key|secret|password|AKIA|sk_live)'")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: {
                    output = """
                    [Google Maps Key] \(EvilCorpSecrets.googleMapsKey)
                    [Stripe Secret] \(EvilCorpSecrets.stripeSecretKey)
                    [AWS Access Key] \(EvilCorpSecrets.awsAccessKey)
                    [AWS Secret Key] \(EvilCorpSecrets.awsSecretKey)
                    [Admin Password] \(EvilCorpSecrets.adminPassword)
                    [API Endpoint] \(EvilCorpSecrets.apiEndpoint)

                    [!] These are embedded in the binary
                    [!] Extractable via: strings EvilCorp | grep -E '(key|secret|password|AKIA|sk_live)'
                    """
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "eye.fill").font(.system(size: 10))
                        Text("DUMP HARDCODED SECRETS").font(.system(size: 11, weight: .semibold, design: .monospaced))
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
    }
}
