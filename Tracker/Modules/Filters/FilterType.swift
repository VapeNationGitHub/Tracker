import Foundation

enum FilterType {
    case all, today, completed, uncompleted
}

extension FilterType {
    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("filter_all", comment: "Все трекеры")
        case .today:
            return NSLocalizedString("filter_today", comment: "Трекеры на сегодня")
        case .completed:
            return NSLocalizedString("filter_completed", comment: "Завершённые")
        case .uncompleted:
            return NSLocalizedString("filter_uncompleted", comment: "Не завершённые")
        }
    }
}
