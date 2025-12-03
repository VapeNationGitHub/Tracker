import Foundation

// MARK: - CategoryViewModel

final class CategoryViewModel {

    // MARK: - Bindings

    var onCategoriesChanged: (() -> Void)?

    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?

    // MARK: - Private Properties

    private let store = TrackerCategoryStore.shared

    // MARK: - Public Properties

    private(set) var categories: [TrackerCategoryCoreData] = [] {
        didSet {
            onCategoriesChanged?()
        }
    }

    var selectedCategoryTitle: String?

    // MARK: - Init

    init(selectedCategoryTitle: String? = nil) {
        self.selectedCategoryTitle = selectedCategoryTitle
        loadCategories()

        // Подписываемся на обновления из Store
        store.onUpdate = { [weak self] in
            self?.loadCategories()
        }
    }

    // MARK: - Data Loading

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

    func selectCategory(at index: Int) {
        let category = categories[index]
        selectedCategoryTitle = category.title
        onCategorySelected?(category)
    }

    // MARK: - CRUD

    func addCategory(title: String) {
        try? store.create(title: title)
        loadCategories()
    }

    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        let cat = categories[index]
        try? store.delete(cat)
        loadCategories()
    }

    func updateCategory(at index: Int, newTitle: String) {
        guard index < categories.count else { return }
        let cat = categories[index]
        try? store.update(cat, title: newTitle)
        loadCategories()
    }
}
