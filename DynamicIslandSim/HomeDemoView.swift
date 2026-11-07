import SwiftUI
import Combine

// MARK: - Écran de démonstration (fond d'écran + barre d'état + réglages)

struct HomeDemoView: View {
    @StateObject private var model = IslandModel()
    @State private var autoDemo = false

    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let demoTimer = Timer.publish(every: 2.6, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                wallpaper
                VStack(spacing: 0) {
                    statusBar
                    DynamicIslandView(model: model, availableWidth: geo.size.width)
                        .padding(.top, 6)
                    Spacer()
                    controls
                }
            }
        }
        .preferredColorScheme(.dark)
        .onReceive(clock) { _ in model.tick() }
        .onReceive(demoTimer) { _ in
            guard autoDemo else { return }
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                let all = IslandContent.allCases
                if let idx = all.firstIndex(of: model.content) {
                    model.content = all[(idx + 1) % all.count]
                }
            }
        }
    }

    // MARK: Fond d'écran factice

    private var wallpaper: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.18, green: 0.10, blue: 0.32),
                                    Color(red: 0.05, green: 0.07, blue: 0.16)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            Circle()
                .fill(Color(red: 0.45, green: 0.25, blue: 0.75).opacity(0.35))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: -80, y: -240)
            Circle()
                .fill(Color(red: 0.95, green: 0.45, blue: 0.35).opacity(0.25))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: 110, y: 320)
        }
        .ignoresSafeArea()
    }

    // MARK: Barre d'état factice

    private var statusBar: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Spacer()
            Image(systemName: "wifi")
            Image(systemName: "battery.100.bolt")
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .foregroundColor(.white)
    }

    // MARK: Panneau de contrôle

    private var controls: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                ForEach(IslandMode.allCases) { m in
                    Button(action: {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                            model.mode = m
                        }
                    }) {
                        Text(m.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(model.mode == m ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(model.mode == m ? Color.white : Color.white.opacity(0.12))
                            )
                    }
                }
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(IslandContent.allCases) { c in
                        Button(action: {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                                model.content = c
                            }
                        }) {
                            Label(c.label, systemImage: c.symbol)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(model.content == c ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule().fill(model.content == c ? Color.white : Color.white.opacity(0.12))
                                )
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Button(action: { model.togglePlay() }) {
                    Image(systemName: model.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                Slider(value: $model.elapsed, in: 0...model.duration)
                    .tint(.white)
            }

            HStack {
                Button(action: { model.runFaceID() }) {
                    Label("Tester Face ID", systemImage: "faceid")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                }
                Spacer()
                Toggle("Démo auto", isOn: $autoDemo)
                    .font(.system(size: 13, weight: .medium))
                    .tint(.white)
                    .fixedSize()
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.55))
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 18)
    }
}

struct HomeDemoView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDemoView()
    }
}
