import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    
    func saveContext() {
        let context = persistentContainer.viewContext
        
        print("🔍 saveContext() вызван")
        
        guard context.hasChanges else {
            print("⚠️ context.hasChanges == false — нечего сохранять")
            return
        }
        
        print("💾 Сохраняем изменения в Core Data…")
        
        do {
            try context.save()
            print("✅ УСПЕХ: Core Data сохранена")
        } catch {
            let nsError = error as NSError
            print("❌ ОШИБКА сохранения: \(nsError), \(nsError.userInfo)")
            fatalError("Unresolved Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }
}
