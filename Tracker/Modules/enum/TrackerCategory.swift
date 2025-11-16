struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    init(from core: TrackerCategoryCoreData, trackers: [Tracker]) {
        self.title = core.title ?? ""
        self.trackers = trackers
    }
}
