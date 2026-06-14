import SwiftUI
import UIKit

extension Color {
    init(hex: UInt) { self.init(red: Double((hex>>16)&0xFF)/255, green: Double((hex>>8)&0xFF)/255, blue: Double(hex&0xFF)/255) }
}

enum EC { static let bg = Color(hex:0x08080C); static let card = Color(hex:0x121218) }

class ChallengeProgress: ObservableObject {
    @Published var completed: Set<String> = []
    @Published var bookmarks: Set<String> = []
    @Published var ctfMode = false
    @Published var ctfStart: Date? = nil
    @Published var ctfScore = 0
    private let key = "evilcorp_completed"
    private var bKey: String { "evilcorp_bookmarks" }
    init() {
        completed = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        bookmarks = Set(UserDefaults.standard.stringArray(forKey: bKey) ?? [])
    }
    func toggle(_ id: String) {
        if completed.contains(id) { completed.remove(id) }
        else { completed.insert(id); if ctfMode { ctfScore += id.contains("Hard") ? 300 : id.contains("Medium") ? 200 : 100 } }
        UserDefaults.standard.set(Array(completed), forKey: key)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    func isCompleted(_ id: String) -> Bool { completed.contains(id) }
    func resetCTF() { ctfStart = Date(); ctfScore = 0 }
    func stopCTF() { ctfMode = false; ctfStart = nil }
    func toggleBookmark(_ id: String) { if bookmarks.contains(id) { bookmarks.remove(id) } else { bookmarks.insert(id) }; UserDefaults.standard.set(Array(bookmarks), forKey: bKey) }
    func isBookmarked(_ id: String) -> Bool { bookmarks.contains(id) }
    func categoryCompleted(_ cat: String) -> Bool { let all = EvilCorpChallenge.all.filter{$0.category==cat}; return !all.isEmpty && all.allSatisfy{completed.contains($0.id)} }
}

class LogStore: ObservableObject {
    @Published var entries: [String] = []
    static let shared = LogStore()
    init() {
        entries = [
            "[EVILCORP] v1.0 started · PID: \(getpid())",
            "[EVILCORP] 25 vulnerabilities loaded",
            "[EVILCORP] ATS disabled · FileSharing enabled · URL scheme registered",
            "[INFO] Tap challenges to see live logs here",
            "[INFO] Challenge actions log credentials/data to this console"
        ]
    }
    func append(_ msg: String) { DispatchQueue.main.async { self.entries.append(msg); if self.entries.count > 200 { self.entries.removeFirst(100) } } }
}

struct ContentView: View {
    @State private var tab = 0
    @State private var challenge: EvilCorpChallenge? = nil
    @StateObject private var progress = ChallengeProgress()
    @StateObject private var log = LogStore.shared
    @AppStorage("onboarding_done") private var onboardingDone = false
    @State private var showOnboarding = false

