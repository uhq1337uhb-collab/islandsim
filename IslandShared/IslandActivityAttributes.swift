import Foundation
import ActivityKit

// Attributs partagés entre l'app (producteur) et le widget (présentation)
struct IslandActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var subtitle: String
        var progress: Double
        var isPlaying: Bool
        var kind: String
    }

    var activityName: String
}
