
import UIKit

class HNewsSettingsViewController: UITableViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .Plain, target: self, action: "didTapClose")
    }
    
    func didTapClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didClickLogin(sender: AnyObject) {
        Login.login("Entalpi", password: "eagames1") { (success) in
            print("Logged in: \(success)")
        }
    }
}