    var body: some View {
        if let ch = challenge {
            let idx = EvilCorpChallenge.all.firstIndex(where: {$0.id == ch.id}) ?? 0
            SwipeableChallengeView(
                challenge: ch, progress: progress,
                onBack: { withAnimation(.easeInOut(duration:0.25)) { challenge = nil } },
                onNext: { let n = min(idx + 1, EvilCorpChallenge.all.count - 1); withAnimation { challenge = EvilCorpChallenge.all[n] } },
                onPrev: { let p = max(idx - 1, 0); withAnimation { challenge = EvilCorpChallenge.all[p] } }
            )
        } else {
            ZStack {
                TabView(selection: $tab) {
                    HomeTabView(selectedChallenge: $challenge, progress: progress).tabItem{Label("Home",systemImage:"house.fill")}.tag(0)
                    LabsTabView(selectedChallenge: $challenge, progress: progress).tabItem{Label("Labs",systemImage:"square.grid.2x2.fill")}.tag(1)
                    MasvsTabView().tabItem{Label("MASVS",systemImage:"checklist")}.tag(2)
                    ProgressTabView(progress: progress).tabItem{Label("Progress",systemImage:"chart.bar.fill")}.tag(3)
                    ConsoleTabView(log: log).tabItem{Label("Console",systemImage:"terminal.fill")}.tag(4)
                    DeviceInfoView().tabItem{Label("Device",systemImage:"iphone.gen3")}.tag(5)
                    MoreTabView().tabItem{Label("Extras",systemImage:"ellipsis.circle.fill")}.tag(6)
                }.tint(.white).preferredColorScheme(.dark)
                if progress.ctfMode { VStack{CTFBannerView(progress:progress).padding(.top,50);Spacer()} }
            }
            .sheet(isPresented: $showOnboarding) { OnboardingView(showOnboarding: $showOnboarding) }
            .onAppear { if !onboardingDone { showOnboarding = true; onboardingDone = true } }
        }
    }
}

struct CTFBannerView: View {
    @ObservedObject var progress: ChallengeProgress
    @State private var elapsed: TimeInterval = 0
    @State private var minimized = false
    let timer = Timer.publish(every:1,on:.main,in:.common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            if !minimized {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "flag.fill").foregroundColor(.orange)
                        Text("CTF MODE").font(.system(size: 11, weight: .bold)).foregroundColor(.orange)
                    }
                    Spacer()
                    HStack(spacing: 16) {
                        VStack(spacing: 0) { Text("\(Int(elapsed/60))m \(Int(elapsed)%60)s").font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(.white); Text("elapsed").font(.system(size: 8)).foregroundColor(.gray) }
                        VStack(spacing: 0) { Text("\(progress.ctfScore)").font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(.orange); Text("pts").font(.system(size: 8)).foregroundColor(.gray) }
                        VStack(spacing: 0) { Text("\(progress.completed.count)/27").font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(.green); Text("solved").font(.system(size: 8)).foregroundColor(.gray) }
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Button(action: { withAnimation(.spring()) { minimized = true } }) {
                            Image(systemName: "chevron.up").font(.caption).foregroundColor(.gray)
                        }
                        Button(action: { progress.stopCTF() }) {
                            Text("END").font(.system(size: 10, weight: .bold)).foregroundColor(.red).padding(.horizontal, 8).padding(.vertical, 4).background(Color.red.opacity(0.15)).cornerRadius(4)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(EC.card)
                .cornerRadius(12)
                .padding(.horizontal, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                Button(action: { withAnimation(.spring()) { minimized = false } }) {
                    HStack(spacing: 6) {
                        Image(systemName: "flag.fill").foregroundColor(.orange).font(.caption)
                        Text("CTF · \(Int(elapsed/60))m · \(progress.ctfScore) pts").font(.system(size: 11)).foregroundColor(.orange)
                        Image(systemName: "chevron.down").font(.caption2).foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(EC.card).cornerRadius(16)
                }
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onReceive(timer) { _ in if let s = progress.ctfStart { elapsed = Date().timeIntervalSince(s) } }
        .onAppear { if let s = progress.ctfStart { elapsed = Date().timeIntervalSince(s) } }
    }
}

struct DetailView: View {
    let challenge: EvilCorpChallenge
    @ObservedObject var progress: ChallengeProgress
    let onBack: () -> Void
    @State private var section = 0
    @State private var hintLevel = 0
    var body: some View {
        VStack(spacing:0) {
            HStack {
                Button(action:onBack){Image(systemName:"chevron.left").font(.title3).foregroundColor(.white)}
                Spacer()
                VStack(spacing:2) {
                    Text(challenge.title).font(.headline).foregroundColor(.white)
                    HStack(spacing:6) {
                        BadgeView(challenge.cwe); BadgeView(challenge.masvs)
                        BadgeView(challenge.maswe, color: .cyan); BadgeView(challenge.cvss, color: .yellow)
                        BadgeView(challenge.difficulty, color: .orange)
                    }
                }
                Spacer()
                Button(action:{withAnimation{progress.toggle(challenge.id)}}) {
                    ZStack {
                        Circle().fill(progress.isCompleted(challenge.id) ? Color.green.opacity(0.2):Color.gray.opacity(0.1)).frame(width:36,height:36)
                        Image(systemName:progress.isCompleted(challenge.id) ? "checkmark.seal.fill":"checkmark.seal").foregroundColor(progress.isCompleted(challenge.id) ? .green:.gray)
                    }
                }
            }.padding(.horizontal).padding(.vertical,10).background(EC.card)
            Picker("",selection:$section){Text("Lab").tag(0);Text("Hints").tag(1);Text("Frida").tag(2)}.pickerStyle(.segmented).padding(.horizontal).padding(.vertical,6)
            TabView(selection:$section){ labView.tag(0); hintsView.tag(1); fridaView.tag(2) }.tabViewStyle(.page(indexDisplayMode:.never))
        }.background(EC.bg)
    }
    @ViewBuilder var labView: some View {
        switch challenge.id {
        case "userdefaults": UserDefaultsChallengeView()
        case "keychain": KeychainChallengeView()
        case "plist": PlistChallengeView()
        case "sqlite": SQLiteChallengeView()
        case "jailbreak": JailbreakChallengeView()
        case "sslpinning": SSLPinningChallengeView()
        case "webviewxss": WebViewXSSChallengeView()
        case "logging": LoggingChallengeView()
        case "hardcodedsecrets": HardcodedSecretsChallengeView()
        case "biometricbypass": BiometricBypassChallengeView()
        case "cryptography": CryptoChallengeView()
        case "network": NetworkChallengeView()
        case "urlscheme": URLSchemeChallengeView()
        case "screenshot": ScreenshotLeakChallengeView()
        case "antidebug": AntiDebugChallengeView()
        case "pasteboard": PasteboardChallengeView()
        case "filesharing": FileSharingChallengeView()
        case "keyboard": KeyboardCacheChallengeView()
        case "binarypatch": BinaryPatchingChallengeView()
        case "pinbruteforce": PinBruteforceView()
        case "urlcache": URLCacheChallengeView()
        case "excessiveperms": ExcessivePermsChallengeView()
        case "phishing": PhishingChallengeView()
        case "memorysensitive": MemorySensitiveChallengeView()
        case "xpc": XPCChallengeView()
        case "randomgen": RandomGenChallengeView()
        case "pathtraversal": PathTraversalChallengeView()
        case "bgfetch": BackgroundFetchChallengeView()
        case "deviceinfo": DeviceInfoView()
        case "localdata": LocalDataStorageView()
        default: Text("...").foregroundColor(.gray)
        }
    }
    var hintsView: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:16) {
                Text("Hints").font(.title2).fontWeight(.bold).foregroundColor(.white)
                ForEach(0..<min(hintLevel+1,challenge.hints.count),id:\.self){i in
                    VStack(alignment:.leading,spacing:8) {
                        Text("Hint \(i+1)").font(.caption).fontWeight(.bold).foregroundColor(.orange).padding(.horizontal,6).padding(.vertical,2).background(Color.orange.opacity(0.15)).cornerRadius(4)
                        Text(challenge.hints[i]).font(.subheadline).foregroundColor(.white).padding().frame(maxWidth:.infinity,alignment:.leading).background(Color.white.opacity(0.04)).cornerRadius(10)
                    }
                }
                if hintLevel < challenge.hints.count - 1 {
                    Button{withAnimation{hintLevel+=1}}label:{
                        HStack{Image(systemName:"lightbulb.fill").foregroundColor(.yellow);Text("Reveal Hint \(hintLevel+2)").foregroundColor(.white)}.font(.subheadline).padding(.horizontal,16).padding(.vertical,10).background(Color.yellow.opacity(0.15)).cornerRadius(8)
                    }
                }
                Spacer()
            }.padding()
        }.background(EC.bg)
    }
    var fridaView: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:16) {
                Text("Frida Script").font(.title2).fontWeight(.bold).foregroundColor(.white)
                Text(challenge.fridaSnippet).font(.system(size:10,design:.monospaced)).foregroundColor(.white).padding(12).frame(maxWidth:.infinity,alignment:.leading).background(Color.black.opacity(0.5)).cornerRadius(10).overlay(RoundedRectangle(cornerRadius:10).stroke(Color.white.opacity(0.1)))
                Text("Usage").font(.headline).foregroundColor(.white).padding(.top)
                HStack(alignment:.top,spacing:6){Text("·").foregroundColor(.white);Text("frida -U -l bypass.js com.evilcorp.ios").font(.subheadline).foregroundColor(.gray)}
                Spacer()
            }.padding()
        }.background(EC.bg)
    }
}

