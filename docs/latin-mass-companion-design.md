# Latin Mass Companion Design Doc

## Overview
Latin Mass Companion is an iPhone-first, offline-first SwiftUI app that helps both Catholics and non-Catholics follow the 1962 Low Mass in real time. The product combines side-by-side Latin and English text with concise explanations so a newcomer can understand both what is happening and why it matters, without needing to bring a separate hand missal or prior familiarity with the Traditional Latin Mass.

The primary audience is future builders working in this repo: engineers, designers, and content editors who need one document that explains the current product shape and the intended next phase. This is an internal design spec, not a pitch or marketing brief.

### Problem Statement
- Newcomers often find the Traditional Latin Mass difficult to follow because the structure, language, silence, and gestures are unfamiliar.
- Existing missal resources can be rich but intimidating, especially during live use in church.
- The app needs to be usable without network access and simple enough to support in a native offline bundle.

### Product Thesis
- A guided, section-by-section companion is a better v1 entry point than a full digital hand missal.
- Side-by-side liturgical text plus short explanations lowers the barrier for first-time attendance without flattening the sacred character of the Mass.
- A content-driven app architecture makes future expansion possible without rebuilding the product shell.

### Success Criteria
- A first-time visitor can open the app before Mass and understand how to use it.
- A newcomer can move through the core flow of the Low Mass offline.
- An experienced attendee can jump quickly to a known section or saved bookmark.
- Future builders can add content and extend the product without introducing a backend.

## Current Product Shape
The current app is intentionally narrow and stable.

- Platform: iPhone only
- Runtime model: fully offline after install
- Liturgical scope: 1962 Low Mass structure only
- Content policy: bundled public-domain content only
- App shell: three-tab `TabView` with `Intro`, `Guide`, and `Library`

### Tab Responsibilities
- `Intro`: onboarding, audience framing, usage guidance during Mass, and source visibility
- `Guide`: primary guided experience through the Mass in liturgical order
- `Library`: searchable index of sections plus bookmark-based filtering

### Current Feature Set
- Bundled Mass content loaded from `mass_library.json`
- Guided navigation through Mass sections
- Side-by-side Latin and English text blocks
- Expandable explanation notes
- Gesture and posture prompts where useful
- Jump list from the guided flow
- Local full-text search
- Local bookmark persistence
- Simple sources and rights view

### Explicit Non-Goals in Current App
- High Mass or Sung Mass support
- Liturgical calendar logic and day-specific proper selection
- Accounts, sync, or backend content delivery
- Audio, media, or live-follow automation
- Licensed or copyrighted missal text integration

## Current UX Flows
### Intro Flow
The app opens on `Intro`, not directly into the Mass guide. This is intentional.

- The opening hero establishes the audience, offline-first posture, and public-domain content policy.
- Supporting cards explain who the app is for, how to use it during Mass, and what parts of the liturgy change day to day.
- The main actions send the user into either `Guide` or `Library`.
- A secondary navigation path exposes source and rights information.

This flow assumes many users will launch the app before Mass begins and need orientation before they start navigating prayers.

### Guide Flow
`Guide` is the app's primary experience.

- The user sees one current `MassPart` at a time.
- Each section includes title, summary, tags, Latin and English text blocks, explanation notes, and gesture cues.
- Previous and next controls allow linear progression through the Mass.
- A jump sheet allows quick movement to any section.
- Bookmarking is available directly from the hero card.

This flow is optimized for live use during Mass. It favors order and calm over maximal density.

### Library Flow
`Library` is the reference mode for users who already know what they want.

- A segmented control switches between all sections and bookmarks only.
- Search runs locally against titles, summaries, tags, rubrics, Latin, English, gesture cues, and explanation text.
- Search results open the same section detail content used by the guide.

This flow supports experienced TLM attendees and repeat users who want quick lookup rather than step-by-step progression.

### Bookmark Flow
- A user bookmarks a section from the guide or a library detail screen.
- The bookmark is persisted in `UserDefaults`.
- The section becomes visible through the bookmark scope in `Library`.

