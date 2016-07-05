class CommentsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let tableView = CommentsTableViewController()
    private let moremenu  = HNewsMoreMenuView()
    private let addBtn    = HNMenuButtonView()
    
    var news: News? {
        didSet {
            tableView.news = news
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
        
        view.addSubview(addBtn)
        addBtn.snp_makeConstraints { (make) in
            make.right.equalTo(-16)
            make.bottom.equalTo(view.snp_bottom).offset(-64)
            make.size.equalTo(view.snp_width).multipliedBy(0.12)
        }
        addBtn.didTapOnButton = didTapPlusButton
        
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
    
    private weak var commentView: HNCommentView?
    
    func didTapPlusButton(sender: HNMenuButtonView, selected: Bool) {
        if selected {
            guard let commentView = commentView else { return }
            Animations.fadeOut(commentView) {
                commentView.removeFromSuperview()
            }
        } else {
            let newCommentView = HNCommentView()
            view.addSubview(newCommentView)
            newCommentView.snp_makeConstraints { (make) in
                make.top.equalTo(32)
                make.bottom.equalTo(-256) // FIXME: Height of current displayed keyboard
                make.left.equalTo(32)
                make.right.equalTo(-32)
            }
            Animations.fadeIn(newCommentView)
            commentView = newCommentView
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
            comments.count == 0 ? showNoContentView(true) : showNoContentView(false)
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
        view.addSubview(noContentView)
        noContentView.text = "No content to show."
        noContentView.textColor = Colors.peach
        noContentView.snp_makeConstraints { (make) in
            make.right.bottom.equalTo(-8)
        }
    }
    
    private var noContentView = UILabel()
    
    private func showNoContentView(show: Bool) {
        show ? print("Showing!") : print("Hiding!")
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
        cell.comment = comments[indexPath.row]
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

class HNCommentView: UIView {
    
    private let textLabel  = UILabel()
    private let submitBtn  = UIImageView()
    private let dismissBtn = UIImageView()
    private let textField  = UITextView()
    
    override func didMoveToSuperview() {
        backgroundColor = Colors.lightGray
        
        textLabel.textColor = Colors.peach
        textLabel.font = Fonts.title
        textLabel.text = "Submit a comment"
        addSubview(textLabel)
        textLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(0)
            make.top.equalTo(8)
        }
        
        let submitTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(didTapSubmit(_:)))
        submitBtn.image = Icons.accept.imageWithRenderingMode(.AlwaysTemplate)
        submitBtn.tintColor = Colors.peach
        submitBtn.addGestureRecognizer(submitTapGestureRecog)
        submitBtn.userInteractionEnabled = true
        addSubview(submitBtn)
        submitBtn.snp_makeConstraints { (make) in
            make.right.equalTo(-8)
            make.top.equalTo(8)
            make.height.equalTo(textLabel)
        }
        
        let dismissTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(didTapDismiss(_:)))
        dismissBtn.image = Icons.dismiss.imageWithRenderingMode(.AlwaysTemplate)
        dismissBtn.tintColor = Colors.peach
        dismissBtn.addGestureRecognizer(dismissTapGestureRecog)
        dismissBtn.userInteractionEnabled = true
        addSubview(dismissBtn)
        dismissBtn.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.top.equalTo(8)
            make.height.equalTo(textLabel)
        }
        
        textField.font = Fonts.title
        textField.backgroundColor = Colors.gray
        textField.textColor = Colors.lightGray
        textField.dataDetectorTypes = .All
        textField.becomeFirstResponder()
        addSubview(textField)
        textField.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(textLabel.snp_bottom).offset(8)
            make.bottom.equalTo(-8)
        }
    }
    
    func didTapDismiss(sender: UITapGestureRecognizer) {
        Animations.fadeOut(self) {
            self.removeFromSuperview()
        }
    }
    
    func didTapSubmit(sender: UITapGestureRecognizer) {
        guard Settings.loggedIn else {
            Popover(.LoginRequired).present()
            Animations.shake(self)
            return
        }
        Animations.fadeOut(self) {
            self.removeFromSuperview()
        }
    }
}
