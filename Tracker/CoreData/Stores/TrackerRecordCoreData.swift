import CoreData
import Foundation

@objc(TrackerRecordCoreData)
public class TrackerRecordCoreData: NSManagedObject { }

extension TrackerRecordCoreData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    
    @NSManaged public var tracker: TrackerCoreData?
}
