import SwiftUI

struct LocalDataStorageView: View {
    @State private var selectedSub = 0
    let subs = ["UserDefaults", "Plist", "Keychain", "SQLite", "Cache", "Pasteboard", "Keyboard"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(0..<subs.count, id: \.self) { i in
                        Button(action: { withAnimation { selectedSub = i } }) {
                            Text(subs[i])
                                .font(.system(size: 12, weight: selectedSub == i ? .bold : .regular))
                                .foregroundColor(selectedSub == i ? .black : .white)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(selectedSub == i ? Color.white : Color.white.opacity(0.08))
                                .cornerRadius(16)
                        }
                    }
                }.padding(.horizontal).padding(.vertical, 8)
            }

            TabView(selection: $selectedSub) {
                UserDefaultsChallengeView().tag(0)
                PlistChallengeView().tag(1)
                KeychainChallengeView().tag(2)
                SQLiteChallengeView().tag(3)
                URLCacheChallengeView().tag(4)
                PasteboardChallengeView().tag(5)
                KeyboardCacheChallengeView().tag(6)
            }.tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
    }
}
