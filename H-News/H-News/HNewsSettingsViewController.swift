import UIKit
import BEMCheckBox

/// Settings for the application
class Settings {
    
    fileprivate let instance = Settings()
    
    fileprivate init() {
        // TODO: Load the state
    }
    
    deinit {
        // TODO: Save the state
    }

    /// Decides which browser opens with the stories
    enum Browser {
        case safari, safariInApp, webview
    }
    
    /// Browser opened
    static var browser: Browser = .safariInApp
    
    /// Overall theme in the application
    enum Theme {
        case light, dark, automatic
    }
    
    /// Theme applied to the application
    static var theme: Theme = .dark
    
    /// Indicates whether the user is logged in
    static var loggedIn: Bool = false
    
    /// Indicates whether the user is kept logged in 
    static var stayloggedin: Bool = true
    
}

class HNewsSettingsViewController: UITableViewController {

    fileprivate struct Section {
        let title: String
        let rows: [Row]
    }
    
    fileprivate class Row {
        let title: String
        var selected: Bool // Used for checkbox like behavior
        let selectable: Bool // Selectable is a bad name for checkboxMode ...
        fileprivate let action: () -> Void // Called whenever row is clicked on
        
        init(title: String, selected: Bool, selectable: Bool, action: @escaping () -> Void) {
            self.title = title
            self.selected = selected
            self.selectable = selectable
            self.action = action
        }
        
        /// Called whenever a user selects a row
        func didSelectRow() {
            selected = !selected
            if selected || !selectable { action() }
        }
    }
    
    fileprivate var sections: [Section] = []
        
    override func viewDidLoad() {
        title = "Preferences"
        
        sections = [
            Section(title: "Account", rows:
                [Row(title: "Login in to Hacker News", selected: false, selectable: false, action: { () in
                    let loginVC = LoginViewController()
                    let navcontr = UINavigationController(rootViewController: loginVC)
                    self.present(navcontr, animated: true, completion: nil)
                })]),
            Section(title: "Browser", rows:
                [Row(title: "Safari", selected: false, selectable: true, action: { () in
                    Settings.browser = .safari
                }),
                Row(title: "Safari-in-app", selected: false, selectable: true, action: { () in
                    Settings.browser = .safariInApp
                }),
                Row(title: "Webview", selected: true, selectable: true, action: { () in
                    Settings.browser = .webview
                })]),
            Section(title: "Theme", rows:
                [Row(title: "Light theme", selected: false, selectable: true, action: { () in
                    Settings.theme = .light
                }),
                Row(title: "Dark theme", selected: true, selectable: true, action: { () in
                    Settings.theme = .dark
                }),
                Row(title: "Automatic selection", selected: false, selectable: true, action: { () in
                    Settings.theme = .automatic
                })]),
            Section(title: "About", rows:
                [Row(title: "Developer", selected: false, selectable: false, action: { () in
                    let developerVC = HNewsDeveloperViewController()
                    let navcontr = UINavigationController(rootViewController: developerVC)
                    self.present(navcontr, animated: true, completion: nil)
                }),
                Row(title: "App", selected: false, selectable: false, action: { () in
                    let appVC = HNewsApplicationViewController()
                    let navcontr = UINavigationController(rootViewController: appVC)
                    self.present(navcontr, animated: true, completion: nil)
                })])
        ]

        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .plain, target: self, action: #selector(HNewsSettingsViewController.didTapClose))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel!.text = row.title
        cell.textLabel?.textColor = Colors.lightGray
        cell.backgroundColor = Colors.gray
        cell.accessoryType = .disclosureIndicator
        // Set selection color theme
        let view = UIView()
        view.backgroundColor = UIColor.orange
        cell.selectedBackgroundView = view
        if row.selectable {
            cell.selectionStyle = .none
            let checkbox = BEMCheckBox(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            checkbox.on = row.selected
            checkbox.isUserInteractionEnabled = false
            cell.accessoryView = checkbox
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        // TODO: Guard against animating the same row
        
        // Deselect every row in section
        for i in 0..<tableView.numberOfRows(inSection: indexPath.section) {
            let indexPath = IndexPath(row: i, section: indexPath.section)
            if let checkbox = tableView.cellForRow(at: indexPath)?.accessoryView as? BEMCheckBox {
                checkbox.setOn(false, animated: true)
            }
        }
        // Select current clicked row
        if let checkbox = tableView.cellForRow(at: indexPath)?.accessoryView as? BEMCheckBox {
            checkbox.setOn(true, animated: true)
        }
        row.didSelectRow()
    }
    
    func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
}
