import SwiftUI

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
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.burgundy.opacity(configuration.isPressed ? 0.85 : 1.0))
            )
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
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.secondarySurface.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
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
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.surface.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}
