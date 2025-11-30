import Foundation

@objc(WeekDaysTransformer)
final class WeekDaysTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        // сохраняем как Data
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    // [String] / NSArray → Data
    override func transformedValue(_ value: Any?) -> Any? {
        // Core Data чаще всего отдаёт сюда NSArray
        guard let array = value as? [Any] else { return nil }

        let strings = array.compactMap { $0 as? String }

        do {
            let data = try JSONEncoder().encode(strings)
            return data as NSData
        } catch {
            print("❌ WeekDaysTransformer encode error:", error)
            return nil
        }
    }

    // Data → [String]
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }

        do {
            let strings = try JSONDecoder().decode([String].self, from: data)
            return strings
        } catch {
            print("❌ WeekDaysTransformer decode error:", error)
            return nil
        }
    }
}





/*
import Foundation

@objc(WeekDaysTransformer)
final class WeekDaysTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [String] else { return nil }
        
        do {
            let data = try JSONEncoder().encode(days)
            return data as NSData
        } catch {
            print("❌ Encode error:", error)
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            let days = try JSONDecoder().decode([String].self, from: data)
            return days
        } catch {
            print("❌ Decode error:", error)
            return nil
        }
    }
}
*/
