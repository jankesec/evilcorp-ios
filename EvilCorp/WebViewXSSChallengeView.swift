import SwiftUI
import WebKit

struct WebViewXSSChallengeView: View {
    @State private var urlText = ""
    @State private var showWebView = false

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 0) {
                Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                Text("WKWebView with JavaScript enabled and file access. XSS + local file read possible.")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color(white: 0.5))
                    .padding(12)
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(8)

            TextField("URL or HTML", text: $urlText)
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
                    showWebView = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe").font(.system(size: 10))
                        Text("LOAD").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 1, blue: 0.25))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button(action: {
                    urlText = "javascript:alert('XSS WORKS - EvilCorp')"
                    showWebView = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 10))
                        Text("XSS TEST").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }

            if showWebView {
                let targetURL: URL = {
                    if urlText.hasPrefix("http") || urlText.hasPrefix("javascript") {
                        return URL(string: urlText) ?? URL(string: "about:blank")!
                    }
                    // Intentionally vulnerable: JS eval enabled in WebView for security training
                    let html = "<html><body style='background:black;color:lime;font:14px monospace'><h2>EvilCorp WebView</h2><p>JS: ON | Files: ON</p><input id='c' placeholder='JS code'><button onclick='eval(document.getElementById(\"c\").value)'>Run</button><pre id='o'></pre></body></html>"
                    return URL(string: "data:text/html;base64," + (html.data(using: .utf8)?.base64EncodedString() ?? "")) ?? URL(string: "about:blank")!
                }()
                EvilCorpWebView(url: targetURL)
                    .frame(height: 300)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
            }

            HStack(spacing: 0) {
                Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                Text("[Frida] Interceptor.attach(WKPreferences['- setJavaScriptEnabled:'])\nTry: javascript:fetch('file:///etc/hosts').then(r=>r.text()).then(t=>alert(t))")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Color(white: 0.5))
                    .padding(12)
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(8)
        }.padding().background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }
}

struct EvilCorpWebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.load(URLRequest(url: url))
        return wv
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
