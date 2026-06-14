import SwiftUI

struct URLCacheChallengeView: View {
    @State private var output = ""
    @State private var cachedData = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("NSURLSession caches HTTP responses including sensitive data. The cache persists on disk and can be extracted from the app sandbox. Responses with authentication tokens remain cached.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                HStack(spacing: 8) {
                    Button(action: fetchAndCache) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.doc").font(.system(size: 10))
                            Text("FETCH & CACHE").font(.system(size: 11, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0, green: 1, blue: 0.25))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    Button(action: readCache) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass").font(.system(size: 10))
                            Text("READ CACHE").font(.system(size: 11, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.12))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
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

                VStack(alignment: .leading, spacing: 6) {
                    Text("CACHED RESPONSE:").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                    Text(cachedData.isEmpty ? "(empty)" : cachedData)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                        .textSelection(.enabled)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("[!] NSURLCache stores HTTP responses in Cache.db\n[!] Path: Library/Caches/com.evilcorp.ios/Cache.db\n[!] Contains: auth tokens, API responses, PII\n[!] Extract: sqlite3 Cache.db .dump | grep -i token")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }

    func fetchAndCache() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 50*1024*1024, diskCapacity: 100*1024*1024)
        let session = URLSession(configuration: config)
        guard let url = URL(string: "https://api.evilcorp.local/user/profile") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer evilcorp_session_token_abc123xyz", forHTTPHeaderField: "Authorization")
        session.dataTask(with: req) { data, resp, _ in
            if let httpResp = resp as? HTTPURLResponse {
                DispatchQueue.main.async {
                    output = "[+] Response cached with Authorization header\n[+] Token: Bearer evilcorp_session_token_abc123xyz\n[+] Cached at: Library/Caches/com.evilcorp.ios/Cache.db\n[+] SQLite DB contains auth tokens and API responses"
                    cachedData = "HTTP 200 OK\nAuthorization: Bearer evilcorp_session_token_abc123xyz\n{\"user\":\"admin\",\"role\":\"superadmin\",\"api_key\":\"sk_live_cached_in_urlsession\"}"
                }
            }
        }.resume()
    }

    func readCache() {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cachePath = (paths[0] as NSString).appendingPathComponent("com.evilcorp.ios")
        let cacheDB = (cachePath as NSString).appendingPathComponent("Cache.db")
        let exists = FileManager.default.fileExists(atPath: cacheDB)
        cachedData = exists ? "[+] Cache.db found at \(cacheDB)\n[+] Open with: sqlite3 Cache.db .dump" : "[-] No cache found. Fetch data first."
    }
}
