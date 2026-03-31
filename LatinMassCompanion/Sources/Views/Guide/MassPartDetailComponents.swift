import SwiftUI

struct GestureCueRow: View {
    let cue: GestureCue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: cue.systemImage)
                .foregroundStyle(AppTheme.burgundy)
                .font(.headline)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(cue.label)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)
                Text(cue.detail)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
    }
}

struct QuickGuidanceCard: View {
    let guidance: QuickGuidance
    let sourceReference: SourceReference?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(guidance.title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)

            Text(guidance.body)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

            if let sourceReference {
                SourceAttributionLine(references: [sourceReference])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.insetPanelFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppTheme.border.opacity(0.85), lineWidth: 1)
        )
    }
}

struct TextBlockCard: View {
    let block: TextBlock

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(block.speaker)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.burgundy)

                Spacer()

                if let rubric = block.rubric {
                    Text(rubric)
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                        .multilineTextAlignment(.trailing)
                }
            }

            Text(block.latin)
                .font(.system(.body, design: .serif))
                .foregroundStyle(AppTheme.ink)

            LiturgicalRule()

            Text(block.english)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.secondarySurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppTheme.border.opacity(0.85), lineWidth: 1)
        )
    }
}

struct LearnLinkButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.secondarySurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.border.opacity(0.85), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open learning note for \(title)")
    }
}

struct ExplanationCard: View {
    let note: ExplanationNote
    let sourceReference: SourceReference?
    let isExpanded: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: toggle) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(AppTheme.ink)
                        if let sourceReference {
                            Text("Anchored by \(sourceReference.title)")
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedInk)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(AppTheme.burgundy)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(note.title)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.body)
                        .font(.body)
                        .foregroundStyle(AppTheme.mutedInk)

                    if let sourceReference {
                        SourceAttributionLine(references: [sourceReference])
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.insetPanelFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppTheme.border.opacity(0.85), lineWidth: 1)
        )
    }
}
