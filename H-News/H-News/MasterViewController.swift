import UIKit

class MasterViewController: UIViewController {
    
    fileprivate let feedSwitchView = FeedSwitchView()
    
    override func viewDidLoad() {
        // Fixes so that the views end up below the navbar not underneth.
        navigationController?.navigationBar.isTranslucent = false
        definesPresentationContext = true
        
        let topVC = currentFeedViewController
        let newVC = FeedViewController()
        let askVC = FeedViewController()
        let showVC = FeedViewController()
        
        // Feed switcher view
        feedSwitchView.delegate = self
        feedSwitchView.feeds = [Feed(name: "TOP", selected: true, type: .top, viewController: topVC),
                                Feed(name: "NEW", selected: false, type: .new, viewController: newVC),
                                Feed(name: "ASK", selected: false, type: .ask, viewController: askVC),
                                Feed(name: "SHOW", selected: false, type: .show, viewController: showVC)]
        view.addSubview(feedSwitchView)
        
        // Install the feed view controllers
        installFeedViewController(currentFeedViewController)
        installFeedViewController(newVC)
        installFeedViewController(askVC)
        installFeedViewController(showVC)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Reading list / Detail
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.readingList, style: .plain, target: self, action: #selector(MasterViewController.didTapDetail))
        }
        
        // Settings
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.settings, style: .plain, target: self, action: #selector(MasterViewController.didTapSettings))
        
        view.bringSubview(toFront: feedSwitchView)
    }
    
    /// The currently shown feed viewcontroller
    var currentFeedViewController = FeedViewController()
    
    var feedViewControllers: [FeedViewController] = []
    
    func installFeedViewController(_ viewController: FeedViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
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
    
    func selectViewController(_ viewController: FeedViewController) {
        let toViewController = viewController
        let fromViewController = currentFeedViewController
        
        let goingRight = feedViewControllers.index(of: toViewController) ?? 0 < feedViewControllers.index(of: fromViewController) ?? 0
        let travelDistance = view.bounds.width
        let travel = CGAffineTransform(translationX: goingRight ? -travelDistance : travelDistance, y: 0)
        toViewController.view.alpha = 0
        toViewController.view.transform = travel.inverted()
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: { 
            fromViewController.view.transform = travel
            toViewController.view.transform = CGAffineTransform.identity
            toViewController.view.alpha = 1
            
            toViewController.view.snp_makeConstraints { (make) in
                make.top.equalTo(self.feedSwitchView.snp_bottom)
                make.centerX.equalTo(0)
                make.right.left.equalTo(0)
                make.bottom.equalTo(self.view.snp_bottom)
            }

            }) { (complete) in
                fromViewController.view.transform = CGAffineTransform.identity
        }
        currentFeedViewController = toViewController
    }
    
    func didTapSettings() {
        let settingsVC = HNewsSettingsViewController()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let navContr = UINavigationController(rootViewController: settingsVC)
        present(navContr, animated: true) { 
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func didTapDetail() {
        splitViewController?.showDetailViewController(DetailViewController(), sender: self)
    }
}

extension MasterViewController: FeedSwitchDelegate {
    func didSelect(_ view: FeedSwitchView, feed: Feed) {
        selectViewController(feed.viewController)
    }
}

/// View-model which represents a feed
struct Feed {
    let name: String
    var selected: Bool
    let type: FeedType
    let viewController: FeedViewController
    
    enum FeedType { case show, ask, new, top }
}

protocol FeedSwitchDelegate {
    func didSelect(_ view: FeedSwitchView, feed: Feed)
}

/// FeedSwitchView represent a tabbar like view which switches feeds.
/// Need to add this as a subview, after setting it's properties.
class FeedSwitchView: UIView {
    
    fileprivate class FeedItemView: UIControl {
        
        fileprivate let title: UILabel = UILabel()
        
        var feed: Feed? {
            didSet {
                guard let feed = feed else { return }
                tag = feed.name.hashValue
                
                title.text = feed.name
                title.textAlignment = .center
                title.textColor = Colors.gray
                addSubview(title)
                title.snp_makeConstraints { (make) in
                    make.center.equalTo(0)
                }
                let tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(FeedSwitchView.FeedItemView.didTapFeed(_:)))
                addGestureRecognizer(tapGestureRecog)
            }
        }
        
        @objc func didTapFeed(_ sender: UITapGestureRecognizer) {
            guard let feed = feed else { return }
            guard !feed.selected else { return }
            guard let parent = superview as? FeedSwitchView else { return }
            parent.selected(feed)
            parent.selectorAnimateTo(self)
        }
    }
    
    fileprivate let selector: UIView = UIView()
    
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
            feedTitle.snp_makeConstraints({ (make) in
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
    
    fileprivate func selected(_ selectedFeed: Feed) {
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
    
    fileprivate func selectorAnimateTo(_ selectedView: FeedItemView) {
        UIView.animate(withDuration: 0.2, animations: {
            // make animatable changes
            self.selector.snp_remakeConstraints({ (make) in
                make.height.equalTo(2)
                make.width.equalTo(self.snp_width).dividedBy(16)
                make.top.equalTo(selectedView.snp_baseline).offset(-4)
                make.centerX.equalTo(selectedView.snp_centerX)
            })
            // do the animation
            self.layoutIfNeeded()
        }) 
    }
}
