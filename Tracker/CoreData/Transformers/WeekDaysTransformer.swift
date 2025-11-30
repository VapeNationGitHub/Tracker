import Foundation

@objc(WeekDaysTransformer)
final class WeekDaysTransformer: ValueTransformer {
    
    // MARK: - Обязательные переопределения

    override class func transformedValueClass() -> AnyClass {
        return NSData.self // Core Data ожидает Data
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    // MARK: - Преобразование из [String] → Data

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [Any] else {
            print("🟥 WeekDaysTransformer: transformedValue не массив")
            return nil
        }

        let strings = array.compactMap { $0 as? String }

        do {
            let data = try JSONEncoder().encode(strings)
            return data as NSData
        } catch {
            print("❌ WeekDaysTransformer encode error:", error)
            return nil
        }
    }

    // MARK: - Преобразование из Data → [String]

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        print("📦 reverseTransformedValue called with value: \(String(describing: value))")

        guard let data = value as? Data ?? (value as? NSData) as Data? else {
            print("🟥 WeekDaysTransformer: значение не Data или NSData")
            return nil
        }

        do {
            let strings = try JSONDecoder().decode([String].self, from: data)
            print("✅ WeekDaysTransformer decoded:", strings)
            return strings
        } catch {
            print("❌ WeekDaysTransformer decode error:", error)
            return nil
        }
    }
}
