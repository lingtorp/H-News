
import UIKit
import RealmSwift

class DetailViewController: UITableViewController {
    
    private var notiToken: NotificationToken?
    private var news: [News] = HNewsReadingPile()?.fetchAllNews(read: false) ?? []
    private var archivednews = HNewsReadingPile()?.fetchAllNews(read: true) ?? []
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        // Observe Realm Notifications
        notiToken = HNewsReadingPile()?.realm?.addNotificationBlock { notification, realm in
            self.news = HNewsReadingPile()?.fetchAllNews(read: false) ?? []
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            self.archivednews = HNewsReadingPile()?.fetchAllNews(read: true) ?? []
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        }
        tableView.registerClass(HNewsTableViewCell.self, forCellReuseIdentifier: HNewsTableViewCell.ID)
        
        // Trash items
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.trash, style: .Plain, target: self, action: #selector(DetailViewController.didPressTrash))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
    }
    
    func didPressTrash() {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Unread", style: .Destructive, handler: { (UIAlertAction) -> Void in
            HNewsReadingPile()?.removeAllNews(read: false)
        }))
        alert.addAction(UIAlertAction(title: "Archived", style: .Destructive, handler: { (UIAlertAction) -> Void in
            HNewsReadingPile()?.removeAllNews(read: true)
        }))
        alert.addAction(UIAlertAction(title: "Unread + Archived", style: .Destructive, handler: { (UIAlertAction) -> Void in
            HNewsReadingPile()?.removeAllNews()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (UIAlertAction) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDatasource
extension DetailViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(HNewsTableViewCell.ID) as? HNewsTableViewCell else { return UITableViewCell() }
        
        switch indexPath.section {
        case 0:
            cell.story = news[indexPath.row]
        case 1:
            cell.story = archivednews[indexPath.row]
        default: break
        }
        
        cell.secondTrigger = 0.5
        cell.showCommentsFor = showCommentsFor
        
        // Remove from Reading Pile gesture
        cell.setSwipeGestureWithView(HNewsTableViewCell.trashImage, color: UIColor.darkGrayColor(), mode: .Exit, state: .State1,
            completionBlock: { (cell, state, mode) -> Void in
                guard let cell = cell as? HNewsTableViewCell else { return }
                guard let news = cell.story as? News         else { return }
                HNewsReadingPile()?.removeNews(news.id)
        })
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return news.count
        case 1:
            return archivednews.count
        default: return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Unread"
        case 1:
            return "Archived"
        default: return ""
        }
    }
}

// MARK: - UITableViewDelegate
extension DetailViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? HNewsTableViewCell else { return }
        guard let news = cell.story as? News else { return }
        if let downloadedHTML = HNewsReadingPile()?.html(news) {
            HNewsReadingPile()?.markNewsAsRead(news)
            let webViewVC = HNewsWebViewController()
            webViewVC.data = downloadedHTML // TODO: Downloaded data not working
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                // Present webviews modally on iPads
                let navContr = UINavigationController(rootViewController: webViewVC)
                splitViewController?.presentViewController(navContr, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(webViewVC, animated: true)
            }
        }
    }
}

/// MARK: - Custom tap cell handling for comments
extension DetailViewController {
    func showCommentsFor(news: News) {
        let commentsVC = HNewsCommentsViewController()
        commentsVC.news = news
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let navContr = UINavigationController(rootViewController: commentsVC)
            splitViewController?.presentViewController(navContr, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(commentsVC, animated: true)
        }
    }
}