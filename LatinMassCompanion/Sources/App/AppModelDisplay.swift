import Foundation

extension AppModel {
    var orderedParts: [ResolvedMassPart] {
        resolvedDay.parts
    }

    var bookmarkedParts: [ResolvedMassPart] {
        orderedParts.filter { bookmarks.contains($0.id) }
    }

    var selectedDateKey: String {
        Self.storageDateFormatter.string(from: selectedDate)
    }

    var selectedDateTitle: String {
        Self.displayDateFormatter.string(from: selectedDate)
    }

    var selectedMassFormTitle: String {
        selectedMassForm.title
    }

    var selectedMassFormSubtitle: String {
        selectedMassForm.subtitle
    }

    var isShowingOrdinaryOnly: Bool {
        resolvedDay.isOrdinaryOnly
    }

    var isOutsideCoverageWindow: Bool {
        resolvedDay.coverageStatus == .outsideSupportedWindow
    }

    var selectedCelebrationTitle: String {
        resolvedDay.title
    }

    var selectedCelebrationSubtitle: String {
        resolvedDay.subtitle
    }

    var selectedCelebrationSummary: String {
        resolvedDay.summary
    }

    var availabilitySummary: String {
        switch resolvedDay.coverageStatus {
        case .properAvailable:
            """
            Bundled propers and form-aware guidance are available for this celebration within the app's stated 2026 scope.
            The app is meant to orient you confidently without pretending to replace a full missal or to cover dates outside the bundle.
            """
        case .ordinaryOnlyWithinSupportedWindow:
            """
            This date is inside the supported year window, but no bundled propers are included for it.
            The Ordinary remains fully available without guessing missing texts or inventing coverage the bundle does not contain.
            """
        case .outsideSupportedWindow:
            """
            This date is outside the bundled year window.
            The app falls back to the fixed Ordinary of the Mass and does not invent missing propers.
            """
        }
    }

    var expectationSummary: String {
        switch selectedMassForm {
        case .low:
            """
            Follow the quieter structure of Low Mass first.
            If you lose your place, rejoin using the posture cues,
            section titles, and the broad movement of the rite rather than
            forcing constant line-by-line tracking. The silence is part of the rite's teaching.
            """
        case .sung:
            """
            Expect slower ceremonial pacing, sung Ordinary parts,
            and stronger chant cues. The guide keeps the same
            structure while pointing out where sung elements
            change the live experience. Listen for major chant
            landmarks before worrying about every syllable or every page turn.
            """
        }
    }

    var coverageTitle: String {
        resolvedDay.coverageStatus.title
    }

    var coverageSummary: String {
        resolvedDay.coverageStatus.summary(
            coverageWindowTitle: coverageWindow?.title,
            coverageDescription: coverageWindow?.description
        )
    }

    var coverageWindowTitle: String {
        coverageWindow?.title ?? "Bundled Coverage"
    }

    var coverageWindowDescription: String {
        coverageWindow?.description ?? ""
    }

    var coverageWindowDateText: String {
        guard let coverageWindow else {
            return ""
        }

        guard
            let startDate = Self.storageDateFormatter.date(from: coverageWindow.startDate),
            let endDate = Self.storageDateFormatter.date(from: coverageWindow.endDate)
        else {
            return "\(coverageWindow.startDate) to \(coverageWindow.endDate)"
        }

        return """
        \(Self.shortDateFormatter.string(from: startDate))
        to
        \(Self.shortDateFormatter.string(from: endDate))
        """
        .replacingOccurrences(of: "\n", with: " ")
    }

    var guideHeaderTitle: String {
        resolvedDay.title
    }

    var orientationGuides: [ParticipationGuide] {
        participationGuides.filter { $0.kind == .orientation }
    }

    var changeGuides: [ParticipationGuide] {
        participationGuides.filter { $0.kind == .changes }
    }

