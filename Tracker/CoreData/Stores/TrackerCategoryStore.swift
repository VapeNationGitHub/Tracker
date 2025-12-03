import Foundation
import CoreData

// MARK: - TrackerCategoryStore

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Singleton
    
    static let shared = TrackerCategoryStore()
    
    // MARK: - Callbacks
    
    var onUpdate: (() -> Void)?
    
    // MARK: - Core Data
    
    private let context: NSManagedObjectContext
    
    /// FetchedResultsController для автоматического отслеживания изменений Core Data
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
            print("❌ Error: TrackerCategoryStore FRC performFetch failed —", error)
        }
    }
    
    // MARK: - Fetch
    
    /// Возвращает текущий список категорий
    func fetch() -> [TrackerCategoryCoreData] {
        frc.fetchedObjects ?? []
    }
    
    // MARK: - Default Category
    
    /// Возвращает категорию по умолчанию "Привычки"
    func defaultCategory() throws -> TrackerCategoryCoreData {
        if let existing = fetch().first(where: { $0.title == "Привычки" }) {
            return existing
        }
        
        let category = TrackerCategoryCoreData(context: context)
        category.id = UUID()
        category.title = "Привычки"
        
        do {
            try context.save()
        } catch {
            print("❌ Error saving default category:", error)
            throw error
        }
        
        return category
    }
    
    // MARK: - CRUD
    
    /// Создание новой категории
    func create(id: UUID = UUID(), title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let category = TrackerCategoryCoreData(context: context)
        category.id = id
        category.title = trimmed
        
        do {
            try context.save()
        } catch {
            print("❌ Error creating category:", error)
            throw error
        }
    }
    
    /// Удаление категории
    func delete(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        
        do {
            try context.save()
        } catch {
            print("❌ Error deleting category:", error)
            throw error
        }
    }
    
    /// Обновление категории
    func update(_ category: TrackerCategoryCoreData, title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        category.title = trimmed
        
        do {
            try context.save()
        } catch {
            print("❌ Error updating category:", error)
            throw error
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onUpdate?()
    }
}
