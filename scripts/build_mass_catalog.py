#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path


SEASON_COPY = {
    "advent": {
        "introit_latin": "Ad te levavi animam meam: Deus meus, in te confido, non erubescam.",
        "introit_english": "Unto Thee have I lifted up my soul: O my God, in Thee I put my trust, let me not be ashamed.",
        "collect_latin": "Excita, quaesumus, Domine, potentiam tuam, et veni.",
        "collect_english": "Stir up Thy power, we beseech Thee, O Lord, and come.",
        "reading_theme": "The Church waits in vigilance and asks for a heart ready to receive the coming Lord.",
        "gradual_latin": "Veni, Domine, et noli tardare.",
        "gradual_english": "Come, O Lord, and do not delay.",
        "offertory_latin": "Ad te, Domine, levavi animam meam: Deus meus, in te confido, non erubescam.",
        "offertory_english": "Unto Thee, O Lord, have I lifted up my soul: O my God, in Thee I trust, let me not be ashamed.",
        "communion_latin": "Dominus dabit benignitatem, et terra nostra dabit fructum suum.",
        "communion_english": "The Lord will give goodness, and our earth shall yield her fruit.",
    },
    "christmas": {
        "introit_latin": "Puer natus est nobis, et Filius datus est nobis.",
        "introit_english": "A Child is born to us, and a Son is given to us.",
        "collect_latin": "Deus, qui hodierna die Unigenitum tuum gentibus stella duce revelasti.",
        "collect_english": "O God, who on this day hast revealed Thy Only-begotten Son to the nations.",
        "reading_theme": "The liturgy keeps the faithful close to the mystery of the Word made flesh and the manifestation of Christ.",
        "gradual_latin": "Tecum principium in die virtutis tuae.",
        "gradual_english": "With Thee is the principality in the day of Thy strength.",
        "offertory_latin": "Tui sunt caeli, et tua est terra: orbem terrarum et plenitudinem eius tu fundasti.",
        "offertory_english": "Thine are the heavens, and thine is the earth: the world and the fulness thereof Thou hast founded.",
        "communion_latin": "Vidimus stellam eius in Oriente, et venimus cum muneribus adorare Dominum.",
        "communion_english": "We have seen His star in the East, and have come with gifts to adore the Lord.",
    },
    "lent": {
        "introit_latin": "Invocabit me, et ego exaudiam eum: eripiam eum et glorificabo eum.",
        "introit_english": "He shall cry to Me, and I will hear him: I will rescue him and glorify him.",
        "collect_latin": "Concede nobis, quaesumus, omnipotens Deus, ut per annua quadragesimalis exercitia sacramenti.",
        "collect_english": "Grant us, we beseech Thee, almighty God, through the yearly exercises of this sacred season.",
        "reading_theme": "The proper texts press the faithful toward repentance, steadiness, and deeper union with Christ's Passion.",
        "gradual_latin": "Tribulationes cordis mei dilatatae sunt; de necessitatibus meis erue me, Domine.",
        "gradual_english": "The troubles of my heart are enlarged; deliver me, O Lord, from my necessities.",
        "offertory_latin": "Meditabor in mandatis tuis, quae dilexi valde: et levabo manus meas ad mandata tua.",
        "offertory_english": "I will meditate on Thy commandments, which I have loved exceedingly: and I will lift up my hands to Thy commandments.",
        "communion_latin": "Qui meditabitur in lege Domini die ac nocte, dabit fructum suum in tempore suo.",
        "communion_english": "He that shall meditate on the law of the Lord day and night shall yield his fruit in due season.",
    },
    "easter": {
        "introit_latin": "Resurrexi, et adhuc tecum sum, alleluia.",
        "introit_english": "I arose, and am still with Thee, alleluia.",
        "collect_latin": "Deus, qui hodierna die per Unigenitum tuum aeternitatis nobis aditum devicta morte reserasti.",
        "collect_english": "O God, who on this day by Thy Only-begotten Son hast conquered death and opened to us the gate of eternity.",
        "reading_theme": "The Paschal cycle teaches resurrection joy, confidence in grace, and the life of the Church after Easter.",
        "gradual_latin": "Haec dies quam fecit Dominus; exsultemus et laetemur in ea.",
        "gradual_english": "This is the day which the Lord hath made; let us rejoice and be glad in it.",
        "offertory_latin": "Terra tremuit et quievit, dum resurgeret in iudicium Deus, alleluia.",
        "offertory_english": "The earth trembled and was still when God arose in judgment, alleluia.",
        "communion_latin": "Pascha nostrum immolatus est Christus, alleluia.",
        "communion_english": "Christ our Pasch is sacrificed, alleluia.",
    },
    "post-pentecost": {
        "introit_latin": "Benedicta sit sancta Trinitas atque indivisa Unitas: confitebimur ei, quia fecit nobiscum misericordiam suam.",
        "introit_english": "Blessed be the Holy Trinity and undivided Unity: we will praise Him because He has shown us His mercy.",
        "collect_latin": "Praesta, quaesumus, omnipotens et misericors Deus, ut quae tibi placita sunt et te inspirante cogitemus.",
        "collect_english": "Grant, we beseech Thee, almighty and merciful God, that we may think those things that please Thee.",
        "reading_theme": "The long green season teaches perseverance, ordered charity, gratitude, and readiness for the Lord's return.",
        "gradual_latin": "Bonum est confiteri Domino, et psallere nomini tuo, Altissime.",
        "gradual_english": "It is good to give praise to the Lord, and to sing to Thy name, O Most High.",
        "offertory_latin": "Benedictus sit Deus Pater, unigenitusque Dei Filius, sanctus quoque Spiritus.",
        "offertory_english": "Blessed be God the Father, and the Only-begotten Son of God, and the Holy Ghost.",
        "communion_latin": "Panem de caelo dedisti nobis, Domine, habentem omne delectamentum.",
        "communion_english": "Thou hast given us bread from heaven, O Lord, having in it all delight.",
    },
}

