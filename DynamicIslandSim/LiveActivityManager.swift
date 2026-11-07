import Foundation
import ActivityKit

final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var activity: Activity<IslandActivityAttributes>?

    func start(model: IslandModel) {
        stop()
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        do {
            activity = try Activity.request(
                attributes: IslandActivityAttributes(),
                content: .init(state: Self.state(from: model), staleDate: nil)
            )
        } catch {
            activity = nil
        }
    }

    func update(model: IslandModel) {
        guard let activity else { return }
        Task {
            await activity.update(.init(state: Self.state(from: model), staleDate: nil))
        }
    }

    func stop() {
        for a in Activity<IslandActivityAttributes>.activities {
            Task { await a.end(nil, dismissalPolicy: .immediate) }
        }
        activity = nil
    }

    private static func state(from model: IslandModel) -> IslandActivityAttributes.ContentState {
        .init(songTitle: model.songTitle,
              songArtist: model.songArtist,
              isPlaying: model.isPlaying,
              elapsed: model.elapsed,
              duration: model.duration)
    }
}
