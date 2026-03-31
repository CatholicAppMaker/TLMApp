# External References

This document collects external references that can guide product, UX, accessibility,
content strategy, and liturgical expansion for Latin Mass Companion.

These are reference materials, not copy-paste source material. Use them to shape
structure, interaction patterns, rights decisions, and future roadmap work.

## 1. Apple Product and UX References

### Apple navigation guidance
- Apple WWDC: Explore navigation design for iOS
  - https://developer.apple.com/videos/play/wwdc2022/10001/
  - Use this to sanity-check our current four-tab structure: `Today`, `Guide`, `Library`,
    and `Learn`.
  - Especially relevant for keeping the top-level modes distinct without adding extra tabs
    or secondary navigation that confuses first-time users.

### SwiftUI tab architecture
- Apple `TabView` documentation
  - https://developer.apple.com/documentation/SwiftUI/TabView
  - Use this as the canonical reference for tab behavior and future changes to the app shell.

### Accessibility guidance
- Apple Accessibility documentation
  - https://developer.apple.com/documentation/accessibility
  - Use this as the primary accessibility reference for VoiceOver, Larger Text, reduced
    mobility, and cognitive accessibility work.

- Apple Assistive Access guidance
  - https://developer.apple.com/documentation/Accessibility/optimizing-your-app-for-assistive-access
  - Useful if we want a simplified newcomer mode or more resilient large-target layouts.

### Symbols and iconography
- SF Symbols
  - https://developer.apple.com/sf-symbols/
  - Use this to keep iconography native, legible, and consistent with Apple platforms.

### Apple design resource licensing
- Apple Design Resources License
  - https://developer.apple.com/support/downloads/terms/apple-design-resources/Apple-Design-Resources-License-20230621-English.pdf
  - Important limitation: Apple design resources are for mock-ups and Apple-platform UI work.
  - Do not treat Apple UI resource files as redistributable product assets.

### UI anti-pattern guardrail
- Uncodixfy
  - https://github.com/cyxzdev/Uncodixfy
  - A lightweight anti-pattern rule set aimed at preventing generic AI-generated UI habits.
  - Useful as a design-review guardrail when generating new screens or refreshing existing ones.
  - Most relevant for avoiding overused patterns such as floating cards everywhere, oversized
    rounding, gratuitous glassmorphism, and overly decorative labels.

## 2. Liturgical and Product References

### Divinum Officium
- https://www.divinumofficium.com/
- Good reference for:
  - classical Roman liturgical structure
  - calendar and version handling
  - how a traditional liturgy project presents variant-era material
- Helpful for future work on day-specific logic, propers, and liturgical navigation.

### Missale Meum
- https://missale.bieda.it/
- Strong product benchmark for:
  - side-by-side Latin and vernacular presentation
  - liturgical calendar UX
  - proper-of-the-day organization
  - printable companion formats
- Useful as a feature benchmark, not as something to copy visually.

### USCCB note on 1962 optional prefaces
- https://www.usccb.org/resources/1962-mass-new-optional-prefaces
- Relevant if we ever expand beyond a simpler "classic Low Mass guide" and need to think
  carefully about what "1962 Mass support" means in a modern product.

## 3. Rights-Safer Text and Historical Source Leads

### Public-domain Roman Missal example
- Wikimedia Commons entry for an 1865 Roman Missal scan
  - https://commons.wikimedia.org/wiki/File:The_Roman_Missal_(IA_TheRomanMissal1865).pdf
- Use this as a proof point that older missal material can be clearly public domain and
  suitable for historical comparison or language/reference work.

### Public-domain Fr. Lasance missal scan
- Corpus Christi Watershed: 1937 Fr. Lasance Missal
  - https://www.ccwatershed.org/2013/03/19/1937-fr-lasance-missal/
- Useful for:
  - public-domain English/Latin devotional reference
  - studying how older missals structure explanatory support
  - rights-safer baseline material than many modern 1962 missals

## 4. How We Should Use These

### Safe uses
- Use Apple references to shape navigation, accessibility, and native interaction patterns.
- Use liturgical sites to understand content organization, variant handling, and user needs.
- Use clearly public-domain scans to inform editorial structure and terminology.
- Treat the Fr. Lasance missal as the primary editorial anchor when we need stronger authority
  for explanatory copy or devotional phrasing.

### Avoid
- Copying modern missal translations into the app without checking rights.
- Reusing visual layouts from external apps too literally.
- Treating web references as authoritative source text without provenance review.

## 5. Practical Recommendations For This App

### Adopt Now
- Apple WWDC navigation guidance:
  - Treat our current four-tab shell as the durable top-level structure.
  - Keep `Today` as orientation and daily context, `Guide` as the primary live-follow flow,
    `Library` as lookup/reference, and `Learn` as the before/after-Mass teaching layer.
  - Avoid adding new top-level tabs unless a feature cannot naturally fit one of those modes.
- Apple accessibility documentation:
  - Treat Dynamic Type, VoiceOver labels, contrast, and touch target sizing as baseline
    requirements for all new UI work.
  - Include accessibility acceptance checks whenever we add a new screen or interaction.
- Uncodixfy:
  - Use as an anti-pattern checklist during UI design or redesign work.
  - Especially useful when creating new visual directions so the app does not drift into a
    generic "AI app" look.
  - Apply it as a guardrail, not as a full visual system.
- SF Symbols:
  - Keep using Apple-native iconography for navigation, bookmarking, gestures, and utility UI.
  - Avoid introducing decorative icon packs that weaken platform familiarity.
- Missale Meum:
  - Use it as the main benchmark for future liturgical-library expansion, proper handling,
    and side-by-side text organization.
  - Do not mirror its UI literally; use it to pressure-test feature completeness and content
    organization.
- Divinum Officium:
  - Use it as the main reference for future calendar-aware structure and variant handling.
  - Treat it as a structural and liturgical reference, not as a direct content import source.
- Public-domain source scans:
  - Treat public-domain scans as the preferred baseline for future source expansion until we
    establish a stronger editorial and provenance workflow.
  - Record provenance before importing or adapting any new text.
  - Prefer Fr. Lasance first, then other public-domain hand missal or chant references as
    supporting material.

### Do Not Adopt Yet
- Apple design resource files as shipped product assets
- Modern missal translations without explicit rights review
- Full calendar-driven proper selection
- Multiple visual modes or a more complex top-level navigation model
- Backend content delivery or account-based sync
- Uncodixfy as a hard visual identity replacement for platform conventions

### Near term
- Use Apple navigation and accessibility docs to refine our current `Today`, `Guide`,
  `Library`, and `Learn` flows.
- Use Uncodixfy as a quick review checklist when redesigning cards, navigation chrome, or
  future educational/reference surfaces.
- Use Missale Meum as a roadmap reference for:
  - better proper handling
  - richer library organization
  - printable or exportable companion content later

### Content and rights
- Keep shipping only clearly public-domain or explicitly authorized content.
- If we want more complete 1962 text coverage, create a source audit before importing any
  new translation material.
- Prefer a provenance-first content pipeline before expanding the bundled corpus.

### V2 planning
- Use Divinum Officium and Missale Meum as reference points for handling:
  - liturgical-calendar-driven content
  - Low Mass vs Sung/High Mass differences beyond the current two-profile approach
  - deeper educational/reference layers without losing the guided core experience
