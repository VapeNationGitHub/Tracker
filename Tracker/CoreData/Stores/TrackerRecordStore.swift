import Foundation
import CoreData

// MARK: - TrackerRecordStore

final class TrackerRecordStore: NSObject {
    
    // MARK: - Singleton
    
    static let shared = TrackerRecordStore()
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private lazy var frc: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Init
    
    private override init() {
        self.context = CoreDataStack.shared.context
        super.init()
        
        do {
            try frc.performFetch()
        } catch {
            print("❌ TrackerRecordStore FRC error:", error)
        }
    }
    
    // MARK: - Fetch
    
    func fetch() -> [TrackerRecordCoreData] {
        frc.fetchedObjects ?? []
    }
    
    // MARK: - Helpers
    
    func isCompleted(tracker: TrackerCoreData, on date: Date) -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker == %@ AND date == %@",
            tracker,
            date as NSDate
        )
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
    
    func completedCount(for tracker: TrackerCoreData) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker == %@",
            tracker
        )
        return (try? context.count(for: request)) ?? 0
    }
    
    // MARK: - Create / Delete
    /*
    func add(tracker: TrackerCoreData, date: Date) throws {
        if isCompleted(tracker: tracker, on: date) { return }
        
        let record = TrackerRecordCoreData(context: context)
        record.id = UUID()
        record.date = date
        record.tracker = tracker
        
        try context.save()
    }
     */
    
    func add(tracker: TrackerCoreData, date: Date) throws {
        if isCompleted(tracker: tracker, on: date) { return }

        let record = TrackerRecordCoreData(context: context)
        record.id = UUID()
        record.date = date

        // 🔥 САМЫЙ ВАЖНЫЙ МОМЕНТ:
        record.tracker = tracker

        // и обязательно обратная связь
        tracker.addToRecords(record)

        try context.save()
    }
    
    func remove(tracker: TrackerCoreData, date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker == %@ AND date == %@",
            tracker,
            date as NSDate
        )
        
        if let record = try context.fetch(request).first {
            context.delete(record)
            try context.save()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
