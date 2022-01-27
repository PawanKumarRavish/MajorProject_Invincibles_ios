

import UIKit

class TaskDetailViewController: BaseViewController {
    @IBOutlet weak var audioProgressView: UIProgressView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var subTasksView: UIStackView!
    @IBOutlet weak var compeleteButton: UIButton!
    @IBOutlet weak var audioPlayButton: UIButton!
    var viewModel = TaskDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        viewModel.loadTaskData()
    }
    private func bindUI(){
        self.subTasksView.isHidden = self.viewModel.isSubTask
        
        self.viewModel.errorMessage.bind { errorMessage in
            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                DispatchQueue.main.async {
                    self.alertWith(title: "", message: errorMessage)
                }
            }
        }
        
        self.viewModel.imagePaths.bind { imagePaths in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if let imagePaths = imagePaths{
                    self.collectionView.isHidden = imagePaths.isEmpty
                }
            }
        }
        self.viewModel.dueDate.bind { dueDate in
            if let dueDate = dueDate{
                self.dueDateLabel.text = dueDate.asString(style: .full)
            }
        }
        self.viewModel.sliderProgress.bind { sliderProgress in
            if let sliderProgress = sliderProgress {
                DispatchQueue.main.async {
                    self.audioProgressView.progress = sliderProgress
                }
            }
        }
        
        self.viewModel.audioURL.bind { audioURL in
            if let audioURL = audioURL{
                DispatchQueue.main.async {
                    self.audioView.isHidden =  audioURL.isEmpty
                }
            }
        }
        self.viewModel.categoryName.bind { categoryName in
            if let categoryName = categoryName {
                DispatchQueue.main.async {
                    self.selectCategoryButton.setTitle(categoryName, for: .normal)
                }
            }
        }
        self.viewModel.title.bind { title in
            DispatchQueue.main.async {
                self.titleField.text = title
            }
        }
        
        self.viewModel.isComplete.bind { isComplete in
            DispatchQueue.main.async {
                if let isComplete = isComplete, isComplete{
                    self.compeleteButton.setTitle("Completed", for: .normal)
                    self.compeleteButton.isEnabled = false
                }else{
                    self.compeleteButton.setTitle("Mark As Complete", for: .normal)
                    self.compeleteButton.isEnabled = true
                }
                
            }
        }
    }
    
    private func pushToSubTasks(){
        if let taskValue = self.viewModel.task.value, let task = taskValue{
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubTasksViewController") as? SubTasksViewController{
                let viewModel = SubTasksViewModel()
                viewModel.parentID = task.id!
                vc.viewModel = viewModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @IBAction func subTasksAction(_ sender: UIButton) {
        pushToSubTasks()
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        self.viewModel.deleteTask()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func completeAction(_ sender: UIButton) {
        self.viewModel.markAsComplete()
    }
    
    @IBAction func playAudioAction(_ sender: UIButton) {
        self.viewModel.playAudio()
    }
    
}

extension TaskDetailViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imagePaths.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        if  let path = viewModel.imagePaths.value?[indexPath.row]{
            do {
                let image = try UIImage.init(data: Data(contentsOf: URL.createFolder(folderName: "upload")!.appendingPathComponent(path)))
                cell.photo.image = image
            }catch{}
            
        }
        return cell
    }
}
