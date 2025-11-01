import Foundation

enum WeekDay: Int, CaseIterable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var shortName: String {
        switch self {
        case .monday:    return "Пн"
        case .tuesday:   return "Вт"
        case .wednesday: return "Ср"
        case .thursday:  return "Чт"
        case .friday:    return "Пт"
        case .saturday:  return "Сб"
        case .sunday:    return "Вс"
        }
    }
    
    static func from(calendarWeekday: Int) -> WeekDay {
        let index = (calendarWeekday + 5) % 7
        return WeekDay(rawValue: index) ?? .monday
    }
}