struct HomeTabView: View {
    @Binding var selectedChallenge: EvilCorpChallenge?
    @ObservedObject var progress: ChallengeProgress
    @State private var showAll = false
    var body: some View {
        ScrollView {
            VStack(spacing:16) {
                SecurityStatusBar()
                VStack(spacing:10) {
                    if let path = Bundle.main.path(forResource: "evilcorp", ofType: "jpg"),
                       let img = UIImage(contentsOfFile: path) {
                        Image(uiImage: img).resizable().scaledToFit().frame(width:80,height:80).clipShape(Circle()).overlay(Circle().stroke(Color.white.opacity(0.3),lineWidth:2))
                    } else {
                        Image(systemName: "flask.fill").font(.system(size:36)).foregroundColor(.white).frame(width:80,height:80).background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Text("EVILCORP").font(.system(size:24,weight:.black,design:.serif)).foregroundColor(.white)
                    Text("Mobile Security Laboratory").font(.caption).foregroundColor(.gray)
                }.padding(.top,12)
                HStack(spacing:10) {
                    StatCardView("30","Challenges","flask.fill")
                    StatCardView("\(progress.completed.count)","Solved","checkmark.seal.fill",.green)
                    StatCardView("5","Categories","square.grid.2x2")
                    StatCardView(progress.ctfMode ? "CTF":"Lab","Mode",progress.ctfMode ? "flag.fill":"beaker",progress.ctfMode ? .orange:.blue)
                }
                if !progress.ctfMode {
                    Button{progress.resetCTF();progress.ctfMode=true}label:{
                        HStack{Image(systemName:"flag.fill");Text("START CTF MODE")}.font(.system(size:13,weight:.semibold)).foregroundColor(.white).padding(.horizontal,20).padding(.vertical,10).background(Color.orange).cornerRadius(8)
                    }
                }
                VStack(alignment:.leading,spacing:10) {
                    Text("Featured").font(.title3).fontWeight(.bold).foregroundColor(.white)
                    ScrollView(.horizontal,showsIndicators:false){HStack(spacing:12){ForEach(EvilCorpChallenge.all.shuffled().prefix(5)){ch in FeaturedCardView(challenge:ch,completed:progress.isCompleted(ch.id)){withAnimation{selectedChallenge=ch}}}}}
                }
                VStack(alignment:.leading,spacing:10) {
                    Text("All Vulnerabilities").font(.title3).fontWeight(.bold).foregroundColor(.white)
                    LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:8){ForEach(EvilCorpChallenge.all.prefix(showAll ? 25:8)){ch in GlassCardView(challenge:ch,completed:progress.isCompleted(ch.id)){withAnimation{selectedChallenge=ch}}}}
                    if !showAll{Button("Show all 30"){withAnimation{showAll=true}}.font(.caption).foregroundColor(.white).frame(maxWidth:.infinity).padding(.vertical,4)}
                }
            }.padding(.horizontal)
        }.background(EC.bg)
    }
}

