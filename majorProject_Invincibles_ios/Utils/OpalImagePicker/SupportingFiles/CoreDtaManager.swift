import Foundation
import CoreData
import UIKit

class CoreDataManager{
    func addTask(name: String, imagesPath:[String] = [], categoryName: String, audioURL: String = "", id: UUID, dueDate: Date){
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return
         }
       
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         let entity =
           NSEntityDescription.entity(forEntityName: "Task",
                                      in: managedContext)!
         
         let task = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        task.setValue(id, forKeyPath: "id")
        task.setValue(false, forKeyPath: "isComplete")
        task.setValue(name, forKeyPath: "title")
        task.setValue(Date(), forKeyPath: "creationDate")
        task.setValue(dueDate, forKeyPath: "dueDate")
        if !imagesPath.isEmpty{
            let data = NSKeyedArchiver.archivedData(withRootObject: imagesPath)
            task.setValue(data, forKey: "images")
        }
        if !audioURL.isEmpty{
            task.setValue(audioURL, forKey: "audio")
        }
        task.setValue(categoryName, forKey: "category")
         do {
           try managedContext.save()
         } catch let error as NSError {
           print("Could not save. \(error), \(error.userInfo)")
         }
    }
    
    func addSubTask(name: String, imagesPath:[String] = [], categoryName: String, audioURL: String = "", parentID: UUID, dueDate: Date){
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return
         }
       
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         let entity =
           NSEntityDescription.entity(forEntityName: "Task",
                                      in: managedContext)!
         
         let task = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        task.setValue(UUID(), forKeyPath: "id")
        task.setValue(parentID, forKeyPath: "parentID")
        task.setValue(false, forKeyPath: "isComplete")
        task.setValue(name, forKeyPath: "title")
        task.setValue(Date(), forKeyPath: "creationDate")
        task.setValue(dueDate, forKeyPath: "dueDate")
        if !imagesPath.isEmpty{
            let data = NSKeyedArchiver.archivedData(withRootObject: imagesPath)
            task.setValue(data, forKey: "images")
        }
        if !audioURL.isEmpty{
            task.setValue(audioURL, forKey: "audio")
        }
        task.setValue(categoryName, forKey: "category")
         do {
           try managedContext.save()
         } catch let error as NSError {
           print("Could not save. \(error), \(error.userInfo)")
         }
    }
    
    func addCategory(categoryName: String){
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return
         }
       
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         let entity =
           NSEntityDescription.entity(forEntityName: "TaskCategory",
                                      in: managedContext)!
         
         let category = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
         
        category.setValue(categoryName, forKeyPath: "title")
        category.setValue(Date(), forKeyPath: "creationDate")
         
         do {
           try managedContext.save()
         } catch let error as NSError {
           print("Could not save. \(error), \(error.userInfo)")
         }
    }
    
    func getCategories() -> [TaskCategory]{
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return []
         }
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskCategory")
         do{
             let results = try  appDelegate.persistentContainer.viewContext.fetch(request)

             return results  as! [TaskCategory]
         }catch{
             print(error.localizedDescription)
             return []
         }
     
    }
    
    func markTaskAsComplete(id: UUID){
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return
         }
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        do{
            let results = try  appDelegate.persistentContainer.viewContext.fetch(request) as! [Task]
            if !results.isEmpty{
                results.first?.setValue(true, forKey: "isComplete")
                try appDelegate.persistentContainer.viewContext.save()
            }
            
        }catch{
            print(error.localizedDescription)
            
        }
    }
    
    
    func deleteTask(id: UUID){
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return
         }
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        do{
            let results = try  appDelegate.persistentContainer.viewContext.fetch(request) as! [Task]
            if !results.isEmpty{
                 appDelegate.persistentContainer.viewContext.delete(results.first!)
                try appDelegate.persistentContainer.viewContext.save()
            }
            
        }catch{
            print(error.localizedDescription)
          
    }
    }
    
    func allSubTasksCompleted(parentID: UUID) -> Bool{
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return false
         }
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
    
            request.predicate = NSPredicate(format: "parentID = %@", argumentArray: [parentID])
      
         do{
             let results = try  appDelegate.persistentContainer.viewContext.fetch(request) as! [Task]
             var allCompleted = true
             for task in results{
                 if !task.isComplete{
                     allCompleted = false
                     break
                 }
             }
             
             return allCompleted
            
         }catch{
             print(error.localizedDescription)
             return false
         }
     
    }
    
    func getSubTasks(parentID: UUID, isDateSort: Bool, isNameSort: Bool, title: String) -> [Task]{
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return []
         }
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: false)
        let nameSort = NSSortDescriptor(key: "title", ascending: false)
        var sorts:[NSSortDescriptor] = []
        if isDateSort{
            sorts.append(dateSort)
        }
        if isNameSort{
            sorts.append(nameSort)
        }
        if !title.isEmpty{
            request.predicate = NSPredicate(format: "parentID = %@ AND title contains[c] %@", argumentArray: [parentID, title])
        }else{
            request.predicate = NSPredicate(format: "parentID = %@", argumentArray: [parentID])
        }
        
        request.sortDescriptors = sorts
         do{
             let results = try  appDelegate.persistentContainer.viewContext.fetch(request)

             return results  as! [Task]
         }catch{
             print(error.localizedDescription)
             return []
         }
     
    }
    
    func getTasks(isDateSort: Bool, isNameSort: Bool, title: String) -> [Task]{
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return []
         }
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: false)
        let nameSort = NSSortDescriptor(key: "title", ascending: false)
        var sorts:[NSSortDescriptor] = []
        if isDateSort{
            sorts.append(dateSort)
        }
        if isNameSort{
            sorts.append(nameSort)
        }
        if !title.isEmpty{
            request.predicate = NSPredicate(format: "title contains[c] %@", argumentArray: [title])
        }
        request.sortDescriptors = sorts
         do{
             let results = try  appDelegate.persistentContainer.viewContext.fetch(request) as! [Task]
             let tasks = results.filter{$0.parentID == nil}
             return tasks
         }catch{
             print(error.localizedDescription)
             return []
         }
     
    }
    
