
import UIKit
import RealmSwift

class DetailViewController: UITableViewController {
    
    fileprivate var notiToken: NotificationToken?
    fileprivate var news: [News] = HNewsReadingPile()?.fetchAllNews(read: false) ?? []
    fileprivate var archivednews = HNewsReadingPile()?.fetchAllNews(read: true) ?? []
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        // Observe Realm Notifications
        notiToken = HNewsReadingPile()?.realm?.addNotificationBlock { notification, realm in
            self.news = HNewsReadingPile()?.fetchAllNews(read: false) ?? []
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.archivednews = HNewsReadingPile()?.fetchAllNews(read: true) ?? []
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
        tableView.register(UINib(nibName: "HNewsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: HNewsTableViewCell.cellID) // TODO: Register class
        
        // Trash items
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.trash, style: .plain, target: self, action: #selector(DetailViewController.didPressTrash))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
    }
    
    func didPressTrash() {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Unread", style: .destructive, handler: { (UIAlertAction) -> Void in
            HNewsReadingPile()?.removeAllNews(read: false)
        }))
        alert.addAction(UIAlertAction(title: "Archived", style: .destructive, handler: { (UIAlertAction) -> Void in
            HNewsReadingPile()?.removeAllNews(read: true)
        }))
        alert.addAction(UIAlertAction(title: "Unread + Archived", style: .destructive, handler: { (UIAlertAction) -> Void in
            HNewsReadingPile()?.removeAllNews()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDatasource
extension DetailViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HNewsTableViewCell.cellID) as? HNewsTableViewCell else { return UITableViewCell() }
        
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
        cell.setSwipeGestureWith(HNewsTableViewCell.trashImage, color: UIColor.darkGray, mode: .exit, state: .state1,
            completionBlock: { (cell, state, mode) -> Void in
                guard let cell = cell as? HNewsTableViewCell else { return }
                guard let news = cell.story as? News         else { return }
                HNewsReadingPile()?.removeNews(news.id)
        })
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return news.count
        case 1:
            return archivednews.count
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? HNewsTableViewCell else { return }
        guard let news = cell.story as? News else { return }
        if let downloadedHTML = HNewsReadingPile()?.html(news) {
            HNewsReadingPile()?.markNewsAsRead(news)
            let webViewVC = HNewsWebViewController()
            webViewVC.data = downloadedHTML // TODO: Downloaded data not working
            if UIDevice.current.userInterfaceIdiom == .pad {
                // Present webviews modally on iPads
                let navContr = UINavigationController(rootViewController: webViewVC)
                splitViewController?.present(navContr, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(webViewVC, animated: true)
            }
        }
    }
}

/// MARK: - Custom tap cell handling for comments
extension DetailViewController {
    func showCommentsFor(_ news: News) {
        let commentsVC = HNewsCommentsViewController()
        commentsVC.news = news
        if UIDevice.current.userInterfaceIdiom == .pad {
            let navContr = UINavigationController(rootViewController: commentsVC)
            splitViewController?.present(navContr, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(commentsVC, animated: true)
        }
    }
}