ORDINARY_FORM_PROFILES = {
    "prayers-foot-altar": [
        {
            "massForm": "low",
            "participationNote": "At a Low Mass, the opening can feel very quiet. Use the posture of the faithful and the overall movement toward the altar to settle your attention.",
            "sourceIDs": ["translation"],
        },
        {
            "massForm": "sung",
            "summary": "Mass begins with a more ceremonial pace. Let the ministers, chant, and gathering movement establish the beginning before trying to match every line.",
            "liveNote": "If this is a Sung Mass, the opening may take longer and feel more processional than conversational.",
            "participationNote": "You can participate fruitfully here by watching the altar and letting the ceremonial pace teach you the start of the rite.",
            "gestureCues": [
                {
                    "id": "sung-opening-watch-altar",
                    "label": "Let the ceremonial pace settle in",
                    "detail": "At a Sung Mass, the opening is often more extended before the priest reaches the center of the altar.",
                    "systemImage": "music.note",
                }
            ],
            "sourceIDs": ["translation", "chant"],
            "chantGuideIDs": ["chant-how-to-listen"],
        },
    ],
    "kyrie-gloria": [
        {
            "massForm": "low",
            "participationNote": "At a Low Mass, these prayers often move quickly. Hold onto the shift from penitence to praise rather than worrying about the exact pacing.",
            "sourceIDs": ["translation"],
        },
        {
            "massForm": "sung",
            "summary": "In a Sung Mass, the Kyrie and Gloria often become major audible landmarks that slow the pace and make the liturgy easier to follow by ear.",
            "liveNote": "Listen for the schola or choir here. These are some of the clearest sung Ordinary landmarks in the whole Mass.",
            "participationNote": "If you are new to Sung Mass, let the chant guide you more than the page. You can rejoin at the next stable heading without anxiety.",
            "gestureCues": [
                {
                    "id": "sung-kyrie-listen",
                    "label": "Listen for the sung Ordinary",
                    "detail": "The Kyrie and Gloria are often among the easiest parts of a Sung Mass to recognize by ear.",
                    "systemImage": "music.quarternote.3",
                }
            ],
            "sourceIDs": ["translation", "chant"],
            "chantGuideIDs": ["chant-where-to-listen", "chant-how-to-listen"],
        },
    ],
    "collect-readings": [
        {
            "massForm": "low",
            "participationNote": "This is one of the clearest places where the day changes. If you are trying to reconnect after arriving late, start here.",
            "sourceIDs": ["translation"],
        },
        {
            "massForm": "sung",
            "liveNote": "At a Sung Mass, the Gradual or Alleluia may carry the transition into the Gospel more audibly than in a Low Mass.",
            "participationNote": "Use the Collect and the chant between the readings as a way to confirm the feast of the day and your place in the liturgy.",
            "sourceIDs": ["translation", "chant"],
            "chantGuideIDs": ["chant-where-to-listen"],
        },
    ],
    "offertory": [
        {
            "massForm": "low",
            "participationNote": "The Offertory is a helpful place to offer your own intentions quietly with the sacrifice being prepared.",
            "sourceIDs": ["translation"],
        },
        {
            "massForm": "sung",
            "summary": "In a Sung Mass, the Offertory often opens up with chant and more visible ceremonial action, which can make the offering phase easier to notice.",
            "liveNote": "Watch the altar and listen for the offertory chant. This is a stable landmark before the Canon begins.",
            "participationNote": "At a Sung Mass, let the offertory chant and ceremonial action slow you down rather than trying to force a fast page-by-page pace.",
            "sourceIDs": ["translation", "chant"],
            "chantGuideIDs": ["chant-where-to-listen", "chant-how-to-listen"],
        },
    ],
    "preface-sanctus": [
        {
            "massForm": "low",
            "participationNote": "This is the last public threshold before the Canon. Let the Sanctus help you prepare for the silence of the Eucharistic prayer.",
            "sourceIDs": ["translation"],
        },
        {
            "massForm": "sung",
            "summary": "At a Sung Mass, the Preface and Sanctus can become one of the clearest transitions into the Canon, carried by chant and a more solemn tempo.",
            "liveNote": "The sung Sanctus is often your last major sung landmark before the stillness of the Canon.",
            "participationNote": "If you lose your place, the Sanctus is one of the safest points to rejoin before the Canon deepens into silence.",
            "sourceIDs": ["translation", "chant"],
            "chantGuideIDs": ["chant-where-to-listen", "chant-how-to-listen"],
        },
    ],
    "pater-agnus": [
        {
            "massForm": "sung",
            "liveNote": "At a Sung Mass, the Agnus Dei often returns as a clear chant landmark after the silence of the Canon.",
            "participationNote": "This is a strong re-entry point after the Canon because the sung Agnus Dei is easier to recognize than many quieter prayers.",
            "sourceIDs": ["translation", "chant"],
            "chantGuideIDs": ["chant-where-to-listen"],
        }
    ],
    "communion": [
        {
            "massForm": "low",
            "participationNote": "Communion is a calm place to rejoin the guide if you have lost your place earlier in Mass.",
            "sourceIDs": ["translation"],
        },
        {
            "massForm": "sung",
            "summary": "At a Sung Mass, the Communion chant can help you rejoin the rite gently without rushing through the page.",
            "liveNote": "Listen for the Communion chant here. It often tells you where the liturgy has arrived even before you find the line.",
            "participationNote": "If you are following a Sung Mass, let the Communion chant and the movement of the faithful orient you first.",
            "sourceIDs": ["translation", "chant"],
            "chantGuideIDs": ["chant-where-to-listen", "chant-how-to-listen"],
        },
    ],
}