//    func checkExistingNote(title: String) -> Bool{
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreDataEntityName.Note)
//        request.predicate = NSPredicate(format: "title contains[c] %@", argumentArray: [title])
//        do{
//         let results = try  persistenceContainer.viewContext.fetch(request) as? [Note]
//            return !results!.isEmpty
//        }catch{
//            print(error.localizedDescription)
//            return false
//        }
//    }
//
//    func deleteNote(note: GNote){
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreDataEntityName.Note)
//        request.predicate = NSPredicate(format: "title contains[c] %@", argumentArray: [note.title])
//        do{
//         let results = try  persistenceContainer.viewContext.fetch(request) as! [Note]
//            if !results.isEmpty{
//                persistenceContainer.viewContext.delete(results.first!)
//                try persistenceContainer.viewContext.save()
//                deleteNoteContent(noteTitle: note.title)
//            }
//
//        }catch{
//            print(error.localizedDescription)
//        }
//    }
//
//    //MARK:- Note Content
//    func deleteNoteContent(noteTitle: String){
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreDataEntityName.NoteContent)
//        request.predicate = NSPredicate(format: "title contains[c] %@", argumentArray: [noteTitle])
//        do{
//            let results =  try persistenceContainer.viewContext.fetch(request) as! [NoteContent]
//
//            for result in results{
//                persistenceContainer.viewContext.delete(result)
//                try persistenceContainer.viewContext.save()
//            }
//        }catch{
//            print(error.localizedDescription)
//        }
//    }
//
//    func saveNoteContent(noteContentData: GNoteContent){
//        let noteContent = NoteContent(context: persistenceContainer.viewContext)
//        noteContent.title = noteContentData.title
//        noteContent.createdAt = noteContentData.createdAt
//        noteContent.text = noteContentData.text
//        noteContent.noteType = noteContentData.noteType.rawValue
//        noteContent.recordID = noteContentData.recordID
//        do{
//            try persistenceContainer.viewContext.save()
//        }catch{
//            print(error.localizedDescription)
//        }
//    }
//
//    func getNoteContent(noteTitle: String) -> [GNoteContent]{
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreDataEntityName.NoteContent)
//        request.predicate = NSPredicate(format: "title contains[c] %@", argumentArray: [noteTitle])
//        do{
//            let results =  try persistenceContainer.viewContext.fetch(request)
//            let resultData =  results as! [NoteContent]
//            var noteContentArray:[GNoteContent] = []
//            for result in resultData{
//
//                let noteContent = GNoteContent(createdAt: result.createdAt ?? Date(), updatedAt: result.updatedAt ?? Date(), text: result.text ?? "", noteType: NoteType(rawValue: result.noteType ?? "text") ?? .text, title: noteTitle, recordID: result.recordID ?? "")
//                noteContentArray.append(noteContent)
//            }
//
//            return noteContentArray
//        }catch{
//
//        }
//        return []
//    }
//
//    func modifyNoteContent(noteContentArray: [GNoteContent]){
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreDataEntityName.NoteContent)
//        for noteContent in noteContentArray{
//            request.predicate = NSPredicate(format: "recordID = %@", noteContent.recordID)
//            do{
//                let results =  try persistenceContainer.viewContext.fetch(request)
//                let resultData =  results as! [NoteContent]
//                updateNoteDescriptionText(title: noteContent.title, descriptionText: noteContent.text)
//                for result in resultData{
//                    result.setValue(noteContent.text, forKey: "text")
//                    try persistenceContainer.viewContext.save()
//                }
//            }catch{
//
//            }
//        }
//
//    }
}