### Source Visibility
- Source and rights visibility is currently lightweight.
- The app exposes source references from bundled content through a dedicated navigation path in `Intro`.
- Provenance is informative, not yet editorially rigorous.

## Current Technical Architecture
### App Shell
The app is a native SwiftUI application with a single coordinating state owner.

- Entry point: `LatinMassCompanionApp`
- Root container: `RootTabView`
- Shared state owner: `AppModel`

`LatinMassCompanionApp` creates the service graph at launch and injects a single `AppModel` into the tab shell. The current dependency graph is simple and local:

- `BundleMassContentRepository`
- `LocalMassSearchService`
- `UserDefaultsBookmarkStore`

### State Ownership
`AppModel` is the coordinating state owner for the whole app.

- Loads the bundled content library at startup
- Holds the ordered Mass parts, source references, bookmarks, and error state
- Provides derived views of all parts and bookmarked parts
- Handles bookmark toggling and section-to-section navigation
- Delegates search to the injected `SearchService`

This is intentionally lightweight MV-style coordination rather than a layered MVVM stack.

### Data Loading
The app loads its entire content bundle locally from `mass_library.json`.

- Repository protocol: `MassContentRepository`
- Concrete implementation: `BundleMassContentRepository`
- Decode target: `MassLibrary`

This keeps v1 reliable inside churches or chapels with poor connectivity and keeps content delivery simple for a first release.

### Search
Search is fully local.

- Protocol: `SearchService`
- Implementation: `LocalMassSearchService`
- Behavior: normalized lowercase token matching over each `MassPart.searchableText`

Current search is deliberately simple and predictable. It is good enough for known prayer and section lookup, but not yet fuzzy, ranked, or typo-tolerant.

### Persistence
Bookmarks are the only persisted user state today.

- Protocol: `BookmarkStore`
- Implementation: `UserDefaultsBookmarkStore`
- Stored value: set of bookmarked `MassPart.id` values

No user profile, account, or cloud sync exists.

### No-Backend Design
The current architecture assumes no backend by default.

- Content is bundled
- Search is local
- Persistence is local
- Navigation is local state only

This is both a product decision and an operational simplification.

## Important Interfaces and Types
### Content Models
- `MassLibrary`: top-level bundled content object with title, subtitle, sources, and ordered parts
- `MassPart`: a single liturgical section with structural and user-facing content
- `TextBlock`: one speaker-labeled Latin and English pair, with optional rubric
- `GestureCue`: posture or gesture guidance
- `ExplanationNote`: short explanatory content attached to a section
- `SourceReference`: provenance and rights metadata for bundled source material

### Service Interfaces
- `MassContentRepository`: loads the bundled Mass content
- `SearchService`: searches a list of `MassPart` values
- `BookmarkStore`: loads and saves bookmarked section identifiers

### Coordinating State
- `AppModel`: owns current loaded content, bookmarks, source references, search routing, and section navigation helpers
- `LibraryScope`: selects between all sections and bookmarks in the library flow

### Current Interface Boundaries
The design intentionally separates:

- content loading from UI rendering
- search behavior from `AppModel`
- persistence behavior from screen code

The app does not yet separate content authoring, provenance review, or liturgical variants into their own subsystems. Those become relevant in v2.

## Content Strategy and Rights
### Current Content Strategy
The shipped content focuses on the broad ordinary flow of the 1962 Low Mass rather than a fully complete hand missal reproduction.

- The current bundle is structured for live guidance, not exhaustive liturgical completeness.
- Each section includes summary context, text blocks, gesture cues, and explanatory notes.
- The app currently models stable flow better than it models day-specific variation.

### Rights Strategy
- v1 assumes public-domain content only.
- Source information is stored in the bundle and surfaced in the UI.
- English text is positioned as adapted from public-domain hand missal sources.

### What Is Deliberately Deferred
- Licensed missal text or proprietary translations
- Day-specific propers and feast-dependent selection
- A formal editorial workflow with revision history
- Multi-source comparison or parallel translation sets

## Adopted External Design Inputs
This project should use a small, explicit set of external references rather than loosely
borrowing from many sources.

