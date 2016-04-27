import UIKit

class MasterViewController: UIViewController {
    
    private let feedSwitchView = FeedSwitchView()
    
    override func viewDidLoad() {
        // Fixes so that the views end up below the navbar not underneth.
        navigationController?.navigationBar.translucent = false
        definesPresentationContext = true
        
        let topVC = currentFeedViewController
        let newVC = FeedViewController()
        newVC.downloader = Downloader<News>(.Top)
        let askVC = FeedViewController()
        askVC.downloader = Downloader<News>(.Top)
        let showVC = FeedViewController()
        showVC.downloader = Downloader<News>(.Top)
        
        // Feed switcher view
        feedSwitchView.delegate = self
        feedSwitchView.feeds = [Feed(name: "TOP", selected: true, type: .Top, viewController: topVC),
                                Feed(name: "NEW", selected: false, type: .New, viewController: newVC),
                                Feed(name: "ASK", selected: false, type: .Ask, viewController: askVC),
                                Feed(name: "SHOW", selected: false, type: .Show, viewController: showVC)]
        view.addSubview(feedSwitchView)
        
        // Install the feed view controllers
        installFeedViewController(currentFeedViewController)
        installFeedViewController(newVC)
        installFeedViewController(askVC)
        installFeedViewController(showVC)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            // Reading list / Detail
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.readingList, style: .Plain, target: self, action: #selector(MasterViewController.didTapDetail))
        }
        
        // Settings
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.settings, style: .Plain, target: self, action: #selector(MasterViewController.didTapSettings))
        
        view.bringSubviewToFront(feedSwitchView)
    }
    
    /// The currently shown feed viewcontroller
    var currentFeedViewController = FeedViewController()
    
    var feedViewControllers: [FeedViewController] = []
    
    func installFeedViewController(viewController: FeedViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        if feedViewControllers.count == 0 {
            // Add first view controller as the selected one
            currentFeedViewController = viewController
            selectViewController(viewController)
        } else {
            let previousViewController = feedViewControllers[feedViewControllers.count - 1]
            viewController.view.snp_makeConstraints { (make) in
                make.top.equalTo(self.feedSwitchView.snp_bottom)
                make.centerY.equalTo(0)
                make.left.equalTo(previousViewController.view.snp_right)
                make.bottom.equalTo(self.view.snp_bottom)
            }
        }
        feedViewControllers.append(viewController)
    }
    
    func selectViewController(viewController: UIViewController) {
        let toViewController = viewController
        let fromViewController = currentFeedViewController
        
        let goingRight = fromViewController.view.frame.origin.x > toViewController.view.frame.origin.x
        let travelDistance = view.bounds.width
        let travel = CGAffineTransformMakeTranslation(goingRight ? -travelDistance : travelDistance, 0)
        toViewController.view.alpha = 0
        toViewController.view.transform = CGAffineTransformInvert(travel)
        
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.TransitionNone, animations: { 
            fromViewController.view.transform = travel
            toViewController.view.transform = CGAffineTransformIdentity
            toViewController.view.alpha = 1
            
            toViewController.view.snp_makeConstraints { (make) in
                make.top.equalTo(self.feedSwitchView.snp_bottom)
                make.centerX.equalTo(0)
                make.right.left.equalTo(0)
                make.bottom.equalTo(self.view.snp_bottom)
            }

            }) { (complete) in
                fromViewController.view.transform = CGAffineTransformIdentity
        }
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
        splitViewController?.showDetailViewController(DetailViewController(), sender: self)
    }
}

extension MasterViewController: FeedSwitchDelegate {
    func didSelect(view: FeedSwitchView, feed: Feed) {
        selectViewController(feed.viewController)
    }
}

/// View-model which represents a feed
struct Feed {
    let name: String
    var selected: Bool
    let type: FeedType
    let viewController: FeedViewController
    
    enum FeedType { case Show, Ask, New, Top }
}

protocol FeedSwitchDelegate {
    func didSelect(view: FeedSwitchView, feed: Feed)
}

/// FeedSwitchView represent a tabbar like view which switches feeds.
/// Need to add this as a subview, after setting it's properties.
class FeedSwitchView: UIView {
    
    private class FeedItemView: UIControl {
        
        private let title: UILabel = UILabel()
        
        var feed: Feed? {
            didSet {
                guard let feed = feed else { return }
                tag = feed.name.hashValue
                
                title.text = feed.name
                title.textAlignment = .Center
                title.textColor = Colors.gray
                addSubview(title)
                title.snp_makeConstraints { (make) in
                    make.center.equalTo(0)
                }
                let tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(FeedSwitchView.FeedItemView.didTapFeed(_:)))
                addGestureRecognizer(tapGestureRecog)
            }
        }
        
        @objc func didTapFeed(sender: UITapGestureRecognizer) {
            guard let feed = feed else { return }
            guard !feed.selected else { return }
            guard let parent = superview as? FeedSwitchView else { return }
            parent.selected(feed)
            parent.selectorAnimateTo(self)
        }
    }
    
    private let selector: UIView = UIView()
    
    var feeds: [Feed]?
    
    var delegate: FeedSwitchDelegate?
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        guard let feeds = feeds else { return }
        
        backgroundColor = Colors.lightGray
        
        self.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.centerX.equalTo(0)
            make.top.equalTo(superview.snp_top)
            make.height.equalTo(superview.snp_height).dividedBy(14)
        }
        
        // Setup feed items
        var rightViewConstraint = superview.snp_right
        for feed in feeds {
            let feedTitle = FeedItemView()
            addSubview(feedTitle)
            feedTitle.feed = feed
            let rightPadding = superview.frame.width / CGFloat(feeds.count + 1)
            feedTitle.snp_makeConstraints(closure: { (make) in
                make.width.equalTo(rightPadding)
                make.height.equalTo(rightPadding / 2)
                make.centerX.equalTo(rightViewConstraint).offset(-rightPadding)
                make.centerY.equalTo(0)
            })
            rightViewConstraint = feedTitle.snp_centerX
        }
        
        guard let selectedFeed = feeds.filter({ (feed) -> Bool in feed.selected }).first else { return }
        guard let selectedView = viewWithTag(selectedFeed.name.hashValue) else { return }
        // Setup selector
        selector.backgroundColor = Colors.gray
        addSubview(selector)
        selector.snp_makeConstraints { (make) in
            make.height.equalTo(2)
            make.width.equalTo(superview.snp_width).dividedBy(16)
            make.top.equalTo(selectedView.snp_baseline).offset(-4)
            make.centerX.equalTo(selectedView.snp_centerX)
        }
    }
    
    private func selected(selectedFeed: Feed) {
        delegate?.didSelect(self, feed: selectedFeed)
        guard let feeds = feeds else { return }
        for feed in feeds {
            // Deselect all
            if let view = viewWithTag(feed.name.hashValue) as? FeedItemView {
                view.feed?.selected = false
            }
            // Select the selected
            if let view = viewWithTag(selectedFeed.name.hashValue) as? FeedItemView {
                view.feed?.selected = true
            }
        }
    }
    
    private func selectorAnimateTo(selectedView: FeedItemView) {
        UIView.animateWithDuration(0.2) {
            // make animatable changes
            self.selector.snp_remakeConstraints(closure: { (make) in
                make.height.equalTo(2)
                make.width.equalTo(self.snp_width).dividedBy(16)
                make.top.equalTo(selectedView.snp_baseline).offset(-4)
                make.centerX.equalTo(selectedView.snp_centerX)
            })
            // do the animation
            self.layoutIfNeeded()
        }
    }
}
