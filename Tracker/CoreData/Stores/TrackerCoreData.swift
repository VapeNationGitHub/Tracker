import CoreData
import Foundation

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject { }

extension TrackerCoreData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var emoji: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var isPinned: Bool
    @NSManaged public var schedule: NSObject?
    
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var records: NSSet?
}
