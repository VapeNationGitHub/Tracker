import UIKit

extension Tracker {
    init(from core: TrackerCoreData) {
        self.id = core.id ?? UUID()
        self.name = core.name ?? ""
        self.emoji = core.emoji ?? ""
        self.color = UIColor(hex: core.colorHex ?? "#0000FF")
        self.schedule = (core.schedule as? [Int] ?? [])
            .compactMap { WeekDay(rawValue: $0) }
    }
}
