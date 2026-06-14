import SwiftUI

struct SSLPinningChallengeView: View {
    @State private var urlText = "https://evilcorp.local"
    @State private var output = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("SSL Certificate Pinning bypass challenge. The app pins certificates via URLSessionDelegate. Use Objection or Frida to intercept traffic.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                TextField("Target URL", text: $urlText)
                    .textFieldStyle(.plain).padding(10)
                    .background(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .cornerRadius(6)
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                    .font(.system(size: 13, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                Button(action: {
                    guard let url = URL(string: urlText) else { return }
                    let session = URLSession(configuration: .default, delegate: SSLPinningDelegate(), delegateQueue: nil)
                    session.dataTask(with: url) { _, _, error in
                        DispatchQueue.main.async {
                            if let err = error {
                                output = "[!] SSL Error: \(err.localizedDescription)\n[!] Pinning likely blocking request"
                            } else {
                                output = "[+] Connection OK\n[!] Pinning bypassed or trusted cert matched"
                            }
                        }
                    }.resume()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill").font(.system(size: 10))
                        Text("TEST SSL CONNECTION").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Bypass: objection -g com.evilcorp.ios run ios sslpinning disable\nFrida: Interceptor.attach(SSLPinningDelegate['- urlSession:didReceiveChallenge:completionHandler:'])")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
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
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }
}

class SSLPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let cert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let expectedHash = "evilcorp_pinned_hash_2024"
        let certData = SecCertificateCopyData(cert) as Data
        let certHash = certData.base64EncodedString().prefix(32)
        NSLog("[SSL PINNING] Cert: \(certHash)")
        if String(certHash) == expectedHash {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
