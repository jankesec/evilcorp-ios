import SwiftUI
import CommonCrypto

struct CryptoChallengeView: View {
    @State private var md5Input = ""
    @State private var md5Output = ""
    @State private var plaintext = "EvilCorp Secret"
    @State private var cipherB64 = ""
    @State private var decrypted = ""

    func md5(_ s: String) -> String {
        let data = Data(s.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { CC_MD5($0.baseAddress, CC_LONG(data.count), &digest) }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    func aesECB(_ plain: String) -> String? {
        let key = "evilcorpkey12345"
        let input = plain.data(using: .utf8)!
        var keyBytes = [UInt8](repeating: 0, count: kCCKeySizeAES128)
        key.data(using: .utf8)!.copyBytes(to: &keyBytes, count: min(key.count, kCCKeySizeAES128))
        var buffer = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var numEnc: size_t = 0
        let status = CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionECBMode | kCCOptionPKCS7Padding), keyBytes, kCCKeySizeAES128, nil, (input as NSData).bytes, input.count, &buffer, buffer.count, &numEnc)
        guard status == kCCSuccess else { return nil }
        return Data(buffer.prefix(numEnc)).base64EncodedString()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Weak crypto: MD5 hashing (broken), AES-128-ECB (no IV, deterministic), hardcoded key 'evilcorpkey12345'.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                // MD5 Section
                Text("MD5 HASH").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.red)

                TextField("Input", text: $md5Input)
                    .textFieldStyle(.plain).padding(10)
                    .background(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .cornerRadius(6)
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                    .font(.system(size: 13, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                Button(action: { md5Output = md5(md5Input) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "number").font(.system(size: 10))
                        Text("MD5 HASH").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if !md5Output.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text("MD5: \(md5Output)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                            .textSelection(.enabled)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
                }

                // AES Section
                Text("AES-128-ECB (HARDCODED KEY)").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.red)

                TextField("Plaintext", text: $plaintext)
                    .textFieldStyle(.plain).padding(10)
                    .background(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .cornerRadius(6)
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                    .font(.system(size: 13, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                Button(action: { cipherB64 = aesECB(plaintext) ?? "Error" }) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill").font(.system(size: 10))
                        Text("ENCRYPT AES-ECB").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if !cipherB64.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text("Cipher: \(cipherB64)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                            .textSelection(.enabled)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
                }
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }
}
