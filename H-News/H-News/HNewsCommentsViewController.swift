
class HNewsCommentsViewController: UITableViewController {
    
    fileprivate let generator = Generator<Comment>()
    fileprivate let downloader = Downloader<Comment>(APIEndpoint.Comments)
    
    /// The News to load comments for
    var news: News? {
        didSet {
            guard let news = news else { return }
            title = news.title
            // Begin to load the comments of the News.
            generator.reset()
            downloader.reset()
            downloader.extraParams = ["newsid":news.id as AnyObject]
            generator.next(15, downloader.fetchNextBatch, onFinish: updateDatasource)
        }
    }
    
    fileprivate var comments: [Comment] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        tableView.register(HNewsCommentTableViewCell.self, forCellReuseIdentifier: HNewsCommentTableViewCell.cellID)
//        tableView.registerNib(UINib(nibName: "HNewsCommentTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: HNewsCommentTableViewCell.cellID) // TODO: Register class 
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Add a dismiss button to the webview on a iPad
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .plain, target: self, action: #selector(HNewsCommentsViewController.didTapDismiss(_:)))
        }
    }
    
    func didTapDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onMore(_ sender: UIBarButtonItem) {
        // TODO: Present custom more menu
        // TODO: Solve the circle of News -> Comments -> News -> ...
    }
}

// MARK: - UITableViewDatasource
extension HNewsCommentsViewController {
    func updateDatasource(_ comments: [Comment]) {
        if comments.count == 0 { return } // (?) Fixes the stuttering
        self.comments += comments
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 1) - 5 {
            Dispatcher.async { self.generator.next(15, self.downloader.fetchNextBatch, onFinish: self.updateDatasource) }
        }
    }
}

// MARK: - UITableViewDelegate
extension HNewsCommentsViewController {    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HNewsCommentTableViewCell.cellID) as? HNewsCommentTableViewCell else { return UITableViewCell() }
        guard let comment = comments[indexPath.row] as? Comment else { return UITableViewCell() }
        cell.comment = comment
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? HNewsCommentTableViewCell else { return }
        cell.didSelectCell(tableView)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? HNewsCommentTableViewCell else { return }
        cell.didUnselectCell(tableView)
    }
}