struct LabsTabView: View {
    @Binding var selectedChallenge: EvilCorpChallenge?
    @ObservedObject var progress: ChallengeProgress
    @State private var search = ""
    @State private var diff: String? = nil
    @State private var cat: String? = nil
    @State private var tag: String? = nil
    var filtered: [EvilCorpChallenge] { EvilCorpChallenge.all.filter{ch in (search.isEmpty||ch.title.localizedCaseInsensitiveContains(search)||ch.cwe.localizedCaseInsensitiveContains(search)||ch.masvs.localizedCaseInsensitiveContains(search)) && (diff==nil||ch.difficulty==diff) && (cat==nil||ch.category==cat) && (tag==nil||ch.cwe==tag||ch.masvs==tag) } }
    var body: some View {
        VStack(spacing:0) {
            HStack(spacing:10){Image(systemName:"magnifyingglass").foregroundColor(.gray);TextField("Search CWE-89, STORAGE-1...",text:$search).foregroundColor(.white);if !search.isEmpty{Button{withAnimation{search=""}}label:{Image(systemName:"xmark.circle.fill").foregroundColor(.gray)}}}.padding(10).background(EC.card).cornerRadius(10).padding(.horizontal).padding(.vertical,6)
            ScrollView(.horizontal,showsIndicators:false){HStack(spacing:8){ ForEach([(nil as String?,"All"),("Easy","Easy"),("Medium","Medium"),("Hard","Hard")],id:\.0){d,n in ChipView(text: n,isOn:diff==d,color:d=="Hard" ? .red:d=="Medium" ? .orange:d=="Easy" ? .green:.white){withAnimation{diff=d}}} }.padding(.horizontal)}.padding(.vertical,4)
            ScrollView(.horizontal,showsIndicators:false){HStack(spacing:6){ForEach(["CWE-89","CWE-312","CWE-798","CWE-319","CWE-327","STORAGE-1","NETWORK-1","AUTH-1","CRYPTO-1"],id:\.self){t in TagChipView(text: t,isOn:tag==t){withAnimation{tag=tag==t ? nil:t}}}}.padding(.horizontal)}.padding(.bottom,4)
            ScrollView{LazyVStack(spacing:6){ if filtered.isEmpty{VStack(spacing:16){Image(systemName:"magnifyingglass").font(.system(size:40)).foregroundColor(.gray).padding(.top,40);Text("No results").foregroundColor(.gray)}}; ForEach(filtered){ch in LabRowView(challenge:ch,completed:progress.isCompleted(ch.id)){withAnimation{selectedChallenge=ch}}} }.padding()}.animation(.default,value:filtered.count)
        }.background(EC.bg)
    }
}

