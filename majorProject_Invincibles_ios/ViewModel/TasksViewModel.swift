
import Foundation

struct TasksViewModel{
    var coreDataManager = CoreDataManager()
    var tasks: Observable<[Task]> = Observable([])
    var isDateSort: Bool = false{
        didSet{
            loadTasks(isDateSort: isDateSort)
        }
    }
    
    var isNameSort: Bool = false{
        didSet{
            loadTasks(isNameSort: isNameSort)
        }
    }

    func loadTasks(isDateSort: Bool = false, isNameSort: Bool = false, title: String = ""){
        self.tasks.value = coreDataManager.getTasks(isDateSort: isDateSort, isNameSort: isNameSort, title: title)
    }
}
