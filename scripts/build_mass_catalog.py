#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path


SEASON_COPY = {
    "advent": {
        "collect_latin": "Excita, quaesumus, Domine, potentiam tuam, et veni.",
        "collect_english": "Stir up Thy power, we beseech Thee, O Lord, and come.",
        "reading_theme": "The Church waits in vigilance and asks for a heart ready to receive the coming Lord.",
        "gradual_latin": "Veni, Domine, et noli tardare.",
        "gradual_english": "Come, O Lord, and do not delay.",
        "communion_latin": "Dominus dabit benignitatem, et terra nostra dabit fructum suum.",
        "communion_english": "The Lord will give goodness, and our earth shall yield her fruit.",
    },
    "christmas": {
        "collect_latin": "Deus, qui hodierna die Unigenitum tuum gentibus stella duce revelasti.",
        "collect_english": "O God, who on this day hast revealed Thy Only-begotten Son to the nations.",
        "reading_theme": "The liturgy keeps the faithful close to the mystery of the Word made flesh and the manifestation of Christ.",
        "gradual_latin": "Tecum principium in die virtutis tuae.",
        "gradual_english": "With Thee is the principality in the day of Thy strength.",
        "communion_latin": "Vidimus stellam eius in Oriente, et venimus cum muneribus adorare Dominum.",
        "communion_english": "We have seen His star in the East, and have come with gifts to adore the Lord.",
    },
    "lent": {
        "collect_latin": "Concede nobis, quaesumus, omnipotens Deus, ut per annua quadragesimalis exercitia sacramenti.",
        "collect_english": "Grant us, we beseech Thee, almighty God, through the yearly exercises of this sacred season.",
        "reading_theme": "The proper texts press the faithful toward repentance, steadiness, and deeper union with Christ’s Passion.",
        "gradual_latin": "Tribulationes cordis mei dilatatae sunt; de necessitatibus meis erue me, Domine.",
        "gradual_english": "The troubles of my heart are enlarged; deliver me, O Lord, from my necessities.",
        "communion_latin": "Qui meditabitur in lege Domini die ac nocte, dabit fructum suum in tempore suo.",
        "communion_english": "He that shall meditate on the law of the Lord day and night shall yield his fruit in due season.",
    },
    "easter": {
        "collect_latin": "Deus, qui hodierna die per Unigenitum tuum aeternitatis nobis aditum devicta morte reserasti.",
        "collect_english": "O God, who on this day by Thy Only-begotten Son hast conquered death and opened to us the gate of eternity.",
        "reading_theme": "The Paschal cycle teaches resurrection joy, confidence in grace, and the life of the Church after Easter.",
        "gradual_latin": "Haec dies quam fecit Dominus; exsultemus et laetemur in ea.",
        "gradual_english": "This is the day which the Lord hath made; let us rejoice and be glad in it.",
        "communion_latin": "Pascha nostrum immolatus est Christus, alleluia.",
        "communion_english": "Christ our Pasch is sacrificed, alleluia.",
    },
    "post-pentecost": {
        "collect_latin": "Praesta, quaesumus, omnipotens et misericors Deus, ut quae tibi placita sunt et te inspirante cogitemus.",
        "collect_english": "Grant, we beseech Thee, almighty and merciful God, that we may think those things that please Thee.",
        "reading_theme": "The long green season teaches perseverance, ordered charity, gratitude, and readiness for the Lord’s return.",
        "gradual_latin": "Bonum est confiteri Domino, et psallere nomini tuo, Altissime.",
        "gradual_english": "It is good to give praise to the Lord, and to sing to Thy name, O Most High.",
        "communion_latin": "Panem de caelo dedisti nobis, Domine, habentem omne delectamentum.",
        "communion_english": "Thou hast given us bread from heaven, O Lord, having in it all delight.",
    },
}


def load_json(path: Path):
    return json.loads(path.read_text())


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
                "body": f"{entry['summary']} This section carries the most visible day-specific shift in the app's live guide.",
                "sourceID": "translation",
            }
        ],
        "liveNote": "Proper texts usually become most obvious here. If you are following live, this is a reliable place to rejoin the day’s celebration.",
        "searchAliases": entry.get("searchAliases", []),
        "sourceIDs": ["calendar-1962", season_source],
        "glossaryIDs": ["collect"],
        "pronunciationIDs": ["et-cum-spiritu-tuo"],
    }


def make_communion_section(entry: dict, season_source: str) -> dict:
    season = SEASON_COPY[entry["season"]]
    tags = ["proper", entry["season"], entry["kind"], "communion"]

    return {
        "id": f"{entry['id']}-communion",
        "replacesPartID": "communion",
        "title": f"{entry['title']} Communion Proper",
        "summary": f"Representative Communion texts for {entry['title'].lower()} keep the user aligned with the day’s focus during the Communion rite.",
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
        "glossaryIDs": ["agnus-dei"],
        "pronunciationIDs": ["domine-non-sum-dignus"],
    }


def assemble_catalog(source_dir: Path) -> dict:
    base = load_json(source_dir / "base.json")
    sources = load_json(source_dir / "sources.json")
    ordinary_parts = load_json(source_dir / "ordinary_parts.json")
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
                make_collect_section(entry, season_source),
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
