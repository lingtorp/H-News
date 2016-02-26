
class HNewsCommentsViewController: UITableViewController {
    
    private let generator = Generator<Comment>()
    private let downloader = Downloader<Comment>(APIEndpoint.Comments)
    
    /// The News to load comments for
    var news: News? {
        didSet {
            guard let news = news else { return }
            title = news.title
            // Begin to load the comments of the News.
            generator.reset()
            downloader.reset()
            downloader.extraParams = ["newsid":news.id]
            generator.next(15, downloader.fetchNextBatch, onFinish: updateDatasource)
        }
    }
    
    private var comments: [Comment] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        tableView.registerNib(UINib(nibName: "HNewsCommentTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: HNewsCommentTableViewCell.cellID) // TODO: Register class 
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
    }
    
    @IBAction func onMore(sender: UIBarButtonItem) {
        // TODO: Present custom more menu
    }
}

// MARK: - UITableViewDatasource
extension HNewsCommentsViewController {
    func updateDatasource(comments: [Comment]) {
        if comments.count == 0 { return } // (?) Fixes the stuttering
        self.comments += comments
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 1) - 5 {
            Dispatcher.async { self.generator.next(15, self.downloader.fetchNextBatch, onFinish: self.updateDatasource) }
        }
    }
}

// MARK: - UITableViewDelegate
extension HNewsCommentsViewController {    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(HNewsCommentTableViewCell.cellID) as? HNewsCommentTableViewCell else { return UITableViewCell() }
        guard let comment = comments[indexPath.row] as? Comment else { return UITableViewCell() }
        cell.comment = comment
        return cell
    }
}