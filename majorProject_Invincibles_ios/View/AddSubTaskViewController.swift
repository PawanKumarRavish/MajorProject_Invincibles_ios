
import UIKit

class AddSubTaskViewController: BaseViewController {
    
    @IBOutlet weak var audioProgressView: UIProgressView!
    @IBOutlet weak var addAutioButton: UIButton!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var audioPlayButton: UIButton!
     var viewModel = AddSubTaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        addOberver()
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: .categorySelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .recordedAudio, object: nil)
    }
    private func addOberver(){
        NotificationCenter.default.addObserver(self, selector: #selector(categorySelected(notification:)), name: .categorySelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recordedAudio(notification:)), name: .recordedAudio, object: nil)
    }
    
    @objc func recordedAudio(notification: Notification){
        if let recordedAudioUrl = notification.object as? String{
            self.viewModel.audioURL.value = recordedAudioUrl
        }
    }
    
    @objc func categorySelected(notification: Notification){
        if let categoryName = notification.object as? String{
            self.viewModel.categoryName.value = categoryName
            
        }
    }
    
    @IBAction func dueDateChanged(_ sender: UIDatePicker) {
        
    }
    
    @IBAction func playAudioAction(_ sender: UIButton) {
        self.viewModel.playAudio()
    }
    
    private func bindUI(){
        self.viewModel.imagePaths.bind { imagePaths in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if let imagePaths = imagePaths{
                    self.collectionView.isHidden = imagePaths.isEmpty
                }
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
        
        self.viewModel.isValidToSave.bind { isValidToSave in
            DispatchQueue.main.async {
                if let isValidToSave = isValidToSave{
                    if isValidToSave ?? false{
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.alertWith(title: "", message: self.viewModel.errorMessage.value ?? "")
                    }
                }else{
                    
                }
            }
        }
    }
    
    private func pushToSubTasks(){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubTasksViewController") as? SubTasksViewController{
            let viewModel = SubTasksViewModel()
            viewModel.parentID = self.viewModel.parentID
            vc.viewModel = viewModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func selectCategryAction(_ sender: Any) {
        
    }

    
    @IBAction func addAudioAction(_ sender: UIButton) {
        
    }
    
    @IBAction func addPictureAction(_ sender: Any) {
        let imagePicker = OpalImagePickerController()
        imagePicker.imagePickerDelegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction private func saveAction(_ sender: UIBarButtonItem) {
        self.viewModel.saveTask(title: self.titleField.text!)
    }
}

extension AddSubTaskViewController: OpalImagePickerControllerDelegate{
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        self.viewModel.saveImagesDirectory(images: images)
        picker.dismiss(animated: true)
    }
}

extension AddSubTaskViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
