
import UIKit

class HNewsSettingsViewController: UITableViewController {
    
    private let sectionTitle = [
        0 : "Browser",
        1 : "Screen",
        2 : "Account",
        3 : "About",
    ]
    
    private let sectionContent = [
        0 : ["Safari", "Safari-in-app", "Webview-in-app"],
        1 : ["Light theme", "Dark theme", "Automatic selection"],
        2 : ["Login to Hacker News"],
        3 : ["Developer", "App"]
    ]

    override func viewDidLoad() {
        title = "Preferences"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        navigationController?.navigationBar.tintColor = Colors.peach
        navigationController?.navigationBar.barTintColor = UIColor.darkGrayColor()
        tableView.backgroundColor = UIColor.darkGrayColor()
        
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .Plain, target: self, action: "didTapClose")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionContent[section]?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = sectionContent[indexPath.section]?[indexPath.row] ?? ""
        return cell
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

/// Presents a check button for some kind of on-off selection/radio button style
class SelectionTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

