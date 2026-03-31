import SwiftUI

struct SourcesView: View {
    let coverageWindowTitle: String
    let coverageWindowDateText: String
    let sources: [SourceReference]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            List {
                if !coverageWindowDateText.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(coverageWindowTitle)
                                .font(.headline)
                                .foregroundStyle(AppTheme.ink)

                            Text(coverageWindowDateText)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.burgundy)
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(AppTheme.surface)
                    }
                }

                Section {
                    ForEach(sources) { source in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(source.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.ink)

                            Text(source.description)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.mutedInk)

                            if let attribution = source.attribution {
                                Text(attribution)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.ink)
                            }

                            if let rights = source.rights {
                                Text(rights)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.burgundy)
                            } else {
                                Text(source.note)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.burgundy)
                            }

                            if let coverageNote = source.coverageNote {
                                Text(coverageNote)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.mutedInk)
                            }

                            if let url = source.url {
                                Link(url, destination: URL(string: url)!)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(AppTheme.surface)
                    }
                } header: {
                    Text("Bundled Sources")
                } footer: {
                    Text("Section-level sources are carried into each part so the app can show where celebration and learning content came from.")
                        .foregroundStyle(AppTheme.mutedInk)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Sources")
        .navigationBarTitleDisplayMode(.inline)
    }
}
