import UIKit

class MasterViewController: UITableViewController {
    
    private var stories: [News] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let newsGenerator  = Generator<News>()
    private let newsDownloader = Downloader<News>(APIEndpoint.News) 
    
    override func viewDidLoad() {        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        navigationController?.navigationBar.tintColor = Colors.peach
        navigationController?.navigationBar.barTintColor = UIColor.darkGrayColor()
        tableView.backgroundColor = UIColor.darkGrayColor()
        
        tableView.registerNib(UINib(nibName: "HNewsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: HNewsTableViewCell.cellID)
        newsGenerator.next(25, newsDownloader.fetchNextBatch, onFinish: updateDatasource)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            clearsSelectionOnViewWillAppear = false
            preferredContentSize = CGSize(width: 320.0, height: 600.0)
            navigationItem.rightBarButtonItem = nil // Hide detail btn on ipads
        }
        
        // Settings
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.settings, style: .Plain, target: self, action: "didTapSettings")
        
        // Reading list / Detail
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.readingList, style: .Plain, target: self, action: "didTapDetail")
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Colors.white
        refreshControl?.addTarget(self, action: "didRefreshFeed:", forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
    }
    
    func didRefreshFeed(sender: UIRefreshControl) {
        newsGenerator.reset()
        newsDownloader.reset()
        stories.removeAll()
        newsGenerator.next(25, newsDownloader.fetchNextBatch, onFinish: updateDatasource)
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

// MARK: - Paging
extension MasterViewController {
    private func updateDatasource(items: [News]) {
        stories += items
        refreshControl?.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 1) - 5 {
            Dispatcher.async { self.newsGenerator.next(15, self.newsDownloader.fetchNextBatch, onFinish: self.updateDatasource) }
        }
    }
}

// MARK: - UITableViewDatasource
extension MasterViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(HNewsTableViewCell.cellID) as? HNewsTableViewCell else { return UITableViewCell() }
        guard let news = stories[indexPath.row] as? News else { return UITableViewCell() }
        
        cell.story = news
        cell.secondTrigger = 0.5
        cell.showCommentsFor = showCommentsFor
        
        // Add to Reading Pile gesture
        cell.setSwipeGestureWithView(HNewsTableViewCell.readingPileImage, color: UIColor.darkGrayColor(), mode: .Exit, state: .State1,
            completionBlock: { (cell, state, mode) -> Void in
                guard let cell = cell as? HNewsTableViewCell else { return }
                guard let news = cell.story as? News         else { return }
                HNewsReadingPile()?.addNews(news)
                Dispatcher.async { self.downloadArticle(news.url, newsID: news.id) }
                self.stories = self.stories.filter { $0.id == news.id ? false : true }
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        })
        
        return cell
    }
    
    private func downloadArticle(url: NSURL, newsID: Int) {
        let request = NSMutableURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, err) -> Void in
            guard let data = data else { return }
            HNewsReadingPile()?.save(data, newsID: newsID)
        }
        task.resume()
    }
}

// MARK: - UITableViewDelegate
extension MasterViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let news = stories[indexPath.row] as? News else { return }
        guard let updatedNews = HNewsReadingPile()?.markNewsAsRead(news) else { return }
        stories[indexPath.row] = updatedNews
        
        let webViewVC = HNewsWebViewController()
        webViewVC.url = news.url
        webViewVC.item = news
        let navContr = UINavigationController(rootViewController: webViewVC)
        navigationController?.pushViewController(navContr, animated: true)
    }
}

/// MARK: - Custom tap cell handling for comments
extension MasterViewController {
    func showCommentsFor(news: News) {
        let commentsVC = HNewsCommentsViewController()
        commentsVC.news = news
        let navContr = UINavigationController(rootViewController: commentsVC)
        navigationController?.pushViewController(navContr, animated: true)
    }
}