struct MasvsTabView: View {
    let cats: [(String,String,[String])] = [("STORAGE","Local Data Storage",["STORAGE-1","STORAGE-2","STORAGE-3"]),("CRYPTO","Cryptography",["CRYPTO-1","CRYPTO-2"]),("NETWORK","Network",["NETWORK-1","NETWORK-2"]),("AUTH","Authentication",["AUTH-1","AUTH-2"]),("RESILIENCE","Resilience",["RESILIENCE-1","RESILIENCE-4"]),("PLATFORM","Platform",["PLATFORM-1","PLATFORM-2"])]
    var body: some View {
        ScrollView{VStack(alignment:.leading,spacing:16){ Text("OWASP MASVS").font(.title2).fontWeight(.bold).foregroundColor(.white).padding(.top,8); ForEach(cats,id:\.0){c,d,reqs in VStack(alignment:.leading,spacing:8){ HStack{Text(c).font(.headline).foregroundColor(.white).padding(.horizontal,8).padding(.vertical,3).background(Color.white.opacity(0.1)).cornerRadius(4);Spacer();Text("\(EvilCorpChallenge.all.filter{$0.masvs.hasPrefix(c)}.count) labs").font(.caption).foregroundColor(.green)}; Text(d).font(.caption).foregroundColor(.gray); ForEach(reqs,id:\.self){r in let id=String(r.prefix(while:{$0 != ":"})); let chs=EvilCorpChallenge.all.filter{$0.masvs==id};HStack{Circle().fill(chs.isEmpty ? Color.gray:Color.green).frame(width:6,height:6);Text(r).font(.caption).foregroundColor(.white);Spacer();if !chs.isEmpty{Text("\(chs.count)").font(.caption2).foregroundColor(.green).padding(.horizontal,4).padding(.vertical,1).background(Color.green.opacity(0.12)).cornerRadius(3)}}}}.padding().background(EC.card).cornerRadius(12)};Spacer()}.padding(.horizontal)}.background(EC.bg)
    }
}

