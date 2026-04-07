import SwiftUI

struct RiteTimelineStrip: View {
    let checkpoints: [RiteTimelineCheckpoint]
    let onSelect: (RiteTimelineCheckpoint) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Rite Timeline")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)
                    .accessibilityIdentifier("guide-timeline-title")

                Spacer()

                Text("Tap to jump")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(Array(checkpoints.enumerated()), id: \.element.id) { index, checkpoint in
                        HStack(spacing: 10) {
                            Button {
                                onSelect(checkpoint)
                            } label: {
                                RiteTimelineStripStep(checkpoint: checkpoint)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("timeline-checkpoint-\(checkpoint.id)")

                            if index < checkpoints.count - 1 {
                                Capsule()
                                    .fill(connectorColor(after: checkpoint))
                                    .frame(width: 18, height: 2)
                                    .padding(.top, 18)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.toolFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.gold.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: AppTheme.burgundy.opacity(0.08), radius: 10, y: 4)
    }

    private func connectorColor(after checkpoint: RiteTimelineCheckpoint) -> Color {
        switch checkpoint.state {
        case .completed, .current:
            AppTheme.burgundy.opacity(0.55)
        case .upcoming:
            AppTheme.border
        }
    }
}

private struct RiteTimelineStripStep: View {
    let checkpoint: RiteTimelineCheckpoint

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Circle()
                    .fill(markerFill)
                    .frame(width: 12, height: 12)
                    .overlay {
                        Circle()
                            .stroke(markerStroke, lineWidth: checkpoint.state == .current ? 3 : 1)
                    }

                Text(checkpoint.phaseTitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(phaseColor)
                    .lineLimit(1)
            }

            Text(checkpoint.title)
                .font(.caption.weight(checkpoint.state == .current ? .bold : .semibold))
                .foregroundStyle(titleColor)
                .frame(width: 112, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(cardStroke, lineWidth: checkpoint.state == .current ? 1.5 : 1)
        )
    }

    private var markerFill: Color {
        switch checkpoint.state {
        case .completed:
            AppTheme.burgundy.opacity(0.75)
        case .current:
            AppTheme.burgundy
        case .upcoming:
            AppTheme.secondarySurface
        }
    }

    private var markerStroke: Color {
        checkpoint.state == .upcoming ? AppTheme.border : AppTheme.burgundy.opacity(0.35)
    }

    private var cardFill: Color {
        switch checkpoint.state {
        case .completed:
            AppTheme.burgundy.opacity(0.08)
        case .current:
            AppTheme.burgundy.opacity(0.14)
        case .upcoming:
            AppTheme.secondarySurface
        }
    }

    private var cardStroke: Color {
        checkpoint.state == .current ? AppTheme.burgundy.opacity(0.55) : AppTheme.border
    }

    private var titleColor: Color {
        checkpoint.state == .upcoming ? AppTheme.ink : AppTheme.ink
    }

    private var phaseColor: Color {
        checkpoint.state == .upcoming ? AppTheme.mutedInk : AppTheme.burgundy
    }
}

struct RiteTimelineRail: View {
    let checkpoints: [RiteTimelineCheckpoint]
    let onSelect: (RiteTimelineCheckpoint) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rite Timeline")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("ipad-rite-timeline-title")

            Text("See the shape of the Mass at a glance and jump quickly when you need to rejoin.")
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(checkpoints.enumerated()), id: \.element.id) { index, checkpoint in
                    Button {
                        onSelect(checkpoint)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(markerFill(for: checkpoint))
                                    .frame(width: 12, height: 12)
                                    .overlay {
                                        Circle()
                                            .stroke(markerStroke(for: checkpoint), lineWidth: checkpoint.state == .current ? 3 : 1)
                                    }

                                if index < checkpoints.count - 1 {
                                    Rectangle()
                                        .fill(connectorColor(for: checkpoint))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                        .padding(.top, 6)
                                }
                            }
                            .frame(width: 16)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(checkpoint.title)
                                        .font(.subheadline.weight(checkpoint.state == .current ? .bold : .semibold))
                                        .foregroundStyle(AppTheme.ink)

                                    if checkpoint.state == .current {
                                        PrayerbookBadge(title: "Current", tone: .accent)
                                    }
                                }

