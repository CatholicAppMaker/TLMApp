import SwiftUI
import WidgetKit

@main
struct LatinMassCompanionWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayCelebrationWidget()
        ResumeGuideWidget()
        SavedSectionsWidget()
    }
}

private struct TodayCelebrationEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let dateKey: String?
}

private struct ActionEntry: TimelineEntry {
    let date: Date
}

private struct TodayCelebrationProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayCelebrationEntry {
        TodayCelebrationEntry(
            date: .now,
            title: "Today’s Celebration",
            subtitle: "Open the guide or calendar for the current feast.",
            dateKey: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayCelebrationEntry) -> Void) {
        completion(Self.makeEntry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayCelebrationEntry>) -> Void) {
        let entry = Self.makeEntry(for: .now)
        let nextRefresh = Calendar.current.startOfDay(for: .now).addingTimeInterval(60 * 60 * 24)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private static func makeEntry(for date: Date) -> TodayCelebrationEntry {
        let loader = WidgetCelebrationLoader()
        let celebration = loader.todayCelebration(for: date)
        return TodayCelebrationEntry(
            date: date,
            title: celebration?.title ?? "Ordinary of the Mass",
            subtitle: celebration?.subtitle ?? "Open the guide to follow the Ordinary or browse the bundled calendar.",
            dateKey: celebration?.dateKey
        )
    }
}

private struct ActionProvider: TimelineProvider {
    func placeholder(in context: Context) -> ActionEntry {
        ActionEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (ActionEntry) -> Void) {
        completion(ActionEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ActionEntry>) -> Void) {
        completion(Timeline(entries: [ActionEntry(date: .now)], policy: .never))
    }
}

private struct TodayCelebrationWidget: Widget {
    let kind = "LatinMassCompanion.TodayCelebration"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayCelebrationProvider()) { entry in
            VStack(alignment: .leading, spacing: 10) {
                Text("Today’s Celebration")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(entry.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(entry.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .containerBackground(.fill.tertiary, for: .widget)
            .widgetURL(Self.url(for: entry.dateKey))
        }
        .configurationDisplayName("Today’s Celebration")
        .description("Open the current celebration or the Ordinary directly from the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }

    private static func url(for dateKey: String?) -> URL? {
        if let dateKey {
            return URL(string: "latinmasscompanion://calendar?date=\(dateKey)")
        }

        return URL(string: "latinmasscompanion://guide")
    }
}

private struct ResumeGuideWidget: Widget {
    let kind = "LatinMassCompanion.ResumeGuide"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ActionProvider()) { _ in
            VStack(alignment: .leading, spacing: 10) {
                Label("Resume Guide", systemImage: "arrow.clockwise")
                    .font(.headline)
                Text("Return to your last saved section without hunting through the full guide.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .containerBackground(.fill.tertiary, for: .widget)
            .widgetURL(URL(string: "latinmasscompanion://guide?resume=1"))
        }
        .configurationDisplayName("Resume Guide")
        .description("Reopen the guide at your last saved Mass section.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct SavedSectionsWidget: Widget {
    let kind = "LatinMassCompanion.SavedSections"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ActionProvider()) { _ in
            VStack(alignment: .leading, spacing: 10) {
                Label("Bookmarks", systemImage: "bookmark")
                    .font(.headline)
                Text("Jump straight into your bookmarked sections when you need a quicker working library.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .containerBackground(.fill.tertiary, for: .widget)
            .widgetURL(URL(string: "latinmasscompanion://library?saved=1"))
        }
        .configurationDisplayName("Bookmarks")
        .description("Open the Library focused on bookmarked sections.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct WidgetCelebration: Decodable {
    let id: String
    let title: String
    let subtitle: String
}

private struct WidgetDateIndex: Decodable {
    let date: String
    let celebrationID: String
}

private struct WidgetCatalog: Decodable {
    let celebrations: [WidgetCelebration]
    let dateIndex: [WidgetDateIndex]
}

private struct TodayWidgetCelebration {
    let dateKey: String
    let title: String
    let subtitle: String
}

private struct WidgetCelebrationLoader {
    func todayCelebration(for date: Date) -> TodayWidgetCelebration? {
        guard
            let url = Bundle.main.url(forResource: "mass_library", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let catalog = try? JSONDecoder().decode(WidgetCatalog.self, from: data)
        else {
            return nil
        }

        let dateKey = Self.storageDateFormatter.string(from: date)
        guard
            let dateEntry = catalog.dateIndex.first(where: { $0.date == dateKey }),
            let celebration = catalog.celebrations.first(where: { $0.id == dateEntry.celebrationID })
        else {
            return nil
        }

        return TodayWidgetCelebration(
            dateKey: dateKey,
            title: celebration.title,
            subtitle: celebration.subtitle
        )
    }

    private static let storageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
