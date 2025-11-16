import Foundation

final class WeekDaysTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        // сохраняем расписание как массив Int
        guard let array = value as? [Int] else { return nil }
        return array as NSArray
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        // возвращаем обратно как [Int]
        return value as? [Int]
    }
}
