import Foundation

struct LearningContentIndex: Sendable {
    let glossaryEntries: [GlossaryEntry]
    let pronunciationGuides: [PronunciationGuide]
    let participationGuides: [ParticipationGuide]
    let chantGuides: [ChantGuide]
}

protocol SearchService {
    func search(
        query: String,
        in parts: [ResolvedMassPart],
        learningContent: LearningContentIndex
    ) -> LibrarySearchResults
}

struct LocalMassSearchService: SearchService {
    func search(
        query: String,
        in parts: [ResolvedMassPart],
        learningContent: LearningContentIndex
    ) -> LibrarySearchResults {
        let normalizedQuery = Self.normalize(query)

        guard !normalizedQuery.isEmpty else {
            return LibrarySearchResults(
                parts: parts.sorted { $0.order < $1.order },
                learningItems: []
            )
        }

        let tokens = normalizedQuery.split(separator: " ").map(String.init)
        let matchingParts = parts
            .filter { part in
                let linkedGlossary = learningContent.glossaryEntries.filter { part.glossaryIDs.contains($0.id) }
                let linkedPronunciation = learningContent.pronunciationGuides.filter { part.pronunciationIDs.contains($0.id) }
                let searchableText = Self.normalize(part.searchableText(
                    glossaryEntries: linkedGlossary,
                    pronunciationGuides: linkedPronunciation
                ))
                return tokens.allSatisfy(searchableText.contains(_:))
            }
            .sorted { $0.order < $1.order }

        let matchingLearningItems =
            learningContent.glossaryEntries
                .filter { matches(tokens: tokens, text: $0.searchableText) }
                .map(LearningSearchResult.glossary)
                + learningContent.pronunciationGuides
                .filter { matches(tokens: tokens, text: $0.searchableText) }
                .map(LearningSearchResult.pronunciation)
                + learningContent.participationGuides
                .filter { matches(tokens: tokens, text: $0.searchableText) }
                .map(LearningSearchResult.participation)
                + learningContent.chantGuides
                .filter { matches(tokens: tokens, text: $0.searchableText) }
                .map(LearningSearchResult.chant)

        return LibrarySearchResults(
            parts: matchingParts,
            learningItems: matchingLearningItems
        )
    }

    private func matches(tokens: [String], text: String) -> Bool {
        let searchableText = Self.normalize(text)
        return tokens.allSatisfy(searchableText.contains(_:))
    }

    private static func normalize(_ text: String) -> String {
        let folded = text.folding(
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
            locale: .current
        )
        let normalized = String(
            folded.unicodeScalars.map { scalar in
                CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : " "
            }
        )

        return normalized
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
