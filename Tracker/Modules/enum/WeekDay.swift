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
    
    /// `calendarWeekday` из Calendar: 1 = воскресенье ... 7 = суббота
    /// Возвращаем наш WeekDay (понедельник = 0) *неопционально*.
    static func from(calendarWeekday: Int) -> WeekDay {
        // map: 1(Sun)→6, 2(Mon)→0, 3(Tue)→1, ... 7(Sat)→5
        let index = (calendarWeekday + 5) % 7
        return WeekDay(rawValue: index) ?? .monday
    }
}
