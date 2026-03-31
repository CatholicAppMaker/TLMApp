import SwiftUI

struct SourcesView: View {
    let coverageWindowTitle: String
    let coverageWindowDateText: String
    let sources: [SourceReference]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.backgroundWash)
                .ignoresSafeArea()

            List {
                if !coverageWindowDateText.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(coverageWindowTitle)
                                .font(.system(.headline, design: .serif))
                                .foregroundStyle(AppTheme.ink)

                            Text(coverageWindowDateText)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.burgundy)

                            Text(
                                """
                                This app is intentionally bounded. It keeps the Ordinary available everywhere,
                                while date-specific material is limited to the bundled year and the celebrations
                                listed below. The goal is clarity and trust, not false completeness. Public-domain
                                hand missals anchor the liturgical core; editorial adaptation is surfaced rather
                                than hidden.
                                """
                            )
                            .font(.caption)
                            .foregroundStyle(AppTheme.mutedInk)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(AppTheme.surface)
                    }
                }

                Section {
                    ForEach(sources) { source in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Text(source.title)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundStyle(AppTheme.ink)

                                Spacer(minLength: 12)

                                if let category = source.category {
                                    PrayerbookBadge(title: category.capitalized, tone: .neutral)
                                }
                            }

                            Text(source.description)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.mutedInk)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(source.note)
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedInk)
                                .fixedSize(horizontal: false, vertical: true)

                            if let attribution = source.attribution {
                                Text(attribution)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let rights = source.rights {
                                Text(rights)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.burgundy)
                            }

                            if let coverageNote = source.coverageNote {
                                Text(coverageNote)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.mutedInk)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let url = source.url {
                                Link("Reference Link", destination: URL(string: url)!)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.burgundy)
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(AppTheme.surface)
                    }
                } header: {
                    Text("Bundled Sources")
                } footer: {
                    Text(
                        """
                        Section-level sources are carried into each part so the app can show where celebration,
                        learning, and chant content came from without implying broader coverage than it actually
                        bundles. If a text or explanation is adapted, the source note names that plainly.
                        """
                    )
                    .foregroundStyle(AppTheme.mutedInk)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Sources")
        .navigationTitle("Sources & Rights")
        .navigationBarTitleDisplayMode(.inline)
    }
}
