class CommentsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let tableView = CommentsTableViewController()
    private let textField = CommentTextField()
    private let moremenu  = HNewsMoreMenuView()
    
    var news: News? {
        didSet {
            tableView.news = news
            title = news?.title
        }
    }
    
    override func viewDidLoad() {
        let attribs: [String : AnyObject] = [
            NSForegroundColorAttributeName : Colors.peach]
        navigationController?.navigationBar.titleTextAttributes = attribs
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // Add a dismiss button to the webview on a iPad
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .Plain, target: self, action: #selector(CommentsViewController.didTapDismiss(_:)))
        }
        
        view.addSubview(tableView.view)
        addChildViewController(tableView)
        tableView.view.snp_makeConstraints { (make) in
            make.right.left.top.bottom.equalTo(0)
        }
        
        view.addSubview(textField)
        textField.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(view.snp_height).multipliedBy(0.1)
        }
        
        view.bringSubviewToFront(textField)
        
        // TODO: Add the items to the moremenu
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.more, style: .Plain, target: self, action: #selector(CommentsViewController.didTapMore(_:)))
        
        let tapOnParentGestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsWebViewController.didTapOnParent(_:)))
        tapOnParentGestureRecog.delegate = self
        view.addGestureRecognizer(tapOnParentGestureRecog)
    }
    
    func didTapDismiss(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapMore(sender: UIBarButtonItem) {
        // TODO: Present custom more menu
        // TODO: Solve the circle of News -> Comments -> News -> ...
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Called whenever the superview was tapped
    func didTapOnParent(send: UITapGestureRecognizer) {
        if moremenu.shown {
            moremenu.dismiss()
        }
    }
}

class CommentsTableViewController: UITableViewController {
    
    private let generator = Generator<Comment>()
    private let downloader = Downloader<Comment>(APIEndpoint.Comments)
    
    /// The News to load comments for
    var news: News? {
        didSet {
            guard let news = news else { return }
            
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
        tableView = UITableView(frame: view.frame, style: .Grouped)
        tableView.registerClass(HNSectionHeader.self, forHeaderFooterViewReuseIdentifier: HNSectionHeader.ID)
        tableView.registerClass(HNewsCommentTableViewCell.self, forCellReuseIdentifier: HNewsCommentTableViewCell.cellID)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        tableView.allowsSelection = false
        tableView.separatorStyle = .None
    }
}

// MARK: - UITableViewDatasource
extension CommentsTableViewController {
    func updateDatasource(comments: [Comment]) {
        if comments.count == 0 { return } // Fixes the stuttering at the end
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
extension CommentsTableViewController {

    // viewForHeaderInSection will not be called without this method impl.
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HNSectionHeader.height
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HNSectionHeader.ID) as? HNSectionHeader else { return HNSectionHeader() }
        header.news = news
        return header
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(HNewsCommentTableViewCell.cellID) as? HNewsCommentTableViewCell else { return UITableViewCell() }
        guard let comment = comments[indexPath.row] as? Comment else { return UITableViewCell() }
        cell.comment = comment
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? HNewsCommentTableViewCell else { return }
        cell.didSelectCell(tableView)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? HNewsCommentTableViewCell else { return }
        cell.didUnselectCell(tableView)
    }
}

class CommentTextField: UIView {
    
    private let submitBtn = UIButton()
    private let textField = UITextField()
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        
        addSubview(submitBtn)
        submitBtn.snp_makeConstraints { (make) in
            make.right.top.equalTo(0)
            make.size.equalTo(20)
        }
        
        addSubview(textField)
        textField.snp_makeConstraints { (make) in
            make.left.equalTo(superview.snp_left)
            make.right.equalTo(submitBtn.snp_left)
            make.bottom.top.equalTo(0)
        }
    }
}
