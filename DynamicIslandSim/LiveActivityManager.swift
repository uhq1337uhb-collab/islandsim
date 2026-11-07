import Foundation
import ActivityKit

// Gestion du Live Activity : pilule affichée sur l'écran verrouillé
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var activity: Activity<IslandActivityAttributes>?

    func start(_ model: IslandModel) {
        end()
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = IslandActivityAttributes(activityName: "IslandSim")
        let state = IslandActivityAttributes.ContentState(
            title: model.content.label,
            subtitle: subtitle(for: model),
            progress: progress(for: model),
            isPlaying: model.isPlaying,
            kind: model.content.rawValue)
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil))
        } catch {
            activity = nil
        }
    }

    func update(_ model: IslandModel) {
        guard let activity else { return }
        let state = IslandActivityAttributes.ContentState(
            title: model.content.label,
            subtitle: subtitle(for: model),
            progress: progress(for: model),
            isPlaying: model.isPlaying,
            kind: model.content.rawValue)
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func end() {
        guard let activity else { return }
        self.activity = nil
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private func subtitle(for model: IslandModel) -> String {
        switch model.content {
        case .music:
            return model.isPlaying ? model.songTitle + " — " + model.songArtist : "En pause"
        case .timer:
            return "Restant : " + model.timeString(model.timerRemaining)
        case .call:
            return model.callAccepted ? "En appel avec " + model.callerName : "Appel entrant…"
        case .charging:
            return "\(model.batteryLevel)% — ≈ \(model.chargingMinutesLeft) min"
        case .faceID:
            return "Authentification"
        }
    }

    private func progress(for model: IslandModel) -> Double {
        switch model.content {
        case .music:
            return model.duration > 0 ? model.elapsed / model.duration : 0
        case .timer:
            return model.timerProgress
        case .charging:
            return Double(model.batteryLevel) / 100.0
        default:
            return 0
        }
    }
}
