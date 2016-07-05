import UIKit
import SafariServices

@available(iOS 9.0, *)
extension FeedViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        guard let viewControllerToCommit = viewControllerToCommit as? SafariViewController,
              let news = viewControllerToCommit.news else { return }
        navigationController?.navigationBar.hidden = true
        showViewController(viewControllerToCommit, sender: self)
        HNewsReadingPile()?.markNewsAsRead(news)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRowAtPoint(location),
            let cell      = tableView.cellForRowAtIndexPath(indexPath) as? HNewsTableViewCell,
            let news = cell.story as? News else { return nil }
        previewingContext.sourceRect = cell.frame
        let safariVC = SafariViewController(URL: news.url)
        safariVC.news = news
        safariVC.showCommentsFor = showCommentsFor
        return safariVC
    }
}

@available(iOS 9.0, *)
class SafariViewController: SFSafariViewController {
    var news: News?
    var showCommentsFor: ((news: News) -> ())?
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        let saveAction = UIPreviewAction(title: "Save", style: .Default) { (previewAction, viewController) in
            guard let news = self.news else { return }
            HNewsReadingPile()?.addNews(news)
            Popover(title: "Saved", mode: .Success).present()
        }
        let commentsAction = UIPreviewAction(title: "Comments", style: .Default) { (previewAction, viewController) in
            guard let news = self.news else { return }
            self.showCommentsFor?(news: news)
        }
        return [saveAction, commentsAction]
    }
}

class FeedViewController: UITableViewController {
    
    private var stories: [News] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var generator: Generator?   = Generator<News>()
    var downloader: Downloader? = Downloader<News>(.Top)
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        tableView.separatorStyle = .None
        tableView.registerClass(HNewsTableViewCell.self, forCellReuseIdentifier: HNewsTableViewCell.ID)
        
        generator?.next(25, downloader?.fetchNextBatch, onFinish: updateDatasource)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            clearsSelectionOnViewWillAppear = false
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Colors.lightGray
        refreshControl?.addTarget(self, action: #selector(FeedViewController.didRefreshFeed(_:)), forControlEvents: .ValueChanged)
        
        if #available(iOS 9.0, *) {
            registerForPreviewingWithDelegate(self, sourceView: tableView)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
    }
    
    func didRefreshFeed(sender: UIRefreshControl) {
        generator?.reset()
        downloader?.reset()
        stories.removeAll()
        generator?.next(25, downloader?.fetchNextBatch, onFinish: updateDatasource)
    }    
}

// MARK: - Paging
extension FeedViewController {
    private func updateDatasource(items: [News]) {
        stories += items
        refreshControl?.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 1) - 5 {
            Dispatcher.async { self.generator?.next(20, self.downloader?.fetchNextBatch, onFinish: self.updateDatasource) }
        }
    }
}

// MARK: - UITableViewDatasource
extension FeedViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(HNewsTableViewCell.ID) as? HNewsTableViewCell else { return UITableViewCell() }
        cell.story = stories[indexPath.row]
        cell.secondTrigger = 0.5
        cell.showCommentsFor = showCommentsFor
        
        // Add to Reading Pile gesture
        cell.setSwipeGestureWithView(HNewsTableViewCell.readingPileImage, color: UIColor.darkGrayColor(), mode: .Exit, state: .State1,
            completionBlock: { (cell, state, mode) -> Void in
                guard let cell = cell as? HNewsTableViewCell else { return }
                guard let news = cell.story as? News         else { return }
                HNewsReadingPile()?.addNews(news)
                self.stories = self.stories.filter { $0.id == news.id ? false : true }
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        })
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let news = stories[indexPath.row]
        guard let updatedNews = HNewsReadingPile()?.markNewsAsRead(news) else { return }
        stories[indexPath.row] = updatedNews
        
        switch Settings.browser {
        case .Safari:
            UIApplication.sharedApplication().openURL(news.url)
        case .SafariInApp:
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(URL: news.url)
                safariVC.view.tintColor = Colors.peach
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    let navContr = UINavigationController(rootViewController: safariVC)
                    splitViewController?.presentViewController(navContr, animated: true, completion: nil)
                } else {
                    navigationController?.navigationBar.hidden = true
                    navigationController?.pushViewController(safariVC, animated: true)
                }
            } else {
                // Fallback on WKWebView with .Webview case
                fallthrough
            }
        case .Webview:
            let webViewVC = HNewsWebViewController()
            webViewVC.url = news.url
            webViewVC.item = news
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let navContr = UINavigationController(rootViewController: webViewVC)
                splitViewController?.presentViewController(navContr, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(webViewVC, animated: true)
            }
        }
    }
}

/// MARK: - Custom tap cell handling for comments
extension FeedViewController {
    func showCommentsFor(news: News) {
        let commentsVC = CommentsViewController()
        commentsVC.news = news
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let navContr = UINavigationController(rootViewController: commentsVC)
            splitViewController?.presentViewController(navContr, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(commentsVC, animated: true)
        }
    }
}