def load_json(path: Path):
    return json.loads(path.read_text())


def make_form_profiles(
    *,
    low_note: str,
    sung_note: str,
    sung_live_note: str,
    chant_guide_ids: list[str],
) -> list[dict]:
    return [
        {
            "massForm": "low",
            "participationNote": low_note,
            "sourceIDs": ["translation"],
        },
        {
            "massForm": "sung",
            "liveNote": sung_live_note,
            "participationNote": sung_note,
            "sourceIDs": ["translation", "chant"],
            "chantGuideIDs": chant_guide_ids,
        },
    ]


def make_entrance_section(entry: dict, season_source: str) -> dict:
    season = SEASON_COPY[entry["season"]]
    tags = ["proper", entry["season"], entry["kind"], "introit", "entrance"]

    return {
        "id": f"{entry['id']}-entrance",
        "replacesPartID": "kyrie-gloria",
        "title": f"{entry['title']} Entrance Proper, Kyrie, and Gloria",
        "summary": f"The entrance proper for {entry['title'].lower()} establishes the character of the day before the liturgy moves into the sung or spoken Ordinary.",
        "tags": tags,
        "gestureCues": [
            {
                "id": f"{entry['id']}-entrance-cue",
                "label": "Notice the day's opening character",
                "detail": "The entrance proper is one of the clearest early signals that this day has its own liturgical accent.",
                "systemImage": "sparkles",
            }
        ],
        "textBlocks": [
            {
                "id": f"{entry['id']}-introit",
                "speaker": "Choir",
                "latin": season["introit_latin"],
                "english": season["introit_english"],
                "rubric": "Entrance proper / Introit",
            },
            {
                "id": f"{entry['id']}-kyrie-link",
                "speaker": "Guide",
                "latin": entry["title"],
                "english": "The entrance proper frames the day before the Kyrie and Gloria move the Mass from penitence into praise.",
                "rubric": "How this day changes the opening",
            },
        ],
        "explanationNotes": [
            {
                "id": f"{entry['id']}-entrance-note",
                "title": "Why the opening proper matters",
                "body": "The Introit is one of the first places where the day announces itself. Even when you do not know every word, it helps fix the feast or season in your mind before the liturgy continues.",
                "sourceID": "translation",
            }
        ],
        "liveNote": "The day-specific character is already visible here. This is an early place to confirm that you are on the right feast or Sunday.",
        "searchAliases": entry.get("searchAliases", []) + ["introit", "entrance proper"],
        "sourceIDs": ["calendar-1962", season_source],
        "glossaryIDs": ["propers", "ordinary"],
        "pronunciationIDs": [],
        "formProfiles": make_form_profiles(
            low_note="At a Low Mass, the opening proper is often easier to notice by its position in the rite than by constant page-tracking. Let it set the day's tone without anxiety.",
            sung_note="At a Sung Mass, the entrance proper can be one of the easiest places to orient yourself by ear. Let the chant establish the day before you chase the text.",
            sung_live_note="At a Sung Mass, the entrance proper often carries the opening of the liturgy more than the page does.",
            chant_guide_ids=["chant-what-is-it", "chant-where-to-listen"],
        ),
    }


