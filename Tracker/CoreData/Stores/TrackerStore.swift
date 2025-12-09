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
    
    func getSchedule(from tracker: TrackerCoreData) -> [WeekDay] {
        guard let rawArray = tracker.schedule as? [Any], !rawArray.isEmpty else {
            print("🟥 Invalid or empty schedule in tracker:", tracker.name ?? "Unknown")
            return []
        }
        
        let weekdays: [WeekDay] = rawArray.compactMap { raw in
            if let string = raw as? String, let intValue = Int(string), let day = WeekDay(rawValue: intValue) {
                return day
            } else {
                print("🟥 Invalid raw value in schedule:", raw)
                return nil
            }
        }
        
        return weekdays
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
        
        guard !schedule.isEmpty else {
            print("🟥 Ошибка: пустое расписание — не сохраняем трекер")
            return
        }
        
        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.name = name
        tracker.emoji = emoji
        tracker.colorHex = color.toHexString()
        
        let scheduleStrings = schedule.map { String($0.rawValue) }
        tracker.schedule = scheduleStrings as NSArray
        
        tracker.category = category
        
        try context.save()
    }
    
    // MARK: - Update
    
    func update(
        trackerCD: TrackerCoreData,
        name: String,
        emoji: String,
        color: UIColor,
        schedule: [WeekDay],
        category: TrackerCategoryCoreData?
    ) throws {
        
        trackerCD.name = name
        trackerCD.emoji = emoji
        trackerCD.colorHex = color.toHexString()
        
        let scheduleStrings = schedule.map { String($0.rawValue) }
        trackerCD.schedule = scheduleStrings as NSArray
        
        trackerCD.category = category
        
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
