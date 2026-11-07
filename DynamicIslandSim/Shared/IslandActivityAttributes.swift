import Foundation
import ActivityKit

// Partagé entre l'app et l'extension Widget
struct IslandActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var songTitle: String
        var songArtist: String
        var isPlaying: Bool
        var elapsed: TimeInterval
        var duration: TimeInterval
    }
}