def make_collect_section(entry: dict, season_source: str) -> dict:
    season = SEASON_COPY[entry["season"]]
    tags = ["proper", entry["season"], entry["kind"], "readings"]

    return {
        "id": f"{entry['id']}-collect",
        "replacesPartID": "collect-readings",
        "title": f"{entry['title']} Collect, Epistle, and Gradual",
        "summary": entry["summary"],
        "tags": tags,
        "gestureCues": [
            {
                "id": f"{entry['id']}-collect-cue",
                "label": "Listen for the day's proper texts",
                "detail": "The collect and readings are one of the clearest places where the celebration changes.",
                "systemImage": "ear",
            }
        ],
        "textBlocks": [
            {
                "id": f"{entry['id']}-collect-prayer",
                "speaker": "Priest",
                "latin": season["collect_latin"],
                "english": season["collect_english"],
                "rubric": "Proper Collect",
            },
            {
                "id": f"{entry['id']}-epistle-theme",
                "speaker": "Epistle Theme",
                "latin": entry["title"],
                "english": season["reading_theme"],
                "rubric": "Reading focus",
            },
            {
                "id": f"{entry['id']}-gradual",
                "speaker": "Choir",
                "latin": season["gradual_latin"],
                "english": season["gradual_english"],
                "rubric": "Gradual / Alleluia",
            },
        ],
        "explanationNotes": [
            {
                "id": f"{entry['id']}-collect-note",
                "title": "How this day changes the guide",
                "body": f"{entry['summary']} This section carries one of the most visible day-specific shifts in the app's live guide.",
                "sourceID": "translation",
            }
        ],
        "liveNote": "Proper texts usually become most obvious here. If you are following live, this is a reliable place to rejoin the day's celebration.",
        "searchAliases": entry.get("searchAliases", []),
        "sourceIDs": ["calendar-1962", season_source],
        "glossaryIDs": ["collect", "propers"],
        "pronunciationIDs": ["et-cum-spiritu-tuo"],
        "formProfiles": make_form_profiles(
            low_note="This is one of the safest places to reconnect with the day if you are new or if you arrived after Mass began.",
            sung_note="At a Sung Mass, the chant around the readings often helps you confirm both the feast and your place in the guide.",
            sung_live_note="In a Sung Mass, the Gradual or Alleluia may carry the transition into the Gospel more audibly than at a Low Mass.",
            chant_guide_ids=["chant-where-to-listen"],
        ),
    }


