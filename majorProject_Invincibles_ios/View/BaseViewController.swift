

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
       func alertWith(title: String, message: String){
           
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           
           alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
               alert.dismiss(animated: true, completion: nil)
           }))
           
           present(alert, animated: true, completion: nil)
       }
}
