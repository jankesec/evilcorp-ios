import SwiftUI
import UIKit

struct PasteboardChallengeView: View {
    @State private var sensitiveText = ""
    @State private var pasteboardContents = ""
    @State private var pasteboardHistory: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("Sensitive data copied to the system pasteboard (UIPasteboard). Any app can read the pasteboard contents. iOS 14+ shows pasteboard access notifications but data is still accessible.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                TextField("Sensitive text to copy...", text: $sensitiveText)
                    .textFieldStyle(.plain).padding(10)
                    .background(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .cornerRadius(6)
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                    .font(.system(size: 13, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                HStack(spacing: 8) {
                    Button(action: {
                        UIPasteboard.general.string = sensitiveText
                        pasteboardHistory.append("[COPIED] \(sensitiveText)")
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.on.clipboard").font(.system(size: 10))
                            Text("COPY").font(.system(size: 11, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0, green: 1, blue: 0.25))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        pasteboardContents = UIPasteboard.general.string ?? "(empty)"
                        pasteboardHistory.append("[READ] \(pasteboardContents)")
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "eye.fill").font(.system(size: 10))
                            Text("READ").font(.system(size: 11, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.12))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("CURRENT CLIPBOARD:").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                    Text(pasteboardContents.isEmpty ? "(empty)" : pasteboardContents)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                        .textSelection(.enabled)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))

                if !pasteboardHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("HISTORY").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        ForEach(pasteboardHistory.suffix(5).reversed(), id: \.self) { entry in
                            Text(entry).font(.system(size: 10, design: .monospaced)).foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
                }

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("[!] UIPasteboard.general is system-wide\n[!] Malicious apps can monitor pasteboard contents\n[!] iOS 14+ notifies on paste access but doesn't block it")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }
}
