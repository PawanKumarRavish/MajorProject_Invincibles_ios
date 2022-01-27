
import Foundation
class SubTasksViewModel{
    var coreDataManager = CoreDataManager()
    var tasks: Observable<[Task]> = Observable([])
    
    var parentID: UUID = UUID()
    
    var isDateSort: Bool = false{
        didSet{
            loadSubTasks(isDateSort: isDateSort)
        }
    }
    
    var isNameSort: Bool = false{
        didSet{
            loadSubTasks(isNameSort: isNameSort)
        }
    }

    func loadSubTasks(isDateSort: Bool = false, isNameSort: Bool = false, title: String = ""){
        self.tasks.value = coreDataManager.getSubTasks(parentID: parentID, isDateSort: isDateSort, isNameSort: isNameSort, title: title)
    }
}
