import SwiftUI

enum IslandMode: String, CaseIterable, Identifiable {
    case compact, minimal, expanded

    var id: String { rawValue }

    var label: String {
        switch self {
        case .compact: return "Compacte"
        case .minimal: return "Minimale"
        case .expanded: return "Déployée"
        }
    }
}

enum IslandContent: String, CaseIterable, Identifiable {
    case music, timer, call, charging, faceID

    var id: String { rawValue }

    var label: String {
        switch self {
        case .music: return "Musique"
        case .timer: return "Minuteur"
        case .call: return "Appel"
        case .charging: return "Charge"
        case .faceID: return "Face ID"
        }
    }

    var symbol: String {
        switch self {
        case .music: return "music.note"
        case .timer: return "timer"
        case .call: return "phone.fill"
        case .charging: return "bolt.fill"
        case .faceID: return "faceid"
        }
    }
}

enum FaceIDPhase {
    case idle, scanning, success
}

final class IslandModel: ObservableObject {
    @Published var mode: IslandMode = .compact
    @Published var content: IslandContent = .music

    // Musique
    @Published var songTitle = "Néon"
    @Published var songArtist = "Nova Bloom"
    var artColors: [Color] = [
        Color(red: 0.42, green: 0.13, blue: 0.65),
        Color(red: 0.98, green: 0.42, blue: 0.44)
    ]
    @Published var isPlaying = true
    @Published var elapsed: TimeInterval = 87
    var duration: TimeInterval = 214

    // Minuteur
    var timerTotal: TimeInterval = 600
    @Published var timerRemaining: TimeInterval = 437

    // Appel
    @Published var callerName = "Léo"
    @Published var callAccepted = false

    // Charge
    @Published var batteryLevel = 68
    @Published var chargingMinutesLeft = 24

    // Face ID
    @Published var faceIDPhase: FaceIDPhase = .idle

    var timerProgress: Double {
        timerTotal > 0 ? timerRemaining / timerTotal : 0
    }

    func timeString(_ t: TimeInterval) -> String {
        let total = Int(max(0, t))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    func tick() {
        if isPlaying {
            elapsed += 1
            if elapsed >= duration { elapsed = 0 }
        }
        if timerRemaining > 0 {
            timerRemaining -= 1
        }
    }

    func togglePlay() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isPlaying.toggle()
        }
    }

    func runFaceID() {
        guard case .idle = faceIDPhase else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            faceIDPhase = .scanning
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    self.faceIDPhase = .success
                }
            }
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            await MainActor.run {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    self.faceIDPhase = .idle
                }
            }
        }
    }
}
