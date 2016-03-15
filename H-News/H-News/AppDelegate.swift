import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let masterVC = MasterViewController()
        let masterNav = UINavigationController(rootViewController: masterVC)
        let detailVC = DetailViewController()
        let detailNav = UINavigationController(rootViewController: detailVC)
        
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [masterNav, detailNav]
        splitVC.delegate = self
        
        window?.rootViewController = splitVC
        window?.makeKeyAndVisible()
    
        return true
    }

    // MARK: - Split view
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let _ = secondaryAsNavController.topViewController as? DetailViewController {
                // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                return true
            }
        }
        return false
    }
}

