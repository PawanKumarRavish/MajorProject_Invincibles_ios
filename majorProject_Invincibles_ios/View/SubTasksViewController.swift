

import UIKit

class SubTasksViewController: UIViewController {
    
    @IBOutlet weak var tasksTableView: UITableView!
    
    @IBOutlet weak var noTasksLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
     var viewModel = SubTasksViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadSubTasks()
    }
    
    private func bindUI(){
        viewModel.tasks.bind { _ in
            DispatchQueue.main.async {
                self.tasksTableView.reloadData()
                self.noTasksLabel.isHidden = !self.viewModel.tasks.value!.isEmpty
            }
        }
    }
    private func pushToAddSubTasks(){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddSubTaskViewController") as? AddSubTaskViewController{
            let viewModel = AddSubTaskViewModel()
            viewModel.parentID = self.viewModel.parentID
            vc.viewModel = viewModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func addSubTask(_ sender: UIBarButtonItem) {
        pushToAddSubTasks()
    }
    
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Sort by Date", style: .default) { action -> Void in
            self.viewModel.isDateSort = !self.viewModel.isDateSort
        }

        let secondAction: UIAlertAction = UIAlertAction(title: "Sort by Name", style: .default) { action -> Void in
            self.viewModel.isNameSort = !self.viewModel.isNameSort
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }

}

extension SubTasksViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.loadSubTasks(isDateSort: false, title: self.searchBar.text!)
    }
}

extension SubTasksViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let tasks = self.viewModel.tasks.value{
            let task = tasks[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "tasks")! as! TaskTableViewCell
            cell.taskNameLabel.text = task.title
            cell.completeImageView.image = UIImage(systemName: task.isComplete ?  "checkmark.circle.fill" : "circle")
           // cell.detailTextLabel?.text = "Date"
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tasks = self.viewModel.tasks.value{
            let viewModel = TaskDetailViewModel()
            viewModel.task.value = tasks[indexPath.row]
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TaskDetailViewController") as? TaskDetailViewController{
                viewModel.isSubTask = true
                vc.viewModel = viewModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
