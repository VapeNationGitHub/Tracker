import Foundation
import CoreData

// MARK: - TrackerCategoryStore

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Singleton
    
    static let shared = TrackerCategoryStore()
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private lazy var frc: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
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
            print("❌ TrackerCategoryStore FRC error:", error)
        }
    }
    
    // MARK: - Fetch
    
    func fetch() -> [TrackerCategoryCoreData] {
        frc.fetchedObjects ?? []
    }
    
    /// Категория по умолчанию "Привычки"
    func defaultCategory() throws -> TrackerCategoryCoreData {
        if let existing = fetch().first(where: { $0.title == "Привычки" }) {
            return existing
        }
        
        let category = TrackerCategoryCoreData(context: context)
        category.id = UUID()
        category.title = "Привычки"
        
        try context.save()
        return category
    }
    
    // MARK: - Create / Delete (на будущее)
    
    func create(id: UUID = UUID(), title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.id = id
        category.title = title
        try context.save()
    }
    
    func delete(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
