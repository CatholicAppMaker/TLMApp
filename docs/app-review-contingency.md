# Latin Mass Companion App Review Contingency

## Summary
Use this playbook only if Apple rejects the app again under `Guideline 4.2 - Design - Minimum Functionality`.

The goal is to avoid random feature churn. Another denial should trigger:
- `clarify and escalate first`
- `one last targeted product pass only if Apple gives concrete direction`
- `distribution fallback planning` if escalation fails

Do not respond to a second denial by adding decorative content, more quotes, a history tab, or vague “more stuff” features.

## Immediate Response After A Second Denial
Reply in App Review and ask for specific examples of what Apple believes is missing.

Use this message as the base response:

> Thank you for the review. Latin Mass Companion is an offline attendance companion for the 1962 Mass, not a general reading app. The current version includes a guided Mass flow, a bundled celebration browser for 2026 Sundays and major feasts, Low Mass and Sung Mass switching, find-my-place and timeline navigation, search, bookmarks, resume behavior, widgets, and an iPad-specific workflow. Bookmarked sections are located in the Library tab under the visible Bookmarks mode. If the app is still being evaluated under Guideline 4.2, we would appreciate specific examples of the functionality or content you believe is insufficient so we can address the concern directly rather than guess at the issue.

If the follow-up reply is still generic:
- request a call or deeper clarification through App Review
- keep the tone factual and calm
- do not speculate about bias or reviewer misunderstanding

## Escalation Rule
Escalate if Apple does not provide a concrete complaint after the follow-up reply.

Use these rules:
- if Apple identifies a concrete missing behavior, address that behavior
- if Apple stays vague, file an `App Review Board` appeal
- do not keep resubmitting cosmetic changes without a new argument

Appeal framing:
- the app is a purpose-built offline attendance tool
- the app now offers multiple functional surfaces rather than a static text corpus
- the app includes celebration browsing, guided navigation, resume, bookmarks, search, widgets, and iPad workflow
- the niche audience does not make the tool non-functional

## One Last Product Pass Only If Apple Gives Specific Direction
Only do one more product pass if Apple gives a concrete hint that the app still feels too narrow.

Best options:
- expand visible corpus breadth so the bundled year feels more substantial
- make saved/recent behavior more prominent on first launch
- strengthen the calendar landing experience so it is even more obviously operational
- make widgets state-aware with shared App Group data instead of launcher-style shortcuts

Do not do these:
- no new history tab
- no more quote-heavy sections
- no decorative filler meant only to look richer
- no broad product rewrite unless Apple clearly points to a mismatch in purpose

## Distribution Fallback If Escalation Fails
If a second denial plus appeal still fails, treat the problem as `distribution fit`, not app quality.

Fallback options:
- continue private rollout through `TestFlight`
- ship a `web/PWA` version of the companion
- distribute it as a direct web tool or private ministry tool
- consider broadening the product later into a larger Catholic liturgy app if App Store fit becomes a strategic requirement

## Decision Defaults
- another denial does not mean the app is bad
- another denial most likely means Apple still sees the app as too niche or too content-shaped for standalone placement
- the next move after a second denial should be `appeal first`
- if escalation fails, prefer `TestFlight / web distribution` over endless pre-submit churn
