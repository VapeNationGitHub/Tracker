import Foundation

enum CategoryMapper {
    static func map(_ core: TrackerCategoryCoreData) -> TrackerCategory {
        let trackers = (core.trackers?.allObjects as? [TrackerCoreData] ?? [])
            .map { Tracker(from: $0) }

        return TrackerCategory(
            title: core.title ?? "",
            trackers: trackers
        )
    }
}