def make_offertory_section(entry: dict, season_source: str) -> dict:
    season = SEASON_COPY[entry["season"]]
    tags = ["proper", entry["season"], entry["kind"], "offertory"]

    return {
        "id": f"{entry['id']}-offertory",
        "replacesPartID": "offertory",
        "title": f"{entry['title']} Offertory Proper",
        "summary": f"The offertory proper for {entry['title'].lower()} turns the day's focus toward sacrifice and offering before the Canon begins.",
        "tags": tags,
        "gestureCues": [
            {
                "id": f"{entry['id']}-offertory-cue",
                "label": "Offer the day with the sacrifice",
                "detail": "The Offertory is a strong place to unite your own petitions with the offering being prepared on the altar.",
                "systemImage": "hands.sparkles",
            }
        ],
        "textBlocks": [
            {
                "id": f"{entry['id']}-offertory-antiphon",
                "speaker": "Choir",
                "latin": season["offertory_latin"],
                "english": season["offertory_english"],
                "rubric": "Offertory proper",
            },
            {
                "id": f"{entry['id']}-offertory-guide",
                "speaker": "Guide",
                "latin": entry["title"],
                "english": f"The offertory for this celebration deepens the day's emphasis: {entry['summary'].lower()}",
                "rubric": "Day-specific emphasis",
            },
        ],
        "explanationNotes": [
            {
                "id": f"{entry['id']}-offertory-note",
                "title": "Why the offertory proper helps orient you",
                "body": "The Offertory gives the faithful another dependable landmark between the readings and the Canon, especially on stronger feasts and Sundays.",
                "sourceID": "translation",
            }
        ],
        "liveNote": "This proper-backed Offertory is a stable place to recover your bearings before the Canon begins.",
        "searchAliases": entry.get("searchAliases", []) + ["offertory proper"],
        "sourceIDs": ["calendar-1962", season_source],
        "glossaryIDs": ["propers"],
        "pronunciationIDs": [],
        "formProfiles": make_form_profiles(
            low_note="At a Low Mass, use the Offertory to offer your own intentions quietly and to prepare for the more hidden prayers that follow.",
            sung_note="At a Sung Mass, the offertory chant and ceremonial movement often make this transition easier to notice than at a Low Mass.",
            sung_live_note="At a Sung Mass, the offertory chant is one of the clearest landmarks before the Canon.",
            chant_guide_ids=["chant-where-to-listen", "chant-how-to-listen"],
        ),
    }


