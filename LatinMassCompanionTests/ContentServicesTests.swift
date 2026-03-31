import Foundation
@testable import LatinMassCompanion
import Testing

struct ContentServicesTests {
    @Test
    func searchableTextIncludesLinkedLearningContent() {
        let part = TestFixtures.makePart(
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
            glossaryIDs: ["collect"],
            pronunciationIDs: ["et-cum-spiritu-tuo"]
        )

        let searchableText = part.searchableText(
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

        let results = service.search(
            query: "   ",
            in: [later, earlier],
            glossaryEntries: TestFixtures.defaultGlossaryEntries,
            pronunciationGuides: TestFixtures.defaultPronunciationGuides,
            participationGuides: TestFixtures.defaultParticipationGuides,
            chantGuides: TestFixtures.defaultChantGuides
        )

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

        let results = service.search(
            query: "resurrection collect",
            in: [matchingPart, otherPart],
            glossaryEntries: TestFixtures.defaultGlossaryEntries,
            pronunciationGuides: TestFixtures.defaultPronunciationGuides,
            participationGuides: TestFixtures.defaultParticipationGuides,
            chantGuides: TestFixtures.defaultChantGuides
        )

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

        let results = service.search(
            query: "lord, i am not worthy",
            in: [communion],
            glossaryEntries: TestFixtures.defaultGlossaryEntries,
            pronunciationGuides: TestFixtures.defaultPronunciationGuides,
            participationGuides: TestFixtures.defaultParticipationGuides,
            chantGuides: TestFixtures.defaultChantGuides
        )

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

        let results = service.search(
            query: "first visit",
            in: [ordinaryPart],
            glossaryEntries: TestFixtures.defaultGlossaryEntries,
            pronunciationGuides: TestFixtures.defaultPronunciationGuides,
            participationGuides: TestFixtures.defaultParticipationGuides,
            chantGuides: TestFixtures.defaultChantGuides
        )

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

        let results = service.search(
            query: "gregorian chant",
            in: [ordinaryPart],
            glossaryEntries: TestFixtures.defaultGlossaryEntries,
            pronunciationGuides: TestFixtures.defaultPronunciationGuides,
            participationGuides: TestFixtures.defaultParticipationGuides,
            chantGuides: TestFixtures.defaultChantGuides
        )

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

        let results = service.search(
            query: "collect canon",
            in: [collect, canon],
            glossaryEntries: TestFixtures.defaultGlossaryEntries,
            pronunciationGuides: TestFixtures.defaultPronunciationGuides,
            participationGuides: TestFixtures.defaultParticipationGuides,
            chantGuides: TestFixtures.defaultChantGuides
        )

        #expect(results.parts.isEmpty)
    }

    @Test
    func repositoryReportsMissingResources() {
        let repository = BundleMassContentRepository(
            bundle: Bundle(for: TestBundleLocator.self),
            resourceName: "missing_mass_library"
        )

        do {
            _ = try repository.loadCatalog()
            Issue.record("Expected missing resource error")
        } catch let error as MassContentRepositoryError {
            switch error {
            case let .missingResource(name):
                #expect(name == "missing_mass_library")
            case let .unreadableResource(message):
                Issue.record("Expected missing resource error, got unreadable resource: \(message)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func repositoryReportsUnreadableResources() {
        let repository = BundleMassContentRepository(
            bundle: Bundle(for: TestBundleLocator.self),
            resourceName: "invalid_mass_library"
        )

        do {
            _ = try repository.loadCatalog()
            Issue.record("Expected unreadable resource error")
        } catch let error as MassContentRepositoryError {
            switch error {
            case .missingResource:
                Issue.record("Expected unreadable resource error")
            case let .unreadableResource(message):
                #expect(!message.isEmpty)
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
