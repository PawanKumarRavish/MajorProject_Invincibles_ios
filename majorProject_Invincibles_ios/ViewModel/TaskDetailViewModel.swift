

import Foundation
import UIKit

class TaskDetailViewModel{
    var coreDataManager = CoreDataManager()
    var imagePaths: Observable<[String]> = Observable([])
    var task: Observable<Task?> = Observable(nil)
    var dueDate: Observable<Date> = Observable(Date())
    var title: Observable<String> = Observable("")
    var categoryName: Observable<String> = Observable("")
    var audioURL: Observable<String> = Observable("")
    var sliderProgress: Observable<Float> = Observable(0.0)
    var isComplete: Observable<Bool> = Observable(false)
    var errorMessage: Observable<String> = Observable("")
    var displayLink = CADisplayLink()
    var recorder = AKAudioRecorder.shared
    var isSubTask = false
    
    
    func playAudio(){
        if !audioURL.value!.isEmpty{
            if recorder.isPlaying{
                recorder.stopPlaying()
                return
            }
            recorder.play(name: audioURL.value!)
        }
        
    }
    
    func deleteTask(){
        if let task = self.task.value, let id = task?.id{
            coreDataManager.deleteTask(id: id)
        }
    }
    
    func markAsComplete(){
       
        if let task = self.task.value, let id = task?.id{
            if isSubTask{
                coreDataManager.markTaskAsComplete(id: id)
                self.isComplete.value = true
                return
            }
            
            if coreDataManager.allSubTasksCompleted(parentID: id){
                coreDataManager.markTaskAsComplete(id: id)
                self.isComplete.value = true
            }else{
                errorMessage.value = "All sub tasks needs to be completed"
            }
        }
        
    }
    
    func stopPlayingAudio(){
        recorder.stopPlaying()
    }
    
    //MARK:- UPDATE SLIDER
    @objc func updateSliderProgress(){
        
         var progress = recorder.getCurrentTime() / Double(recorder.duration) /// progress 0 -> 1
        
         if recorder.isPlaying == false || progress == .infinity {
             displayLink.invalidate()
             progress = 0.0
         }
        sliderProgress.value = Float(progress)  /// Slider value is equal to progress
     }
     
    //MARK:- Run Time Loop for slider
     func playSlider(){
        if recorder.isPlaying{
            displayLink = CADisplayLink(target: self, selector: #selector(self.updateSliderProgress))
            self.displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
         }
     }
    
    func loadTaskData(){
        if let task = task.value {
            self.categoryName.value = task?.category
            self.title.value = task?.title
            if let imagesPathData = task?.images  {
                do{
                    let imagesPaths = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imagesPathData) as? [String]
                    self.imagePaths.value = imagesPaths
                }catch{}
                
            }
            self.audioURL.value = task?.audio
            self.isComplete.value = task?.isComplete
            self.dueDate.value = task?.dueDate
        }
    }
}
