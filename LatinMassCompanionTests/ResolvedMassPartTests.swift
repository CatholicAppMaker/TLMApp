@testable import LatinMassCompanion
import Testing

struct ResolvedMassPartTests {
    @Test
    func properResolutionMergesMetadataAndPreservesBasePhase() {
        let basePart = TestFixtures.makePart(
            id: "collect-readings",
            order: 4,
            phase: .instruction,
            title: "Collect",
            tags: ["ordinary", "shared"],
            liveNote: "Base live note",
            searchAliases: ["base-alias"],
            sourceIDs: ["ordinary"],
            glossaryIDs: ["collect"],
            pronunciationIDs: ["et-cum-spiritu-tuo"]
        )
        let celebration = TestFixtures.makeCelebration(
            id: "easter-sunday",
            title: "Easter Sunday",
            properTitle: "Easter Sunday Propers",
            properTags: ["proper", "shared"],
            properLiveNote: "Proper live note",
            properSearchAliases: ["resurrection"],
            properGlossaryIDs: ["canon"],
            properPronunciationIDs: ["domine-non-sum-dignus"],
            sourceIDs: ["proper"]
        )

        let resolved = ResolvedMassPart(
            basePart: basePart,
            properSection: celebration.properSections[0],
            celebration: celebration,
            massForm: .low
        )

        #expect(resolved.phase == .instruction)
        #expect(resolved.title == "Easter Sunday Propers")
        #expect(resolved.tags == ["ordinary", "proper", "shared"])
        #expect(resolved.liveNote == "Proper live note")
        #expect(resolved.searchAliases == ["base-alias", "resurrection"])
        #expect(resolved.sourceIDs == ["ordinary", "proper"])
        #expect(resolved.glossaryIDs == ["canon", "collect"])
        #expect(resolved.pronunciationIDs == ["domine-non-sum-dignus", "et-cum-spiritu-tuo"])
        #expect(resolved.celebrationID == "easter-sunday")
        #expect(resolved.celebrationTitle == "Easter Sunday")
        #expect(resolved.isProper)
    }

    @Test
    func properResolutionFallsBackToBaseLiveNoteWhenProperNoteIsMissing() {
        let basePart = TestFixtures.makePart(
            id: "collect-readings",
            order: 4,
            title: "Collect",
            liveNote: "Base live note"
        )
        let celebration = TestFixtures.makeCelebration(
            id: "christmas",
            title: "Christmas Day",
            properTitle: "Christmas Day Propers",
            properLiveNote: nil
        )

        let resolved = ResolvedMassPart(
            basePart: basePart,
            properSection: celebration.properSections[0],
            celebration: celebration,
            massForm: .low
        )

        #expect(resolved.liveNote == "Base live note")
    }

    @Test
    func sungFormResolutionMergesBaseAndProperProfiles() {
        let basePart = TestFixtures.makePart(
            id: "kyrie-gloria",
            order: 2,
            phase: .preparation,
            title: "Kyrie and Gloria",
            liveNote: "Base live note",
            formProfiles: [
                MassFormProfile(
                    massForm: .sung,
                    summary: nil,
                    liveNote: "Base sung live note",
                    participationNote: "Base sung participation note",
                    gestureCues: nil,
                    sourceIDs: ["chant"],
                    chantGuideIDs: ["chant-what-is-it"]
                )
            ]
        )
        let celebration = TestFixtures.makeCelebration(
            id: "christmas",
            title: "Christmas Day",
            replacesPartID: "kyrie-gloria",
            properTitle: "Christmas Entrance Proper",
            properFormProfiles: [
                MassFormProfile(
                    massForm: .sung,
                    summary: nil,
                    liveNote: "Proper sung live note",
                    participationNote: "Proper sung participation note",
                    gestureCues: nil,
                    sourceIDs: ["translation"],
                    chantGuideIDs: ["chant-how-to-listen"]
                )
            ],
            sourceIDs: ["proper"]
        )

        let resolved = ResolvedMassPart(
            basePart: basePart,
            properSection: celebration.properSections[0],
            celebration: celebration,
            massForm: .sung
        )

        #expect(resolved.liveNote == "Proper sung live note")
        #expect(resolved.participationNote == "Proper sung participation note")
        #expect(resolved.chantGuideIDs == ["chant-how-to-listen", "chant-what-is-it"])
        #expect(resolved.sourceIDs == ["chant", "ordinary", "proper", "translation"])
        #expect(resolved.massForm == MassForm.sung)
    }

    @Test
    func sourceReferenceIDsIncludeExplanationSourcesWithoutDuplicates() {
        let part = TestFixtures.makePart(
            id: "collect-readings",
            order: 4,
            title: "Collect",
            explanationNotes: [
                ExplanationNote(
                    id: "ordinary-note",
                    title: "Ordinary source",
                    body: "Body",
                    sourceID: "ordinary"
                ),
                ExplanationNote(
                    id: "translation-note",
                    title: "Translation source",
                    body: "Body",
                    sourceID: "translation"
                )
            ],
            sourceIDs: ["ordinary"]
        )

        let resolved = ResolvedMassPart(part: part, massForm: .low)

        #expect(resolved.sourceReferenceIDs == ["ordinary", "translation"])
    }
}
