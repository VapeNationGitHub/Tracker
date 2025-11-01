import UIKit

struct TrackerCellModel {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let isCompletedToday: Bool
    let completedDays: Int
}