struct ConsoleTabView: View {
    @ObservedObject var log: LogStore
    @State private var auto = true
    @State private var filter = ""
    var filtered: [String] { filter.isEmpty ? log.entries : log.entries.filter{$0.localizedCaseInsensitiveContains(filter)} }
    var body: some View {
        VStack(spacing:0) {
            HStack{Text("Console").font(.headline).foregroundColor(.white);Spacer();Button{auto.toggle()}label:{Image(systemName:auto ? "arrow.down.to.line":"arrow.up.to.line").foregroundColor(auto ? .green:.gray)};Button{log.entries=[]}label:{Image(systemName:"trash").foregroundColor(.red)}}.padding(.horizontal).padding(.top,8)
            HStack(spacing:8){Image(systemName:"magnifyingglass").foregroundColor(.gray);TextField("Filter...",text:$filter).foregroundColor(.white)}.padding(8).background(EC.card).cornerRadius(8).padding(.horizontal).padding(.vertical,4)
            Button{LogStore.shared.append("[TEST] Console active · PID: \(getpid())")}label:{HStack{Image(systemName:"play.fill");Text("Test Log")}.font(.caption).foregroundColor(.green)}.padding(.bottom,4)
            ScrollViewReader{proxy in ScrollView{LazyVStack(alignment:.leading,spacing:2){ if filtered.isEmpty && !log.entries.isEmpty{Text("No matches").foregroundColor(.gray).padding()}; ForEach(Array(filtered.enumerated()),id:\.offset){_,e in Text(e).font(.system(size:9,design:.monospaced)).foregroundColor(e.contains("ERROR") ? .red:e.contains("TEST") ? .green:.white.opacity(0.7)).id(e)}; if log.entries.isEmpty{Text("Tap Test Log to start").foregroundColor(.gray).padding().font(.caption)} }.padding(8)}.onChange(of:log.entries.count){_ in if auto,let last=log.entries.last{proxy.scrollTo(last,anchor:.bottom)}}}
        }.background(EC.bg)
    }
}

struct ProgressTabView: View {
    @ObservedObject var progress: ChallengeProgress
    @State private var ring: CGFloat = 0
    let cats = ["Storage","Network","Crypto","Auth"]
    var body: some View {
        ScrollView{VStack(spacing:20){
            Text("Progress").font(.title2).fontWeight(.bold).foregroundColor(.white).padding(.top,16)
            ZStack{
                Circle().stroke(Color.white.opacity(0.08),lineWidth:14).frame(width:150)
                Circle().trim(from:0,to:ring).stroke(AngularGradient(colors:[.white,.gray,.green],center:.center),style:StrokeStyle(lineWidth:14,lineCap:.round)).frame(width:150).rotationEffect(.degrees(-90)).animation(.easeInOut(duration:1.5),value:ring)
                VStack{Text("\(progress.completed.count)").font(.system(size:38,weight:.bold)).foregroundColor(.white);Text("of 30").font(.caption).foregroundColor(.gray)}
            }.onAppear{ring=CGFloat(progress.completed.count)/30.0}
            HStack(spacing:20){ StatPillView("checkmark.circle.fill","\(progress.completed.count)","Completed",.green); StatPillView("clock.fill","\(30-progress.completed.count)","Left",.orange); StatPillView("percent","\(Int(Double(progress.completed.count)/30*100))%","Score",.white) }
            if progress.ctfMode { CTFStatsView(progress:progress) }
            // Achievements
            VStack(alignment:.leading,spacing:8) {
                Text("Achievements").font(.headline).foregroundColor(.white)
                HStack(spacing:16) {
                    ForEach(cats, id: \.self) { cat in
                        let total = EvilCorpChallenge.all.filter{$0.category==cat}.count
                        let done = EvilCorpChallenge.all.filter{$0.category==cat && progress.isCompleted($0.id)}.count
                        let icon = cat == "Storage" ? "externaldrive.fill" : cat == "Network" ? "antenna.radiowaves.left.and.right" : cat == "Crypto" ? "lock.shield.fill" : "faceid"
                        AchievementBadge(title: cat, icon: icon, unlocked: done == total, count: done, total: total)
                    }
                }
            }.padding().background(EC.card).cornerRadius(12)
            VStack(spacing:10){ForEach(cats,id:\.self){c in let t=EvilCorpChallenge.all.filter{$0.category==c}.count;let d=EvilCorpChallenge.all.filter{$0.category==c&&progress.isCompleted($0.id)}.count;BarView(cat:c,done:d,total:t)}}.padding().background(EC.card).cornerRadius(12)
            if !progress.completed.isEmpty{
                VStack(alignment:.leading,spacing:8){Text("Solved").font(.headline).foregroundColor(.white);ForEach(Array(progress.completed).sorted().prefix(6).reversed(),id:\.self){id in if let ch=EvilCorpChallenge.all.first(where:{$0.id==id}){HStack{Image(systemName:ch.icon).foregroundColor(.green).frame(width:24);Text(ch.title).font(.subheadline).foregroundColor(.white);Spacer();BadgeView(ch.difficulty,color:ch.difficulty=="Hard" ? .red:ch.difficulty=="Medium" ? .orange:.green)}}}}.padding().background(EC.card).cornerRadius(12)
            }else{Text("No challenges solved yet").foregroundColor(.gray).padding().background(EC.card).cornerRadius(12)}
            Text("v1.0 · EvilCorp").font(.caption2).foregroundColor(.gray).padding(.bottom)
        }.padding(.horizontal)}.background(EC.bg)
    }
}

