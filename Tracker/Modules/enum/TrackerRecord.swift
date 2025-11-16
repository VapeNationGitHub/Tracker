import Foundation

struct TrackerRecord {
    let trackerID: UUID
    let date: Date
}

extension TrackerRecord {
    init?(from core: TrackerRecordCoreData) {
        guard
            let id = core.tracker?.id,
            let date = core.date
        else { return nil }

        self.trackerID = id
        self.date = date
    }
}
