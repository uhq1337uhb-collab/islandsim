import WidgetKit
import SwiftUI

@main
struct IslandWidgetBundle: WidgetBundle {
    var body: some Widget {
        IslandActivityWidget()
    }
}

struct IslandActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IslandActivityAttributes.self) { context in
            LockScreenIslandView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: iconFor(context.state.kind))
                        .foregroundColor(.white)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.title)
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .semibold))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.subtitle)
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .tint(.white)
                }
            } compactLeading: {
                Image(systemName: iconFor(context.state.kind))
                    .foregroundColor(.white)
            } compactTrailing: {
                Image(systemName: context.state.isPlaying ? "waveform" : "pause.fill")
                    .foregroundColor(.white)
            } minimal: {
                Image(systemName: iconFor(context.state.kind))
                    .foregroundColor(.white)
            }
        }
    }
}

private func iconFor(_ kind: String) -> String {
    switch kind {
    case "music": return "music.note"
    case "timer": return "timer"
    case "call": return "phone.fill"
    case "charging": return "bolt.fill"
    case "faceID": return "faceid"
    default: return "circle.fill"
    }
}

// Présentation écran verrouillé : la pilule noire, style île
struct LockScreenIslandView: View {
    var state: IslandActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: iconFor(state.kind))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color(white: 0.18)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(state.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                Spacer()
                if state.kind == "music" {
                    Image(systemName: state.isPlaying ? "waveform" : "pause.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            if state.progress > 0 {
                ProgressView(value: state.progress)
                    .tint(.white)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .activityBackgroundTint(Color.black)
    }
}
