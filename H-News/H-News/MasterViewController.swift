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
        
        // Feed switcher view
        let feedSwitchView = FeedSwitchView()
        feedSwitchView.feeds = [Feed(name: "TOP", selected: true),
                                Feed(name: "NEW", selected: false),
                                Feed(name: "ASK", selected: false),
                                Feed(name: "SHOW", selected: false)]
        view.addSubview(feedSwitchView)
        
        // Settings
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.settings, style: .Plain, target: self, action: #selector(MasterViewController.didTapSettings))
        
        // Reading list / Detail
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.readingList, style: .Plain, target: self, action: #selector(MasterViewController.didTapDetail))
    }
    
    func didTapSettings() {
        let settingsVC = HNewsSettingsViewController()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let navContr = UINavigationController(rootViewController: settingsVC)
        presentViewController(navContr, animated: true) { 
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func didTapDetail() {
        if let split = splitViewController {
            split.showDetailViewController(DetailViewController(), sender: self)
        }
    }
}

/// Represents a general feed
struct Feed {
    let name: String
    var selected: Bool
}

/// FeedSwitchView represent a tabbar like view which switches feeds.
/// Need to add this as a subview, after setting it's properties.
class FeedSwitchView: UIView {
    
    var feeds: [Feed]?
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        guard let feeds = feeds else { return }
        
        backgroundColor = Colors.gray
        
        self.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.centerX.equalTo(0)
            make.top.equalTo(superview.snp_top)
            make.height.equalTo(superview.snp_height).dividedBy(6)
        }
        
        var rightViewConstraint = superview.snp_right
        for feed in feeds {
            let feedTitle = UILabel()
            addSubview(feedTitle)
            feedTitle.text = feed.name
            feedTitle.textAlignment = .Center
            feedTitle.textColor = Colors.lightGray
            feedTitle.snp_makeConstraints(closure: { (make) in
                make.right.greaterThanOrEqualTo(rightViewConstraint).offset(0)
                make.left.greaterThanOrEqualTo(0)
                make.centerY.equalTo(0)
            })
            rightViewConstraint = feedTitle.snp_left
        }
    }
    
    
}
