import UIKit
import BEMCheckBox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let masterVC = MasterViewController()
        let masterNav = UINavigationController(rootViewController: masterVC)
        let detailVC = DetailViewController()
        let detailNav = UINavigationController(rootViewController: detailVC)
        
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [masterNav, detailNav]
        splitVC.delegate = self
        
        window?.rootViewController = splitVC
        window?.makeKeyAndVisible()
        
        /// Global appearance
        UINavigationBar.appearance().tintColor = Colors.peach
        UINavigationBar.appearance().barTintColor = UIColor.darkGray
        UITableView.appearance().backgroundColor = UIColor.darkGray
        
        // Checkbox default appearance
        BEMCheckBox.appearance().onTintColor = Colors.peach
        BEMCheckBox.appearance().tintColor = Colors.peach
        BEMCheckBox.appearance().onCheckColor = Colors.peach
        BEMCheckBox.appearance().lineWidth = 1.5
        BEMCheckBox.appearance().animationDuration = 0.2
        
        return true
    }

    // MARK: - Split view
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let _ = secondaryAsNavController.topViewController as? DetailViewController {
                // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                return true
            }
        }
        return false
    }
}

