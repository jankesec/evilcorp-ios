import SwiftUI

struct SplashScreenView: View {
    let onComplete: () -> Void

    @State private var phase = 0  // 0=boot, 1=logo, 2=text, 3=done
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var typedText = ""
    @State private var showCursor = true
    @State private var taglineOpacity: Double = 0
    @State private var scanLineY: CGFloat = -100
    @State private var bootLines: [String] = []
    @State private var gridOpacity: Double = 0

    let fullName = "EVILCORP"
    let bootSequence = [
        "[SYS] Initializing EvilCorp Security Framework...",
        "[NET] Loading vulnerability database (25 modules)...",
        "[SEC] OWASP MASVS v2.0 mapping loaded",
        "[LAB] Preparing challenge environments...",
        "[CTF] Scoring engine ready",
        "[SYS] Boot complete. Welcome, operator."
    ]

    let neonGreen = Color(red: 0, green: 1, blue: 0.25)

    var body: some View {
        ZStack {
            // Deep black background
            Color(red: 0.02, green: 0.02, blue: 0.04).ignoresSafeArea()

            // Animated grid background
            Canvas { context, size in
                let spacing: CGFloat = 30
                for x in stride(from: 0, through: size.width, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(neonGreen.opacity(0.05)), lineWidth: 0.5)
                }
                for y in stride(from: 0, through: size.height, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(neonGreen.opacity(0.05)), lineWidth: 0.5)
                }
            }
            .opacity(gridOpacity)
            .ignoresSafeArea()

            // Boot text (phase 0)
            if phase == 0 {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(bootLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(neonGreen.opacity(0.7))
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .transition(.opacity)
            }

            // Logo + text (phase 1+)
            if phase >= 1 {
                VStack(spacing: 20) {
                    // Logo with glow
                    ZStack {
                        Circle()
                            .fill(neonGreen.opacity(0.1))
                            .frame(width: 130, height: 130)
                            .blur(radius: glowRadius)

                        Image("evilcorp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(neonGreen.opacity(0.6), lineWidth: 2))
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    // Typewriter text
                    if phase >= 2 {
                        HStack(spacing: 0) {
                            Text(typedText)
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .shadow(color: neonGreen.opacity(0.5), radius: 10)

                            if showCursor {
                                Rectangle()
                                    .fill(neonGreen)
                                    .frame(width: 3, height: 32)
                                    .opacity(showCursor ? 1 : 0)
                            }
                        }

                        Text("Mobile Security Laboratory")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(neonGreen.opacity(taglineOpacity))
                    }
                }
            }

            // Scan line
            Rectangle()
                .fill(LinearGradient(colors: [.clear, neonGreen.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 2)
                .offset(y: scanLineY)
                .blur(radius: 1)
        }
        .onAppear { startSequence() }
    }

    func startSequence() {
        // Grid fade in
        withAnimation(.easeIn(duration: 0.5)) { gridOpacity = 1 }

        // Phase 0: Boot text
        for (i, line) in bootSequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeIn(duration: 0.1)) { bootLines.append(line) }
            }
        }

        // Phase 1: Logo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) { phase = 1 }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0; logoOpacity = 1
            }
            withAnimation(.easeInOut(duration: 1.5)) { glowRadius = 20 }
        }

        // Phase 2: Typewriter
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            phase = 2
            typeText()
        }

        // Scan line
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.linear(duration: 0.6)) { scanLineY = UIScreen.main.bounds.height }
        }

        // Tagline
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeIn(duration: 0.4)) { taglineOpacity = 1 }
        }

        // Cursor blink
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            showCursor.toggle()
            if phase >= 3 { timer.invalidate() }
        }

        // Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            phase = 3
            onComplete()
        }
    }

    func typeText() {
        for (i, char) in fullName.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                typedText += String(char)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
}
