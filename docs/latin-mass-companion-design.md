# Latin Mass Companion Design Doc

## Overview
Latin Mass Companion is an offline-first SwiftUI app for iPhone and iPad that helps newcomers and regular attendees follow the `1962 Mass` with an intentionally bounded, trust-first product shape.

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
- `Guide`: the primary live-follow flow with Mass form switching, timeline guidance, resume, and landmarks
- `Calendar`: bundled-year browsing for covered Sundays and major feasts
- `Library`: local search across resolved Mass sections, bookmarks, and learning content
- `Learn`: newcomer orientation, Ordinary vs Propers, participation guidance, pronunciation, glossary, chant primer, and support settings

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

## Visual Direction

### Core visual stance
- The app should feel `reverent and memorable`, not merely tidy.
- Avoid the look of a generic “stack of rounded cards on beige.”
- The product should feel calm enough for church use, but still have enough character that each screen is recognizable at a glance.
- Restraint does not mean flatness. Use contrast, atmosphere, and hierarchy rather than decoration for its own sake.

### Shared visual system
- The shipped visual language should stay within a warm liturgical palette:
  - parchment and stone neutrals
  - burgundy as the main active accent
  - restrained gold for emphasis and ornament
  - darker “candlelit” variants in dark mode rather than plain charcoal UI
- Shared surfaces should have distinct roles:
  - `hero` surfaces for top-level orientation
  - `tool` surfaces for active workflows and controls
  - `reference` or inset surfaces for secondary supporting material
- Not every panel should carry the same weight. Stronger hierarchy is required so the app does not feel visually monotonous.

### Per-tab identity
- `Guide` should be the most operational tab.
  - Primary actions, timeline, and Mass-form controls should feel decisive and tool-like.
  - Reading content should remain calmer than controls.
- `Calendar` should be the most atmospheric browse surface.
  - It should feel like entering the liturgical year, not scanning a plain data list.
  - Selection state should be visually obvious.
- `Library` should be the cleanest and sharpest tab.
  - Search, bookmarks, and results should feel indexed and dependable.
  - The bookmarks experience should be unmistakable.
- `Learn` should be contemplative and editorial.
  - It can be warmer and slightly more reflective, but it must not collapse into a wall of identical cards.

### Imagery and ornament rules
- Use restrained, SwiftUI-native imagery only:
  - gradients
  - layered shapes
  - lines and rules
  - SF Symbols
  - simple motif compositions
- Do not rely on photos, scanned textures, saint art, or decorative wallpaper backgrounds.
- Imagery should support orientation and atmosphere, not compete with text or primary actions.
- Hero areas may carry more atmosphere than content rows, but reading surfaces must stay clean.

### Control styling
- Important actions should look intentionally important:
  - `Find My Place`
  - `Jump to Major Moments`
  - `Open Bookmarks`
  - celebration open actions
- Segmented controls, pills, and buttons should feel native but not stock.
- Touch targets, contrast, and one-handed use remain more important than ornament.

### Anti-patterns to avoid
- visually identical stacked cards across every screen
- generic glassmorphism or trendy iOS effects that do not fit the product
- over-rounding, over-shadowing, or oversized decorative motifs
- decorative elements placed inside reading content where they compete with the rite
- adding more text as a substitute for better hierarchy

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
