import Foundation
import CoreData
import UIKit

// MARK: - TrackerStore

final class TrackerStore: NSObject {
    
    // MARK: - Singleton
    
    static let shared = TrackerStore()
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private lazy var frc: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
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
            print("❌ TrackerStore FRC error:", error)
        }
    }
    
    // MARK: - Fetch
    
    func fetch() -> [TrackerCoreData] {
        frc.fetchedObjects ?? []
    }
    
    func tracker(with id: UUID) -> TrackerCoreData? {
        fetch().first { $0.id == id }
    }
    
    // MARK: - Create

    func create(id: UUID,
                name: String,
                emoji: String,
                color: UIColor,
                schedule: [WeekDay],
                category: TrackerCategoryCoreData?) throws {
        
        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.name = name
        tracker.emoji = emoji
        tracker.colorHex = color.toHexString()
        tracker.schedule = schedule.map { "\($0.rawValue)" } as NSArray
        tracker.category = category

        try context.save()
    }
    
    // MARK: - Delete
    
    func delete(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(
            name: Notification.Name("TrackersDidChange"),
            object: nil
        )
    }
}
