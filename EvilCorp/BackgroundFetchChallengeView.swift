import SwiftUI

struct BackgroundFetchChallengeView: View {
    @State private var isRegistered = false
    @State private var fetchData: [(String, String)] = []
    @State private var output = ""

    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 12) {
            Text("Background app refresh leaks sensitive data. The app fetches data in the background and stores it without encryption, exposing it to forensic extraction even when the app is closed.")
                .font(.subheadline).foregroundColor(.gray)
                .padding().background(Color.white.opacity(0.05)).cornerRadius(10)

            Button("Simulate Background Fetch") {
                let data: [(String, String)] = [
                    ("token", "bg_fetch_token_evilcorp_7f3a"),
                    ("user", "admin@evilcorp.local"),
                    ("balance", "$1,500,000.00"),
                    ("last_sync", ISO8601DateFormatter().string(from: Date())),
                    ("api_endpoint", "http://api.evilcorp.local:8080/sync"),
                ]
                fetchData = data

                let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let bgFile = (docs as NSString).appendingPathComponent("background_fetch_cache.dat")
                let content = data.map { "\($0.0)=\($0.1)" }.joined(separator: "\n")
                try? content.write(toFile: bgFile, atomically: true, encoding: .utf8)

                isRegistered = true
                output = """
                [+] Background fetch simulated
                [+] Data cached to Documents/background_fetch_cache.dat
                [+] 5 sensitive fields stored without encryption
                [!] Accessible via iTunes File Sharing (USB)
                [!] Survives app termination
                [!] No data protection class applied
                """
                EvilCorpNSLog("[BG_FETCH] Sensitive data cached to disk: token, user, balance")
            }
            .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(Color.purple).cornerRadius(8)

            if !fetchData.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cached Background Data:").font(.caption).fontWeight(.bold).foregroundColor(.red)
                    ForEach(fetchData, id: \.0) { k, v in
                        HStack {
                            Text(k).font(.system(size: 11, design: .monospaced)).foregroundColor(.gray).frame(width: 100, alignment: .leading)
                            Text(v).font(.system(size: 11, design: .monospaced)).foregroundColor(.yellow)
                        }
                    }
                }.padding().background(EC.card).cornerRadius(8)
            }

            if !output.isEmpty {
                Text(output).font(.system(size: 10, design: .monospaced)).foregroundColor(.green)
                    .padding().background(Color.black.opacity(0.5)).cornerRadius(8)
            }
        }.padding() }.background(EC.bg)
    }
}
