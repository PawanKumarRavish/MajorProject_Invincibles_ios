import UIKit
import Foundation
class AddSubTaskViewModel{
    var coreDataManager = CoreDataManager()
  
    var imagePaths: Observable<[String]> = Observable([])
    var isValidToSave: Observable<Bool?> = Observable(nil)
    var errorMessage: Observable<String> = Observable("")
    var categoryName: Observable<String> = Observable("Select Category")
    var audioURL: Observable<String> = Observable("")
    var sliderProgress: Observable<Float> = Observable(0.0)
    var dueDate = Date()
    var displayLink = CADisplayLink()
    var recorder = AKAudioRecorder.shared
    
    var parentID: UUID = UUID()
    
    func saveImagesDirectory(images:[UIImage]){
        self.imagePaths.value = []
        var imagesURLPaths:[String] = []
        for i in 0..<images.count{
            let dateString = Date().timeIntervalSince1970.string() + "\(i)"
            DirectoryManager.writeImageToPath(dateString, image: images[i])
            imagesURLPaths.append(dateString)
        }
        self.imagePaths.value = imagesURLPaths
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
    
    func saveTask(title: String){
        if title.isEmpty{
            isValidToSave.value = false
            errorMessage.value = "Please enter title"
            return
        }
        if categoryName.value == "Select Category" {
            isValidToSave.value = false
            errorMessage.value = "Please select category"
            return
        }
        isValidToSave.value = true
        coreDataManager.addSubTask(name: title, imagesPath: imagePaths.value ?? [], categoryName: categoryName.value!, audioURL: self.audioURL.value ?? "", parentID: parentID, dueDate: dueDate)
    }
    
    func playAudio(){
        if !audioURL.value!.isEmpty{
            if recorder.isPlaying{
                recorder.stopPlaying()
                return
            }
            recorder.play(name: audioURL.value!)
        }
        
    }
    
    func stopPlayingAudio(){
        recorder.stopPlaying()
    }
}