struct CTFStatsView: View {
    @ObservedObject var progress: ChallengeProgress
    @State private var elapsed: TimeInterval = 0
    let timer = Timer.publish(every:1,on:.main,in:.common).autoconnect()
    var body: some View {
        HStack(spacing:12) {
            VStack{Text("\(Int(elapsed/60))m \(Int(elapsed)%60)s").font(.title3).fontWeight(.bold).foregroundColor(.orange);Text("Elapsed").font(.caption2).foregroundColor(.gray)}.frame(maxWidth:.infinity).padding(.vertical,8).background(EC.card).cornerRadius(10)
            VStack{Text("\(progress.ctfScore)").font(.title3).fontWeight(.bold).foregroundColor(.orange);Text("Score").font(.caption2).foregroundColor(.gray)}.frame(maxWidth:.infinity).padding(.vertical,8).background(EC.card).cornerRadius(10)
        }.onReceive(timer){_ in if let s=progress.ctfStart{elapsed=Date().timeIntervalSince(s)}}.onAppear{if let s=progress.ctfStart{elapsed=Date().timeIntervalSince(s)}}
    }
}

struct GlassCardView: View { let challenge: EvilCorpChallenge; let completed: Bool; let action: () -> Void; @State private var appear = false
    var body: some View { Button(action:action){VStack(alignment:.leading,spacing:6){HStack{Image(systemName:challenge.icon).foregroundColor(completed ? .green:.white);Spacer();if completed{Image(systemName:"checkmark.seal.fill").foregroundColor(.green).font(.caption)}};Text(challenge.title).font(.caption).fontWeight(.semibold).foregroundColor(.white).lineLimit(2);BadgeView(challenge.difficulty,color:challenge.difficulty=="Hard" ? .red:challenge.difficulty=="Medium" ? .orange:.green)}.padding(10).frame(maxWidth:.infinity,alignment:.leading).background(EC.card).cornerRadius(12).overlay(RoundedRectangle(cornerRadius:12).stroke(completed ? Color.green.opacity(0.3):Color.white.opacity(0.06),lineWidth:1))}.scaleEffect(appear ? 1:0.85).opacity(appear ? 1:0).onAppear{withAnimation(.spring(response:0.4,dampingFraction:0.7).delay(Double.random(in:0...0.15))){appear=true}}} }
