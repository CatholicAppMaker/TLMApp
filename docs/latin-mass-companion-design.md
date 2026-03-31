# Latin Mass Companion Design Doc

## Overview
Latin Mass Companion is an iPhone-first, offline-first SwiftUI app that helps newcomers and regular attendees follow the `1962 Mass` with an intentionally bounded, trust-first product shape.

The app is not trying to be a complete digital missal. Its current promise is narrower and clearer:

- fully offline after install
- one bundled year of `2026` coverage
- `Sundays and major feasts` only for date-specific propers
- `Low Mass` and one combined `Sung Mass` profile
- a calm companion for live use, plus a practical learning layer before or after Mass

This document is for future builders and editors. It should stay aligned with the shipped product, not with earlier prototypes.

## Product Thesis
- Newcomers do better with a trustworthy companion than with a maximal but confusing missal clone.
- A date-aware guide is useful only if the app is honest about what it does and does not cover.
- The app should help users stay recollected, not pressure them into catching every word.
- Editorial clarity and source visibility matter as much as code quality in a liturgical product.

## Current Product Shape

### Top-level navigation
- `Today`: date, coverage status, celebration summary, Mass form, resume, and first-time guidance
- `Guide`: resolved Mass flow for the selected date and Mass form
- `Library`: local search across resolved Mass sections plus learning content
- `Learn`: newcomer orientation, Ordinary vs Propers, participation guidance, pronunciation, glossary, and chant primer

### Supported runtime behavior
- bundled `MassCatalog` loaded from local JSON
- explicit `CoverageWindow` with bundled-year boundaries
- `MassForm` support for:
  - `low`
  - `sung`
- date-aware resolution for bundled celebrations
- Ordinary fallback inside and outside the supported year window
- local bookmarks
- local Mass progress resume
- local search only

### Explicit non-goals for 1.0
- backend content delivery
- accounts or sync
- full feria / every-date coverage
- audio or chant playback
- separate `Solemn High Mass` modeling
- licensed or proprietary missal text imports

## Current Architecture

### Core runtime models
- `MassCatalog`: bundled runtime content root
- `CoverageWindow`: supported year metadata
- `MassPart`: baseline Ordinary section
- `Celebration`: bundled Sunday or feast with proper-backed section replacements
- `CelebrationSection`: proper replacement content for specific landmarks
- `ResolvedMassPart`: date- and form-aware guide section used by `Guide` and `Library`
- `QuickGuidance`: short live-use guidance distinct from deeper explanation
- `ExplanationNote`: richer liturgical or devotional explanation
- `GlossaryEntry`, `PronunciationGuide`, `ParticipationGuide`, `ChantGuide`: learning content types

### Services and state
- `BundleMassContentRepository`: loads the bundled catalog
- `LocalMassSearchService`: local normalized token search across Mass and learning content
- `UserDefaultsBookmarkStore`
- `UserDefaultsMassModeProgressStore`
- `UserDefaultsMassFormStore`
- `AppModel`: app-wide coordinator for loading, date selection, Mass form selection, search, bookmark state, and guide resume

### Content pipeline
- source content is authored in `LatinMassCompanion/Resources/CatalogSource/`
- `scripts/build_mass_catalog.py` assembles the shipped runtime catalog
- the app still loads one bundled `mass_library.json` at runtime

This keeps authoring more maintainable while preserving the offline runtime model.

## UX Principles
- Prefer `trust` over breadth.
- Prefer `orientation` over information overload.
- Prefer explicit fallbacks over guessed content.
- Prefer `landmarks` over line-by-line anxiety.
- Keep the visual language prayerful, warm, and restrained rather than generic or overly decorative.

## Editorial Principles
- Source visibility is part of product trust, not optional metadata.
- Proper-backed content should be traceable to bundled source records.
- Quick guidance should help live use without flattening the sacred character of the rite.
- Deeper explanations should be richer than generic onboarding copy but still calm and readable on a phone.
- Learning content should answer practical questions first:
  - where am I
  - what changes today
  - what varies locally
  - how do I follow calmly

## Launch Readiness Standard
The app is ready for `1.0` only when all of the following are true:

- the UI clearly states its bounded scope
- the learning layer is strong enough for first-time users
- covered celebrations feel editorially credible, not merely placeholder-like
- `Low` and `Sung` form differences are useful but not overstated
- accessibility and one-handed guide use feel reliable
- docs, launch copy, and in-app language all describe the same product
- the final readiness audit finds no major refactor need or meaningful missing tests that should block launch
