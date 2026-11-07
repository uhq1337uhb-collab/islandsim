import WidgetKit
import SwiftUI
import ActivityKit

struct IslandLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IslandActivityAttributes.self) { context in
            LockIslandView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.92))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(LinearGradient(colors: [Color(red: 0.42, green: 0.13, blue: 0.65),
                                                      Color(red: 0.98, green: 0.42, blue: 0.44)],
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
                        .frame(width: 36, height: 36)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.songTitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(context.state.songArtist)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.elapsed, total: max(1, context.state.duration))
                        .tint(.white)
                }
            } compactLeading: {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.42, green: 0.13, blue: 0.65),
                                                  Color(red: 0.98, green: 0.42, blue: 0.44)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .frame(width: 18, height: 18)
            } compactTrailing: {
                Image(systemName: context.state.isPlaying ? "waveform" : "pause.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            } minimal: {
                Image(systemName: "music.note")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            }
        }
    }
}

// Vue de l'écran verrouillé : la pilule noire façon Dynamic Island
struct LockIslandView: View {
    var state: IslandActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.42, green: 0.13, blue: 0.65),
                                              Color(red: 0.98, green: 0.42, blue: 0.44)],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(state.songTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(state.songArtist)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                ProgressView(value: state.elapsed, total: max(1, state.duration))
                    .tint(.white)
                    .frame(height: 3)
            }
            Spacer()
            Image(systemName: state.isPlaying ? "waveform" : "pause.fill")
                .foregroundColor(.white)
        }
        .padding(12)
    }
}