struct FeaturedCardView: View { let challenge: EvilCorpChallenge; let completed: Bool; let action: () -> Void
    var body: some View { Button(action:action){VStack(alignment:.leading,spacing:10){HStack{Image(systemName:challenge.icon).font(.title2).foregroundColor(completed ? .green:.white);Spacer();BadgeView(challenge.difficulty,color:challenge.difficulty=="Hard" ? .red:challenge.difficulty=="Medium" ? .orange:.green)};Text(challenge.title).font(.subheadline).fontWeight(.semibold).foregroundColor(.white);Text(challenge.description).font(.caption).foregroundColor(.gray).lineLimit(2)}.padding().frame(width:180,height:130,alignment:.topLeading).background(EC.card).cornerRadius(16)} }
}
struct LabRowView: View { let challenge: EvilCorpChallenge; let completed: Bool; let action: () -> Void
    var body: some View { Button(action:action){HStack(spacing:14){ZStack{Circle().fill((completed ? Color.green:Color.white).opacity(0.12)).frame(width:44,height:44);Image(systemName:challenge.icon).foregroundColor(completed ? .green:.white).font(.system(size:16))};VStack(alignment:.leading,spacing:3){Text(challenge.title).font(.subheadline).fontWeight(.medium).foregroundColor(.white);Text(challenge.cwe+" · "+challenge.masvs+" · "+challenge.maswe+" · "+challenge.cvss).font(.caption2).foregroundColor(.gray)};Spacer();VStack(alignment:.trailing,spacing:4){BadgeView(challenge.difficulty,color:challenge.difficulty=="Hard" ? .red:challenge.difficulty=="Medium" ? .orange:.green);if completed{Image(systemName:"checkmark.circle.fill").foregroundColor(.green)}}}.padding(12).background(EC.card).cornerRadius(12)} }
}
struct StatCardView: View { let v: String; let l: String; let i: String; var c: Color = .white; init(_ v: String,_ l: String,_ i: String,_ c: Color = .white){self.v=v;self.l=l;self.i=i;self.c=c}
    var body: some View { VStack(spacing:4){Image(systemName:i).foregroundColor(c).font(.caption);Text(v).font(.title3).fontWeight(.bold).foregroundColor(.white);Text(l).font(.system(size:9)).foregroundColor(.gray)}.frame(maxWidth:.infinity).padding(.vertical,10).background(EC.card).cornerRadius(12) }
}
struct ChipView: View { let text: String; let isOn: Bool; var color: Color = .white; let action: () -> Void
    var body: some View { Button(action:action){Text(text).font(.system(size:12,weight:.medium)).foregroundColor(isOn ? .black:.white).padding(.horizontal,12).padding(.vertical,6).background(isOn ? color:Color.white.opacity(0.08)).cornerRadius(14)} }
}
struct TagChipView: View { let text: String; let isOn: Bool; let action: () -> Void
    var body: some View { Button(action:action){Text(text).font(.system(size:10,weight:.medium,design:.monospaced)).foregroundColor(isOn ? .black:.white).padding(.horizontal,8).padding(.vertical,4).background(isOn ? Color.white:Color.white.opacity(0.08)).cornerRadius(8)} }
}
struct BadgeView: View { let text: String; var color: Color = .white; init(_ t: String, color: Color = .white) { text = t; self.color = color }
    var body: some View { Text(text).font(.system(size:9,weight:.bold,design:.monospaced)).foregroundColor(color).padding(.horizontal,5).padding(.vertical,2).background(color.opacity(0.12)).cornerRadius(3) }
}
struct StatPillView: View { let icon: String; let value: String; let label: String; let color: Color; init(_ i: String,_ v: String,_ l: String,_ c: Color){icon=i;value=v;label=l;color=c}
    var body: some View { VStack(spacing:4){Image(systemName:icon).foregroundColor(color).font(.title3);Text(value).font(.title3).fontWeight(.bold).foregroundColor(color);Text(label).font(.caption2).foregroundColor(.gray)}.frame(maxWidth:.infinity).padding(.vertical,12).background(EC.card).cornerRadius(12) }
}
struct BarView: View { let cat: String; let done: Int; let total: Int
    var body: some View { VStack(alignment:.leading,spacing:6){HStack{Text(cat).font(.subheadline).foregroundColor(.white);Spacer();Text("\(done)/\(total)").font(.caption).foregroundColor(.gray)};GeometryReader{geo in ZStack(alignment:.leading){RoundedRectangle(cornerRadius:4).fill(Color.white.opacity(0.1));RoundedRectangle(cornerRadius:4).fill(LinearGradient(colors:[.white,.gray],startPoint:.leading,endPoint:.trailing)).frame(width:geo.size.width*(total>0 ? CGFloat(done)/CGFloat(total):0)).animation(.easeInOut(duration:1),value:done)}}.frame(height:8)} }
}