### Adopt Now
- Apple navigation guidance:
  - Preserve the current three-tab information architecture.
  - Treat `Guide` as the task flow, `Library` as lookup/reference, and `Intro` as orientation.
- Apple accessibility guidance:
  - Treat Dynamic Type, VoiceOver labels, contrast, and touch target sizing as default
    implementation requirements, not later polish.
- Uncodixfy:
  - Use as an anti-pattern guardrail for future UI work so the app avoids generic AI-generated
    visual habits.
  - Apply it during design review, especially when creating new surfaces or refreshing the
    visual language.
- SF Symbols:
  - Continue using native Apple iconography for navigation and utility actions.
- Missale Meum:
  - Use as the primary external benchmark for future library organization, liturgical lookup,
    and side-by-side text presentation.
- Divinum Officium:
  - Use as the primary structural reference for future calendar-aware and variant-aware liturgical
    expansion.
- Public-domain historical missal scans:
  - Use as the preferred source class for future text expansion until a more formal editorial
    and provenance pipeline exists.

### Not Adopted Yet
- Apple design resource files as redistributable product assets
- Modern missal translations without explicit rights clearance
- Full calendar-driven proper selection in the product
- Any external app's visual design as a direct UI template
- Backend delivery or account-sync assumptions driven by third-party products
- Uncodixfy as a replacement for platform-native UX conventions

### Working Rule
External references may shape structure, interaction patterns, accessibility standards, and
content strategy, but they should not be treated as permission to import text, mimic visual
layouts too closely, or widen scope without an explicit product decision.

## Known Constraints and Risks
### Product Constraints
- iPhone-first only
- Low Mass only
- No backend or sync
- No calendar-driven proper handling
- No distinction yet between quiet Low Mass and sung or ceremonial variants

### UX Risks
- Users may over-assume completeness if the app looks more authoritative than the current content bundle actually is.
- Newcomers may still need stronger orientation around where silence, propers, and ceremonial variations occur.
- Search is functional but not yet forgiving for typos or alternate phrasing.

### Content Risks
- Current content authoring is JSON-based and manual.
- As content grows, editing directly in a large bundled file will become harder to review and maintain.
- Provenance metadata is present but not yet strong enough for a robust editorial process.

### Technical Risks
- `AppModel` is an appropriate coordinator today, but it will take on too much responsibility if v2 adds variants, glossary content, or richer progress features without new layers.
- The current `MassPart` model is well suited to a single ordered flow, but variant handling will pressure that structure quickly.

## Detailed V2 Spec
The next phase should expand the app without breaking the product shape that already works: Intro for orientation, Guide for live use, and Library for lookup.

### V2 Goals
- Preserve the current offline-first, no-backend posture
- Improve usability during live attendance
- Expand educational value without overwhelming newcomers
- Prepare the content model for liturgical variants and richer provenance

### 1. Support Sung and High Mass Differences
#### User-Facing Behavior
- Users can view the standard Low Mass flow and see where Sung or High Mass differs.
- Variant differences appear inline or as clearly labeled alternates, not as a separate disconnected product.
- The guide explains when a part may be sung, omitted, expanded, or ceremonially different.

#### Architecture Impact
- `MassPart` will need support for variant-specific content or annotations.
- `TextBlock` and `ExplanationNote` may need optional variant scoping.
- `AppModel` will likely need a user-selectable Mass mode or liturgical form context.

#### Must Remain Unchanged
- The main `Guide` should still read as one calm, ordered experience.
- Offline delivery remains the default.

#### Acceptance Criteria
- A user can understand where Sung/High Mass diverges without leaving the current section.
- Variant-aware content can be loaded from local bundle data.
- Existing Low Mass behavior remains intact when no variant mode is selected.

### 2. Add Glossary and FAQ Content
#### User-Facing Behavior
- Users can look up common terms such as Canon, Collect, Missal, rubrics, Epistle side, and propers.
- The app provides short FAQ-style answers for recurring newcomer questions.
- Glossary and FAQ content is reachable from `Intro` and `Library`.

#### Architecture Impact
- Add new bundled content types for glossary entries and FAQ items.
- Extend the search service to search across reference content, not just `MassPart`.
- Consider splitting Library into sections or introducing a richer reference index.

