import Foundation

extension AppModel {
    var orderedParts: [ResolvedMassPart] {
        resolvedDay.parts
    }

    var bookmarkedParts: [ResolvedMassPart] {
        orderedParts.filter { bookmarks.contains($0.id) }
    }

    var majorMomentAnchors: [MajorMomentAnchor] {
        guideAnchorMatches.map {
            MajorMomentAnchor(
                id: $0.id,
                title: $0.title,
                summary: $0.part.summary,
                partID: $0.part.id
            )
        }
    }

    func riteTimelineCheckpoints(activePartID: String?) -> [RiteTimelineCheckpoint] {
        guard !guideAnchorMatches.isEmpty else {
            return []
        }

        let currentPartIndex = orderedParts.firstIndex(where: { $0.id == activePartID }) ?? 0
        let checkpointPartIndices = guideAnchorMatches.map { anchor in
            orderedParts.firstIndex(where: { $0.id == anchor.part.id }) ?? 0
        }
        let currentCheckpointIndex =
            checkpointPartIndices.lastIndex(where: { $0 <= currentPartIndex }) ?? 0

        return guideAnchorMatches.enumerated().map { index, anchor in
            let state: RiteTimelineCheckpointState
            if index < currentCheckpointIndex {
                state = .completed
            } else if index == currentCheckpointIndex {
                state = .current
            } else {
                state = .upcoming
            }

            return RiteTimelineCheckpoint(
                id: anchor.id,
                title: anchor.title,
                summary: anchor.part.summary,
                partID: anchor.part.id,
                phaseTitle: anchor.part.phase.title,
                state: state
            )
        }
    }

    var selectedDateKey: String {
        Self.storageDateFormatter.string(from: selectedDate)
    }

    var selectedDateTitle: String {
        if calendar.isDate(selectedDate, inSameDayAs: now()) {
            return "Today"
        }

        return Self.shortDateFormatter.string(from: selectedDate)
    }

    var selectedDateLongTitle: String {
        Self.displayDateFormatter.string(from: selectedDate)
    }

    var selectedMassFormTitle: String {
        selectedMassForm.title
    }

    var selectedMassFormSubtitle: String {
        selectedMassForm.subtitle
    }

    var bookmarkCountText: String {
        let count = bookmarks.count
        return count == 1 ? "1 saved section" : "\(count) saved sections"
    }

    var celebrationListings: [CelebrationListing] {
        let celebrationByID = Dictionary(uniqueKeysWithValues: celebrations.map { ($0.id, $0) })

        return dateIndex.compactMap { entry in
            guard
                let celebration = celebrationByID[entry.celebrationID],
                let date = Self.storageDateFormatter.date(from: entry.date)
            else {
                return nil
            }

            return CelebrationListing(
                date: date,
                dateKey: entry.date,
                title: celebration.title,
                subtitle: celebration.subtitle,
                summary: celebration.summary,
                rank: celebration.rank,
                celebrationID: celebration.id,
                coverageStatus: coverageStatus(for: date, matchedCelebration: celebration),
                monthTitle: Self.monthSectionFormatter.string(from: date),
                shortDateText: Self.shortDateFormatter.string(from: date),
                longDateText: Self.displayDateFormatter.string(from: date)
            )
        }
        .sorted { $0.date < $1.date }
    }

    var selectedCelebrationListing: CelebrationListing? {
        celebrationListings.first(where: { $0.dateKey == selectedDateKey })
    }

    var bundledCoverageSummary: String {
        "\(celebrationListings.count) bundled 2026 Sundays and major feasts."
    }

    func celebrationSections(matching query: String) -> [CelebrationMonthSection] {
        let filteredListings = celebrationListings.filter { $0.matches(query) }
        let grouped = Dictionary(grouping: filteredListings, by: \.monthTitle)

        return celebrationListings
            .map(\.monthTitle)
            .reduce(into: [String]()) { titles, title in
                if !titles.contains(title) {
                    titles.append(title)
                }
            }
            .compactMap { title in
                guard let listings = grouped[title], !listings.isEmpty else {
                    return nil
                }

                return CelebrationMonthSection(title: title, listings: listings)
            }
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

    var currentCoverageBadgeTitle: String {
        resolvedDay.coverageStatus.calendarBadgeTitle
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
            "\(selectedDateLongTitle) • \(formText) • \(resolvedDay.subtitle)"
        case .ordinaryOnlyWithinSupportedWindow:
            "\(selectedDateLongTitle) • \(formText) • Ordinary only"
        case .outsideSupportedWindow:
            "\(selectedDateLongTitle) • \(formText) • Outside bundled coverage"
        }
    }