                                Text(checkpoint.phaseTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(checkpoint.state == .upcoming ? AppTheme.mutedInk : AppTheme.burgundy)

                                Text(checkpoint.summary)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.mutedInk)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(cardFill(for: checkpoint))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(cardStroke(for: checkpoint), lineWidth: checkpoint.state == .current ? 1.5 : 1)
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("ipad-timeline-\(checkpoint.id)")
                }
            }
        }
        .prayerbookPanel()
    }

    private func markerFill(for checkpoint: RiteTimelineCheckpoint) -> Color {
        switch checkpoint.state {
        case .completed:
            AppTheme.burgundy.opacity(0.75)
        case .current:
            AppTheme.burgundy
        case .upcoming:
            AppTheme.secondarySurface
        }
    }

    private func markerStroke(for checkpoint: RiteTimelineCheckpoint) -> Color {
        checkpoint.state == .upcoming ? AppTheme.border : AppTheme.burgundy.opacity(0.35)
    }

    private func connectorColor(for checkpoint: RiteTimelineCheckpoint) -> Color {
        checkpoint.state == .upcoming ? AppTheme.border : AppTheme.burgundy.opacity(0.45)
    }

    private func cardFill(for checkpoint: RiteTimelineCheckpoint) -> Color {
        switch checkpoint.state {
        case .completed:
            AppTheme.burgundy.opacity(0.08)
        case .current:
            AppTheme.burgundy.opacity(0.14)
        case .upcoming:
            AppTheme.secondarySurface
        }
    }

    private func cardStroke(for checkpoint: RiteTimelineCheckpoint) -> Color {
        checkpoint.state == .current ? AppTheme.burgundy.opacity(0.55) : AppTheme.border
    }
}

struct JumpToSectionView: View {
    let majorMoments: [MajorMomentAnchor]
    let parts: [ResolvedMassPart]
    @Binding var selectedPartID: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if !majorMoments.isEmpty {
                    Section("Major Moments") {
                        ForEach(majorMoments) { anchor in
                            Button {
                                selectedPartID = anchor.partID
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(anchor.title)
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.ink)
                                    Text(anchor.summary)
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.mutedInk)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 6)
                            }
                            .accessibilityIdentifier("jump-moment-\(anchor.partID)")
                        }
                    }
                }

                Section("All Sections") {
                    ForEach(parts) { part in
                        Button {
                            selectedPartID = part.id
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(part.title)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.ink)
                                Text(part.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.mutedInk)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 6)
                        }
                        .accessibilityIdentifier("jump-to-\(part.id)")
                    }
                }
            }
            .navigationTitle("Jump to Major Moments")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct GuideUtilityPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.system(.headline, design: .serif))
            .foregroundStyle(.white)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        configuration.isPressed
                            ? AnyShapeStyle(AppTheme.burgundy)
                            : AnyShapeStyle(AppTheme.strongAccentFill)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.gold.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: AppTheme.burgundy.opacity(configuration.isPressed ? 0.12 : 0.24), radius: 10, y: 4)
    }
}

struct GuideUtilitySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.ink)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        configuration.isPressed
                            ? AnyShapeStyle(AppTheme.secondarySurface.opacity(0.78))
                            : AnyShapeStyle(AppTheme.referenceFill)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.border.opacity(0.92), lineWidth: 1)
            )
    }
}

struct GuideNavigationBar: View {
    let previousTitle: String?
    let nextTitle: String?
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPrevious) {
                Label(previousTitle ?? "Beginning", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GuideNavButtonStyle())
            .disabled(previousTitle == nil)
            .accessibilityIdentifier("previous-section")
            .accessibilityLabel("Previous section")
            .accessibilityValue(previousTitle ?? "Beginning of Mass")

            Button(action: onNext) {
                Label(nextTitle ?? "End", systemImage: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GuideNavButtonStyle())
            .disabled(nextTitle == nil)
            .accessibilityIdentifier("next-section")
            .accessibilityLabel("Next section")
            .accessibilityValue(nextTitle ?? "End of Mass")
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(AppTheme.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.divider)
                .frame(height: 1)
        }
    }
}

struct FindMyPlaceView: View {
    let anchors: [FindMyPlaceAnchor]
    @Binding var selectedPartID: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(anchors) { anchor in
                Button {
                    selectedPartID = anchor.partID
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(anchor.title)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        Text(anchor.summary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.mutedInk)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("find-place-\(anchor.partID)")
            }
            .navigationTitle("Find My Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct GuideNavButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        configuration.isPressed
                            ? AnyShapeStyle(AppTheme.surface.opacity(0.82))
                            : AnyShapeStyle(AppTheme.referenceFill)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}
