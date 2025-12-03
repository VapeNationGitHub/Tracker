import Foundation

// MARK: - CategoryViewModel

final class CategoryViewModel {
    
    // MARK: - Bindings
    
    /// Вызывается, когда список категорий изменился
    var onCategoriesChanged: (() -> Void)?
    
    /// Вызывается при выборе категории
    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?
    
    // MARK: - Dependencies
    
    private let store = TrackerCategoryStore.shared
    
    // MARK: - Public State
    
    /// Все категории, отсортированные и подготовленные для таблицы
    private(set) var categories: [TrackerCategoryCoreData] = [] {
        didSet { onCategoriesChanged?() }
    }
    
    /// Текущая выбранная категория (по title)
    var selectedCategoryTitle: String?
    
    // MARK: - Init
    
    init(selectedCategoryTitle: String? = nil) {
        self.selectedCategoryTitle = selectedCategoryTitle
        loadCategories()
        
        // Подписка на изменения в модели данных
        store.onUpdate = { [weak self] in
            self?.loadCategories()
        }
    }
    
    // MARK: - Data Loading
    
    /// Загружает категории из Core Data.
    func loadCategories() {
        categories = store.fetch()
    }
    
    // MARK: - Table Helpers
    
    func numberOfRows() -> Int {
        categories.count
    }
    
    func titleForRow(at index: Int) -> String {
        categories[index].title ?? ""
    }
    
    // MARK: - Selection
    
    /// Устанавливает выбранную категорию
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        
        let category = categories[index]
        selectedCategoryTitle = category.title
        onCategorySelected?(category)
    }
    
    // MARK: - CRUD Operations
    
    /// Создание новой категории
    func addCategory(title: String) {
        do {
            try store.create(title: title)
        } catch {
            print("❌ Ошибка при создании категории:", error)
        }
        loadCategories()
    }
    
    /// Удаление категории
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        
        let category = categories[index]
        do {
            try store.delete(category)
        } catch {
            print("❌ Ошибка при удалении категории:", error)
        }
        loadCategories()
    }
    
    /// Обновление существующей категории
    func updateCategory(at index: Int, newTitle: String) {
        guard index < categories.count else { return }
        
        let category = categories[index]
        do {
            try store.update(category, title: newTitle)
        } catch {
            print("❌ Ошибка при обновлении категории:", error)
        }
        loadCategories()
    }
}