#### Must Remain Unchanged
- The core Mass guide should remain primary, not buried under educational extras.
- Search for Mass sections should stay fast and obvious.

#### Acceptance Criteria
- A newcomer can find a plain-language answer to a common liturgical term offline.
- Reference content is included in the same bundled content workflow as Mass content.
- Search returns both Mass sections and supporting educational entries in a clear, distinguishable way.

### 3. Strengthen Content Provenance and Editorial Workflow
#### User-Facing Behavior
- Source information becomes more transparent and section-specific where needed.
- Users can see which text or explanation content is adapted, public-domain, or derived from a specific missal source.

#### Architecture Impact
- `SourceReference` likely needs richer metadata.
- `ExplanationNote` and possibly `TextBlock` should support stronger citation linkage.
- Content storage should move from a single large JSON file toward a more maintainable editorial structure, such as split files by domain or section.

#### Must Remain Unchanged
- Runtime content loading should still end in a local bundled payload.
- Rights-safe content boundaries remain explicit.

#### Acceptance Criteria
- Builders can add or revise content with clearer provenance rules.
- Each shipped content unit can be traced back to a recorded source reference.
- The final runtime bundle still loads offline without any network dependency.

### 4. Improve Progression and Orientation During Mass
#### User-Facing Behavior
- The guide gives users better help in understanding where they are in the Mass.
- Possible additions include a visible progress rail, a compact section timeline, "what usually comes next" context, and optional newcomer tips for silence or posture changes.

#### Architecture Impact
- `AppModel` may need richer progress and section relationship metadata.
- `MassPart` may need optional timing or phase-group fields such as Preparation, Instruction, Offertory, Canon, Communion, and Conclusion.

#### Must Remain Unchanged
- The guide should remain usable with one hand and low cognitive load.
- The current previous/next model should continue to work as the base interaction.

#### Acceptance Criteria
- A user can tell where they are in the Mass at a glance.
- Orientation aids do not require an internet connection or live sync.
- New cues help without turning the guide into a constantly animated or distracting interface.

### 5. Expand Accessibility and Polish
#### User-Facing Behavior
- Better support for Dynamic Type, VoiceOver, contrast, and touch target clarity
- More resilient layouts for longer text blocks and content scaling
- Improved accessibility labels around bookmarks, navigation, and explanation expansion

#### Architecture Impact
- Mostly UI-layer work, but may require content-writing standards to keep explanations concise and screen-reader friendly.

#### Must Remain Unchanged
- The overall visual identity can evolve, but the app should keep its calm, reverent, readable tone.

#### Acceptance Criteria
- Core guide and library flows remain usable at larger text sizes.
- Interactive controls expose meaningful accessibility labels and states.
- Visual polish improves readability without making the app feel decorative at the expense of function.

## Acceptance Criteria
### Current App Acceptance Criteria
- The app launches into `Intro` and explains its purpose clearly.
- `Guide` presents the Mass in a stable ordered flow using bundled local content.
- `Library` supports all-sections search and bookmark-filtered lookup.
- Search works across section titles, Latin, English, rubrics, and explanation text.
- Bookmarks persist locally across launches without requiring an account.
- The app functions without network access after installation.

### Next-Phase Acceptance Criteria
- Variant handling for Sung and High Mass can be added without replacing the current guided flow model.
- Educational content can expand beyond Mass sections without collapsing the current navigation model.
- Content provenance becomes more explicit and maintainable for builders.
- Orientation aids improve live usability without increasing cognitive load.
- Accessibility improvements raise usability for a wider range of users while preserving the app's liturgical tone.

## Assumptions and Open Questions
### Assumptions
- The app should remain backend-free by default unless a future requirement makes local bundling unworkable.
- Low Mass remains the canonical baseline flow even after variant support is added.
- Educational content should remain concise and supportive rather than encyclopedic.

### Open Questions for Future Iteration
- Whether a future editorial pipeline should remain JSON-based or move to a more structured authoring format
- How far the app should go in representing day-specific propers before complexity outweighs v2 value
- Whether Sung/High Mass support should be mode-based, section-annotation-based, or both
