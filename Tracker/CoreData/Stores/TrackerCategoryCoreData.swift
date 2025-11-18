import CoreData
import Foundation

@objc(TrackerCategoryCoreData)
public class TrackerCategoryCoreData: NSManagedObject { }

extension TrackerCategoryCoreData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    
    @NSManaged public var trackers: NSSet?
}
