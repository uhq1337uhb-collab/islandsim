import SwiftUI

// MARK: - Pilule principale (réplique du design de la Dynamic Island)

struct DynamicIslandView: View {
    @ObservedObject var model: IslandModel
    var availableWidth: CGFloat

    private var expandedWidth: CGFloat { min(371, availableWidth - 8) }

    private var size: CGSize {
        switch model.mode {
        case .compact: return CGSize(width: 128, height: 37)
        case .minimal: return CGSize(width: 37, height: 37)
        case .expanded: return CGSize(width: expandedWidth, height: 224)
        }
    }

    private var cornerRadius: CGFloat {
        model.mode == .expanded ? 44 : 20
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.black)
                .frame(width: size.width, height: size.height)

            content
                .frame(width: size.width, height: size.height)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
        }
        .contentShape(Rectangle())
        .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
        .onTapGesture { toggleMode() }
    }

    private func toggleMode() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            model.mode = (model.mode == .expanded) ? .compact : .expanded
        }
    }

    @ViewBuilder private var content: some View {
        switch model.mode {
        case .compact: compactContent
        case .minimal: minimalContent
        case .expanded: expandedContent
        }
    }

    // MARK: Compacte (deux éléments séparés, comme la vraie île)

    private var compactContent: some View {
        HStack {
            leadingCompact
            Spacer(minLength: 30)
            trailingCompact
        }
        .padding(.horizontal, 9)
    }

    @ViewBuilder private var leadingCompact: some View {
        switch model.content {
        case .music:
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(LinearGradient(colors: model.artColors,
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .frame(width: 22, height: 22)
        case .timer:
            TimerRing(progress: model.timerProgress, size: 22, lineWidth: 3)
        case .call:
            Image(systemName: "phone.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.green)
        case .charging:
            Image(systemName: "bolt.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
        case .faceID:
            Image(systemName: "faceid")
                .font(.system(size: 13))
                .foregroundColor(.white)
        }
    }

    @ViewBuilder private var trailingCompact: some View {
        switch model.content {
        case .music:
            EqualizerView()
        case .timer:
            Text(model.timeString(model.timerRemaining))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.orange)
        case .call:
            Image(systemName: "waveform")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.green)
        case .charging:
            Text("\(model.batteryLevel)%")
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
                .foregroundColor(.green)
        case .faceID:
            Text("Face ID")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: Minimale (cercle unique)

    @ViewBuilder private var minimalContent: some View {
        switch model.content {
        case .music:
            EqualizerView().padding(8)
        case .timer:
            TimerRing(progress: model.timerProgress, size: 29, lineWidth: 3.5)
        default:
            Image(systemName: model.content.symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: Déployée

    @ViewBuilder private var expandedContent: some View {
        switch model.content {
        case .music: ExpandedMusicView(model: model)
        case .timer: ExpandedTimerView(model: model)
        case .call: ExpandedCallView(model: model)
        case .charging: ExpandedChargeView(model: model)
        case .faceID: ExpandedFaceIDView(model: model)
        }
    }
}

// MARK: - Égaliseur animé

struct EqualizerView: View {
    var barCount = 4

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            HStack(alignment: .center, spacing: 2.5) {
                ForEach(0..<barCount, id: \.self) { i in
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 2.5, height: barHeight(i, t))
                }
            }
            .frame(height: 16, alignment: .center)
        }
    }

    private func barHeight(_ i: Int, _ t: TimeInterval) -> CGFloat {
        let phase = t * (2.4 + Double(i) * 0.55) + Double(i) * 1.1
        return 4 + 9 * CGFloat(abs(sin(phase)))
    }
}

// MARK: - Anneau de progression (minuteur)

struct TimerRing: View {
    var progress: Double
    var size: CGFloat
    var lineWidth: CGFloat
    var tint: Color = .orange

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.25), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(1, progress))))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .animation(.linear(duration: 0.5), value: progress)
    }
}

// MARK: - État déployé : Musique

struct ExpandedMusicView: View {
    @ObservedObject var model: IslandModel

    var body: some View {
        ZStack {
            LinearGradient(colors: model.artColors, startPoint: .top, endPoint: .bottom)
                .opacity(0.85)

            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(LinearGradient(colors: model.artColors,
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
                        .frame(width: 38, height: 38)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.songTitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(model.songArtist)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    Spacer()
                    EqualizerView()
                }

                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.25))
                            Capsule()
                                .fill(Color.white)
                                .frame(width: geo.size.width * CGFloat(model.elapsed / model.duration))
                        }
                    }
                    .frame(height: 4)

                    HStack {
                        Text(model.timeString(model.elapsed))
                        Spacer()
                        Text("-" + model.timeString(model.duration - model.elapsed))
                    }
                    .font(.system(size: 10, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(.white.opacity(0.65))
                }

                HStack(spacing: 34) {
                    Image(systemName: "backward.fill")
                    Button(action: { model.togglePlay() }) {
                        Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 22, weight: .bold))
                    }
                    Image(systemName: "forward.fill")
                }
                .foregroundColor(.white)
            }
            .padding(18)
        }
    }
}

// MARK: - État déployé : Minuteur

struct ExpandedTimerView: View {
    @ObservedObject var model: IslandModel

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                TimerRing(progress: model.timerProgress, size: 92, lineWidth: 8, tint: .orange)
                Text(model.timeString(model.timerRemaining))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.orange)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Minuteur")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text("Temps restant")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(18)
    }
}

// MARK: - État déployé : Appel

struct ExpandedCallView: View {
    @ObservedObject var model: IslandModel

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(LinearGradient(colors: [Color(white: 0.35), Color(white: 0.18)],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(model.callerName.prefix(1)).uppercased())
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(model.callerName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                Text(model.callAccepted ? "En appel" : "Appel entrant…")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            VStack(spacing: 10) {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        model.callAccepted = false
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                            model.mode = .compact
                        }
                    }
                }) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 46, height: 46)
                        .background(Circle().fill(Color.red))
                }
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        model.callAccepted = true
                    }
                }) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 46, height: 46)
                        .background(Circle().fill(Color.green))
                }
            }
        }
        .padding(18)
    }
}

// MARK: - État déployé : Charge

struct ExpandedChargeView: View {
    @ObservedObject var model: IslandModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.green)
                Text("Charge en cours")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(model.batteryLevel)%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.green)
            }
            ProgressView(value: Double(model.batteryLevel), total: 100)
                .tint(.green)
            HStack {
                Spacer()
                Text("≈ \(model.chargingMinutesLeft) min restantes")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.65))
            }
        }
        .padding(20)
    }
}

// MARK: - État déployé : Face ID

struct ExpandedFaceIDView: View {
    @ObservedObject var model: IslandModel
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 14) {
            icon
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .onAppear {
            pulse = true
        }
    }

    private var label: String {
        switch model.faceIDPhase {
        case .idle: return "Face ID"
        case .scanning: return "Scanner le visage"
        case .success: return "Face ID validé"
        }
    }

    @ViewBuilder private var icon: some View {
        switch model.faceIDPhase {
        case .idle:
            Image(systemName: "faceid")
                .font(.system(size: 44))
                .foregroundColor(.white)
        case .scanning:
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 2)
                    .frame(width: 64, height: 64)
                    .scaleEffect(pulse ? 1.12 : 0.94)
                    .opacity(pulse ? 0.4 : 1)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                               value: pulse)
                Image(systemName: "faceid")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
        }
    }
}
