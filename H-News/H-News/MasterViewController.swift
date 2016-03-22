import UIKit

class MasterViewController: UIViewController {
    
    override func viewDidLoad() {
        definesPresentationContext = true
        let feed = FeedViewController()
        feed.view.frame = view.bounds
        addChildViewController(feed)
        view.addSubview(feed.view)
        feed.didMoveToParentViewController(self)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            preferredContentSize = CGSize(width: 320.0, height: 600.0)
            navigationItem.rightBarButtonItem = nil // Hide detail btn on ipads
        }
        
        // Settings
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.settings, style: .Plain, target: self, action: "didTapSettings")
        
        // Reading list / Detail
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.readingList, style: .Plain, target: self, action: "didTapDetail")
    }
    
    func didTapSettings() {
        let settingsVC = HNewsSettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsVC)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func didTapDetail() {
        if let split = splitViewController {
            split.showDetailViewController(DetailViewController(), sender: self)
        }
    }
}