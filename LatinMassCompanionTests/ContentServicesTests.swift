import Foundation
@testable import LatinMassCompanion
import Testing

struct ContentServicesTests {
    @Test
    func searchableTextIncludesLinkedLearningContent() {
        let searchableText = makeSearchableCollectPart().searchableText(
            glossaryEntries: TestFixtures.defaultGlossaryEntries,
            pronunciationGuides: TestFixtures.defaultPronunciationGuides
        )

        #expect(searchableText.contains("collect"))
        #expect(searchableText.contains("oration"))
        #expect(searchableText.contains("sit for the epistle"))
        #expect(searchableText.contains("et cum spiritu tuo"))
        #expect(searchableText.contains("response"))
        #expect(searchableText.contains("what the collect does"))
        #expect(searchableText.contains("opening prayer"))
        #expect(searchableText.contains("recover your place"))
    }

    @Test
    func searchReturnsOrderedPartsForBlankQueries() {
        let service = LocalMassSearchService()
        let later = ResolvedMassPart(
            part: TestFixtures.makePart(id: "later", order: 2, title: "Later"),
            massForm: .low
        )
        let earlier = ResolvedMassPart(
            part: TestFixtures.makePart(id: "earlier", order: 1, title: "Earlier"),
            massForm: .low
        )

        let results = runSearch("   ", parts: [later, earlier], service: service)

        #expect(results.parts.map(\.id) == ["earlier", "later"])
        #expect(results.learningItems.isEmpty)
    }

    @Test
    func searchMatchesTokensAcrossProperAndLearningFields() {
        let service = LocalMassSearchService()
        let basePart = TestFixtures.makePart(
            id: "collect-readings",
            order: 2,
            title: "Collect, Epistle, and Gradual"
        )
        let celebration = TestFixtures.makeCelebration(
            id: "easter-sunday",
            title: "Easter Sunday",
            summary: "The Resurrection is the heart of the day.",
            properTitle: "Easter Sunday Propers",
            properSummary: "The proper texts proclaim the Resurrection.",
            properTags: ["resurrection", "alleluia"],
            properGlossaryIDs: ["collect"]
        )
        let matchingPart = ResolvedMassPart(
            basePart: basePart,
            properSection: celebration.properSections[0],
            celebration: celebration,
            massForm: .low
        )
        let otherPart = ResolvedMassPart(
            part: TestFixtures.makePart(id: "other", order: 1, title: "Offertory"),
            massForm: .low
        )

        let results = runSearch("resurrection collect", parts: [matchingPart, otherPart], service: service)

        #expect(results.parts.map(\.id) == ["collect-readings"])
    }

    @Test
    func searchNormalizesPunctuationAndReturnsLearningMatchesSeparately() {
        let service = LocalMassSearchService()
        let communion = ResolvedMassPart(
            part: TestFixtures.makePart(
                id: "communion",
                order: 1,
                title: "Communion",
                summary: "Preparation for Holy Communion.",
                searchAliases: ["domine non sum dignus"],
                glossaryIDs: ["agnus-dei"],
                pronunciationIDs: ["domine-non-sum-dignus"]
            ),
            massForm: .low
        )

        let results = runSearch("lord, i am not worthy", parts: [communion], service: service)

        #expect(results.parts.map(\.id) == ["communion"])
        #expect(results.learningItems.contains(where: {
            if case let .pronunciation(guide) = $0 {
                return guide.id == "domine-non-sum-dignus"
            }
            return false
        }))
    }

    @Test
    func searchReturnsLearningOnlyMatchForParticipationAlias() {
        let service = LocalMassSearchService()
        let ordinaryPart = ResolvedMassPart(
            part: TestFixtures.makePart(
                id: "canon",
                order: 1,
                title: "Canon",
                summary: "The Eucharistic prayer."
            ),
            massForm: .low
        )

        let results = runSearch("first visit", parts: [ordinaryPart], service: service)

        #expect(results.parts.isEmpty)
        #expect(results.learningItems == [.participation(TestFixtures.defaultParticipationGuides[0])])
    }

    @Test
    func searchReturnsChantLearningMatchesSeparatelyFromMassSections() {
        let service = LocalMassSearchService()
        let ordinaryPart = ResolvedMassPart(
            part: TestFixtures.makePart(
                id: "intro",
                order: 1,
                title: "Intro"
            ),
            massForm: .low
        )

        let results = runSearch("gregorian chant", parts: [ordinaryPart], service: service)

        #expect(results.parts.isEmpty)
        #expect(results.learningItems == [.chant(TestFixtures.defaultChantGuides[0])])
    }

    @Test
    func searchRequiresAllTokensBeforeMatchingAPart() {
        let service = LocalMassSearchService()
        let collect = ResolvedMassPart(
            part: TestFixtures.makePart(
                id: "collect-readings",
                order: 1,
                title: "Collect",
                summary: "Opening prayer"
            ),
            massForm: .low
        )
        let canon = ResolvedMassPart(
            part: TestFixtures.makePart(
                id: "canon",
                order: 2,
                title: "Canon",
                summary: "Eucharistic prayer"
            ),
            massForm: .low
        )

        let results = runSearch("collect canon", parts: [collect, canon], service: service)

        #expect(results.parts.isEmpty)
    }
}

private func makeSearchableCollectPart() -> MassPart {
    TestFixtures.makePart(
        id: "collect-readings",
        order: 1,
        title: "Collect",
        summary: "Opening prayer",
        tags: ["readings", "oration"],
        gestureCues: [
            GestureCue(
                id: "cue",
                label: "Sit",
                detail: "Sit for the epistle",
                systemImage: "figure.seated.side"
            )
        ],
        textBlocks: [
            TextBlock(
                id: "text",
                speaker: "Server",
                latin: "Et cum spiritu tuo",
                english: "And with thy spirit",
                rubric: "Response"
            )
        ],
        explanationNotes: [
            ExplanationNote(
                id: "note",
                title: "What the Collect does",
                body: "The prayer gathers the petitions of the Church.",
                sourceID: "ordinary"
            )
        ],
        quickGuidance: [
            QuickGuidance(
                id: "guidance",
                title: "Reconnect here",
                body: "Use the collect to recover your place.",
                sourceID: "translation"
            )
        ],
        glossaryIDs: ["collect"],
        pronunciationIDs: ["et-cum-spiritu-tuo"]
    )
}

private func runSearch(
    _ query: String,
    parts: [ResolvedMassPart],
    service: LocalMassSearchService
) -> LibrarySearchResults {
    service.search(
        query: query,
        in: parts,
        learningContent: LearningContentIndex(
            glossaryEntries: TestFixtures.defaultGlossaryEntries,
            pronunciationGuides: TestFixtures.defaultPronunciationGuides,
            participationGuides: TestFixtures.defaultParticipationGuides,
            chantGuides: TestFixtures.defaultChantGuides
        )
    )
}