    var currentCelebration: Celebration? {
        resolvedDay.celebration
    }

    var savedProgressContext: SavedProgressContext? {
        guard let progress, let date = Self.storageDateFormatter.date(from: progress.dateKey) else {
            return nil
        }

        let resolvedDay = resolveDay(for: date, massForm: progress.massForm)
        guard let part = resolvedDay.parts.first(where: { $0.id == progress.sectionID }) else {
            return nil
        }

        return SavedProgressContext(
            progress: progress,
            date: date,
            resolvedDay: resolvedDay,
            part: part
        )
    }

    var resumePreview: ResumePreview? {
        guard let savedProgressContext else {
            return nil
        }

        return ResumePreview(
            partTitle: savedProgressContext.part.title,
            celebrationTitle: savedProgressContext.resolvedDay.title,
            dateText: Self.displayDateFormatter.string(from: savedProgressContext.date),
            massFormTitle: savedProgressContext.progress.massForm.title,
            lastOpenedText: Self.relativeFormatter.localizedString(
                for: savedProgressContext.progress.lastOpenedAt,
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

    var findMyPlaceAnchors: [FindMyPlaceAnchor] {
        var anchors: [FindMyPlaceAnchor] = []

        func appendAnchor(title: String, matchingAnchorID anchorID: String) {
            guard let anchor = majorMomentAnchors.first(where: { $0.id == anchorID }) else {
                return
            }

            anchors.append(
                FindMyPlaceAnchor(
                    id: anchor.id,
                    title: title,
                    summary: anchor.summary,
                    partID: anchor.partID
                )
            )
        }

        if let firstPart = orderedParts.first {
            anchors.append(
                FindMyPlaceAnchor(
                    id: "beginning",
                    title: "Beginning",
                    summary: firstPart.summary,
                    partID: firstPart.id
                )
            )
        }

        appendAnchor(title: "Readings", matchingAnchorID: "collect-readings")
        appendAnchor(title: "Offertory", matchingAnchorID: "offertory")
        appendAnchor(title: "Canon", matchingAnchorID: "canon")
        appendAnchor(title: "Communion", matchingAnchorID: "communion")
        appendAnchor(title: "Last Gospel", matchingAnchorID: "last-gospel")

        return anchors
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

private extension AppModel {
    struct GuideAnchorMatch {
        let id: String
        let title: String
        let part: ResolvedMassPart
    }

    var guideAnchorMatches: [GuideAnchorMatch] {
        var seenPartIDs = Set<String>()
        var matches: [GuideAnchorMatch] = []

        func appendAnchor(
            id: String,
            title: String,
            matcher: (ResolvedMassPart) -> Bool
        ) {
            guard let part = orderedParts.first(where: matcher),
                  seenPartIDs.insert(part.id).inserted
            else {
                return
            }

            matches.append(
                GuideAnchorMatch(
                    id: id,
                    title: title,
                    part: part
                )
            )
        }

        appendAnchor(id: "foot-of-the-altar", title: "Prayers at the Foot of the Altar") {
            $0.id.localizedCaseInsensitiveContains("foot")
                || $0.title.localizedCaseInsensitiveContains("Foot of the Altar")
        }
        appendAnchor(id: "kyrie-gloria", title: "Kyrie / Gloria") {
            $0.id.localizedCaseInsensitiveContains("kyrie")
                || $0.title.localizedCaseInsensitiveContains("Kyrie")
                || $0.title.localizedCaseInsensitiveContains("Gloria")
        }
        appendAnchor(id: "collect-readings", title: "Collect / Readings") {
            $0.id.localizedCaseInsensitiveContains("collect")
                || $0.title.localizedCaseInsensitiveContains("Collect")
        }
        appendAnchor(id: "offertory", title: "Offertory") {
            $0.phase == .offertory
        }
        appendAnchor(id: "canon", title: "Canon") {
            $0.phase == .canon
        }
        appendAnchor(id: "communion", title: "Communion") {
            $0.phase == .communion
        }
        appendAnchor(id: "last-gospel", title: "Last Gospel") {
            $0.id.localizedCaseInsensitiveContains("last-gospel")
                || $0.title.localizedCaseInsensitiveContains("Last Gospel")
        }

        if let finalPart = orderedParts.last,
           !seenPartIDs.contains(finalPart.id)
        {
            matches.append(
                GuideAnchorMatch(
                    id: "final-section",
                    title: finalPart.title,
                    part: finalPart
                )
            )
        }

        return matches
    }

    static let monthSectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
}
