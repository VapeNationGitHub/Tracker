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
