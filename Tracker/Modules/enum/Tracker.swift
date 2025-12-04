import Foundation
import UIKit

// MARK: - Tracker

struct Tracker {
    let id: UUID                   // Уникальный идентификатор
    let name: String               // Название трекера
    let color: UIColor            // Цвет трекера
    let emoji: String              // Эмодзи
    let schedule: [WeekDay]        // Расписание (дни недели)
    let category: TrackerCategoryCoreData
}
