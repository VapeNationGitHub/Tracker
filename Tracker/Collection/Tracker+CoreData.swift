import UIKit
import UIColorHexSwift

extension Tracker {
    init(from core: TrackerCoreData) {
        self.id = core.id ?? UUID()
        self.name = core.name ?? ""
        self.emoji = core.emoji ?? ""
        self.color = UIColor(hex: core.colorHex ?? "#0000FF")
        self.schedule = (core.schedule as? [Int] ?? [])
            .compactMap { WeekDay(rawValue: $0) }

        if let category = core.category {
            self.category = category
        } else {
            assertionFailure("❌ core.category is nil — повреждённая запись в Core Data.")
            self.category = (try? TrackerCategoryStore.shared.defaultCategory())
                            ?? TrackerCategoryCoreData()
        }
    }
}