    var participationHelpGuides: [ParticipationGuide] {
        participationGuides.filter { $0.kind == .participation }
    }

    var guideHeaderSubtitle: String {
        let formText = selectedMassForm.title

        return switch resolvedDay.coverageStatus {
        case .properAvailable:
            "\(selectedDateTitle) • \(formText) • \(resolvedDay.subtitle)"
        case .ordinaryOnlyWithinSupportedWindow:
            "\(selectedDateTitle) • \(formText) • Ordinary only"
        case .outsideSupportedWindow:
            "\(selectedDateTitle) • \(formText) • Outside bundled coverage"
        }
    }

    var currentCelebration: Celebration? {
        resolvedDay.celebration
    }

    var resumePreview: ResumePreview? {
        guard let progress, let date = Self.storageDateFormatter.date(from: progress.dateKey) else {
            return nil
        }

        let selectedMassForm = progress.massForm
        let resolvedDay = resolveDay(for: date, massForm: selectedMassForm)
        guard let part = resolvedDay.parts.first(where: { $0.id == progress.sectionID }) else {
            return nil
        }

        return ResumePreview(
            partTitle: part.title,
            celebrationTitle: resolvedDay.title,
            dateText: Self.displayDateFormatter.string(from: date),
            massFormTitle: selectedMassForm.title,
            lastOpenedText: Self.relativeFormatter.localizedString(
                for: progress.lastOpenedAt,
                relativeTo: now()
            )
        )
    }

    func sourceReferences(for part: ResolvedMassPart) -> [SourceReference] {
        sourceReferences(for: part.sourceReferenceIDs)
    }

    func sourceReferences(for ids: [String]) -> [SourceReference] {
        let idSet = Set(ids)
        return sources.filter { idSet.contains($0.id) }.sorted { $0.title < $1.title }
    }

    func sourceReference(withID id: String?) -> SourceReference? {
        guard let id else {
            return nil
        }

        return sources.first(where: { $0.id == id })
    }

    func guideOrientation(for part: ResolvedMassPart) -> GuideOrientation {
        let upcomingPart = self.part(after: part)
        return GuideOrientation(
            positionText: "Section \(displayIndex(for: part)) of \(orderedParts.count)",
            phaseTitle: part.phase.title,
            massFormTitle: part.massForm.title,
            liveNote: part.liveNote,
            participationNote: part.participationNote,
            nextPartTitle: upcomingPart?.title,
            nextPartSummary: upcomingPart?.summary
        )
    }

    func chantGuides(for part: ResolvedMassPart) -> [ChantGuide] {
        let ids = Set(part.chantGuideIDs)
        return chantGuides.filter { ids.contains($0.id) }.sorted { $0.title < $1.title }
    }

    func resolveDay(for date: Date, massForm: MassForm) -> ResolvedDay {
        let dateKey = Self.storageDateFormatter.string(from: date)
        let celebrationByID = Dictionary(uniqueKeysWithValues: celebrations.map { ($0.id, $0) })
        let matchedCelebration = dateIndex
            .first(where: { $0.date == dateKey })
            .flatMap { celebrationByID[$0.celebrationID] }
        let coverageStatus = coverageStatus(for: date, matchedCelebration: matchedCelebration)

        let replacementLookup = Dictionary(
            uniqueKeysWithValues: matchedCelebration?.properSections.map { ($0.replacesPartID, $0) } ?? []
        )

        let parts = ordinaryParts.map { part in
            if let replacement = replacementLookup[part.id], let matchedCelebration {
                return ResolvedMassPart(
                    basePart: part,
                    properSection: replacement,
                    celebration: matchedCelebration,
                    massForm: massForm
                )
            }

            return ResolvedMassPart(part: part, massForm: massForm)
        }

        return ResolvedDay(
            date: date,
            celebration: matchedCelebration,
            parts: parts,
            coverageStatus: coverageStatus
        )
    }
}
