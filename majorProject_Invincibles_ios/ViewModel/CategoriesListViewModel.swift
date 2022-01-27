
import Foundation

struct CategoriesListViewModel{
    var coreDataManager = CoreDataManager()
    var categories: Observable<[TaskCategory]> = Observable([])
    
    func saveCategory(title: String){
        coreDataManager.addCategory(categoryName: title)
        loadCategories()
    }
    
    func loadCategories(){
        self.categories.value = coreDataManager.getCategories()
    }
}