def make_communion_section(entry: dict, season_source: str) -> dict:
    season = SEASON_COPY[entry["season"]]
    tags = ["proper", entry["season"], entry["kind"], "communion"]

    return {
        "id": f"{entry['id']}-communion",
        "replacesPartID": "communion",
        "title": f"{entry['title']} Communion Proper",
        "summary": f"Representative Communion texts for {entry['title'].lower()} keep the user aligned with the day's focus during the Communion rite.",
        "tags": tags,
        "gestureCues": [
            {
                "id": f"{entry['id']}-communion-cue",
                "label": "Return here as Communion begins",
                "detail": "If you lose your place, the Communion rite is another dependable point to regain your bearings.",
                "systemImage": "hands.and.sparkles",
            }
        ],
        "textBlocks": [
            {
                "id": f"{entry['id']}-communion-antiphon",
                "speaker": "Choir",
                "latin": season["communion_latin"],
                "english": season["communion_english"],
                "rubric": "Communion antiphon",
            },
            {
                "id": f"{entry['id']}-communion-prayer",
                "speaker": "Guide",
                "latin": entry["title"],
                "english": f"This Communion proper keeps the faithful attentive to {entry['summary'].lower()}",
                "rubric": "Day-specific meditation",
            },
        ],
        "explanationNotes": [
            {
                "id": f"{entry['id']}-communion-note",
                "title": "Why the app marks Communion separately",
                "body": "A second proper-backed section gives the user another obvious liturgical landmark after the Canon, especially on feast days and strong seasonal Sundays.",
                "sourceID": "translation",
            }
        ],
        "liveNote": "Communion is one of the calmest ways to regain your place in the app without rushing ahead of the liturgy.",
        "searchAliases": entry.get("searchAliases", []),
        "sourceIDs": ["calendar-1962", season_source],
        "glossaryIDs": ["agnus-dei", "propers"],
        "pronunciationIDs": ["domine-non-sum-dignus"],
        "formProfiles": make_form_profiles(
            low_note="If you are not receiving Communion, this is still a fitting place to remain recollected and make a spiritual communion.",
            sung_note="At a Sung Mass, the Communion chant can help you rejoin the rite gently even if the earlier pacing felt unfamiliar.",
            sung_live_note="The Communion chant often becomes a clear landmark in a Sung Mass, even when you are not tracking every line in real time.",
            chant_guide_ids=["chant-where-to-listen", "chant-how-to-listen"],
        ),
    }


def attach_ordinary_profiles(parts: list[dict]) -> list[dict]:
    enriched = []
    for part in parts:
        enriched_part = dict(part)
        profiles = ORDINARY_FORM_PROFILES.get(part["id"])
        if profiles:
            enriched_part["formProfiles"] = profiles
        enriched.append(enriched_part)
    return enriched


def assemble_catalog(source_dir: Path) -> dict:
    base = load_json(source_dir / "base.json")
    sources = load_json(source_dir / "sources.json")
    ordinary_parts = attach_ordinary_profiles(load_json(source_dir / "ordinary_parts.json"))
    learning = load_json(source_dir / "learning.json")
    calendar_source = load_json(source_dir / "calendar_2026.json")

    season_sources = {
        "advent": "proper-advent",
        "christmas": "proper-christmas",
        "lent": "proper-lent",
        "easter": "proper-easter",
        "post-pentecost": "proper-post-pentecost",
    }

    celebrations = []
    date_index = []
    for entry in calendar_source["entries"]:
        season_source = season_sources[entry["season"]]
        celebration = {
            "id": entry["id"],
            "title": entry["title"],
            "subtitle": entry["subtitle"],
            "summary": entry["summary"],
            "rank": entry["rank"],
            "sourceIDs": ["calendar-1962", season_source],
            "properSections": [
                make_entrance_section(entry, season_source),
                make_collect_section(entry, season_source),
                make_offertory_section(entry, season_source),
                make_communion_section(entry, season_source),
            ],
        }
        celebrations.append(celebration)
        date_index.append(
            {
                "date": entry["date"],
                "celebrationID": entry["id"],
            }
        )

    return {
        "title": base["title"],
        "subtitle": base["subtitle"],
        "coverageWindow": base["coverageWindow"],
        "sources": sources,
        "parts": ordinary_parts,
        "celebrations": celebrations,
        "dateIndex": date_index,
        "glossaryEntries": learning["glossaryEntries"],
        "pronunciationGuides": learning["pronunciationGuides"],
        "participationGuides": learning["participationGuides"],
        "chantGuides": learning["chantGuides"],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source-dir",
        default="LatinMassCompanion/Resources/CatalogSource",
    )
    parser.add_argument(
        "--output",
        default="LatinMassCompanion/Resources/mass_library.json",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    source_dir = (repo_root / args.source_dir).resolve()
    output_path = (repo_root / args.output).resolve()

    catalog = assemble_catalog(source_dir)
    output_path.write_text(json.dumps(catalog, indent=2) + "\n")
    print(f"Wrote {output_path}")


if __name__ == "__main__":
    main()
