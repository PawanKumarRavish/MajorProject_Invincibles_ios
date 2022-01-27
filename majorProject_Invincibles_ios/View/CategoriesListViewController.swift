
import UIKit

class CategoriesListViewController: UIViewController {

    @IBOutlet weak var categoriesTableView: UITableView!
    
    @IBOutlet weak var notCateLabel: UILabel!
    private var viewModel = CategoriesListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        viewModel.loadCategories()
    }
    
    private func bindUI(){
        viewModel.categories.bind { categories in
            self.categoriesTableView.reloadData()
            if let categories = categories {
                self.notCateLabel.isHidden = !categories.isEmpty
            }
        }
    }

    @IBAction func addAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Category",
                                        message: "Add a new name",
                                        preferredStyle: .alert)
          
          let saveAction = UIAlertAction(title: "Save",
                                         style: .default) {
            [unowned self] action in
                                          
            guard let textField = alert.textFields?.first,
              let nameToSave = textField.text else {
                return
            }
              self.viewModel.saveCategory(title: nameToSave)
            
          }
          
          let cancelAction = UIAlertAction(title: "Cancel",
                                           style: .cancel)
          
          alert.addTextField()
          
          alert.addAction(saveAction)
          alert.addAction(cancelAction)
          
          present(alert, animated: true)
    }
}

extension CategoriesListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let categories = self.viewModel.categories.value{
            let category = categories[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "category")!
            cell.textLabel?.text = category.title
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let categories = self.viewModel.categories.value{
            let category = categories[indexPath.row]
            NotificationCenter.default.post(name: .categorySelected, object: category.title)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
