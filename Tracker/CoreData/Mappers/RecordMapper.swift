import Foundation

enum RecordMapper {
    static func map(_ core: TrackerRecordCoreData) -> TrackerRecord {
        TrackerRecord(
            trackerID: core.tracker?.id ?? UUID(),
            date: core.date ?? Date()
        )
    }
}
