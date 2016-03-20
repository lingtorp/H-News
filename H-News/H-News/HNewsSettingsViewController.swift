import UIKit
import BEMCheckBox

/// Settings for the application
class Settings {

    enum Browser {
        case Safari, SafariInApp, Webview
    }
    
    /// Browser opened
    static var browser: Browser = .Webview
    
    enum Theme {
        case Light, Dark, Automatic
    }
    
    /// Theme applied to the application
    static var theme: Theme = .Dark
    
    /// Indicates whether the user is logged in
    static var loggedIn: Bool = false
    
    /// Indicates whether the user is kept logged in 
    static var stayloggedin: Bool = true
}

class HNewsSettingsViewController: UITableViewController {

    private struct Section {
        let title: String
        let rows: [Row]
    }
    
    private class Row {
        let title: String
        var selected: Bool
        let selectable: Bool
        private let action: () -> Void // Called whenever row is clicked on
        
        init(title: String, selected: Bool, selectable: Bool, action: () -> Void) {
            self.title = title
            self.selected = selected
            self.selectable = selectable
            self.action = action
        }
        
        func toggleSelect() {
            selected = !selected
            if selected || !selectable { action() }
        }
    }
    
    private var sections: [Section] = []
        
    override func viewDidLoad() {
        title = "Preferences"
        
        sections = [
            Section(title: "Browser", rows:
                [Row(title: "Safari", selected: false, selectable: true, action: { () in
                    Settings.browser = .Safari
                }),
                Row(title: "Safari-in-app", selected: false, selectable: true, action: { () in
                    Settings.browser = .SafariInApp
                }),
                Row(title: "Webview", selected: true, selectable: true, action: { () in
                    Settings.browser = .Webview
                })]),
            Section(title: "Theme", rows:
                [Row(title: "Light theme", selected: false, selectable: true, action: { () in
                    Settings.theme = .Light
                }),
                Row(title: "Dark theme", selected: true, selectable: true, action: { () in
                    Settings.theme = .Dark
                }),
                Row(title: "Automatic selection", selected: false, selectable: true, action: { () in
                    Settings.theme = .Automatic
                })]),
            Section(title: "Account", rows:
                [Row(title: "Login in to Hacker News", selected: false, selectable: false, action: { () in
                    let loginVC = HNewsLoginViewController()
                    let navcontr = UINavigationController(rootViewController: loginVC)
                    self.presentViewController(navcontr, animated: true, completion: nil)
                })]),
            Section(title: "About", rows:
                [Row(title: "Developer", selected: false, selectable: false, action: { () in
                    let developerVC = HNewsDeveloperViewController()
                    let navcontr = UINavigationController(rootViewController: developerVC)
                    self.presentViewController(navcontr, animated: true, completion: nil)
                }),
                Row(title: "App", selected: false, selectable: false, action: { () in
                    let appVC = HNewsApplicationViewController()
                    let navcontr = UINavigationController(rootViewController: appVC)
                    self.presentViewController(navcontr, animated: true, completion: nil)
                })])
        ]

        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .Plain, target: self, action: "didTapClose")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel!.text = row.title
        cell.textLabel?.textColor = Colors.lightGray
        cell.backgroundColor = Colors.gray
        cell.accessoryType = .DisclosureIndicator
        // Set selection color theme
        let view = UIView()
        view.backgroundColor = UIColor.orangeColor()
        cell.selectedBackgroundView = view
        if row.selectable {
            cell.selectionStyle = .None
            let checkbox = BEMCheckBox(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            checkbox.on = row.selected
            cell.accessoryView = checkbox
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        if row.selectable {
            section.rows.forEach { row in if row.selected { row.toggleSelect() } }
        }
        row.toggleSelect()
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
    }
    
    func didTapClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
