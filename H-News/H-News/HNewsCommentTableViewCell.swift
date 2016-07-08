import MCSwipeTableViewCell

class HNewsCommentTableViewCell: MCSwipeTableViewCell {
    
    private static let dataDetector = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
    private static let dateCompsFormatter = NSDateComponentsFormatter()
    static let cellID = "HNewsCommentTableViewCell"
    
    private let author       = UILabel()
    private let dateLabel    = UILabel()
    private let commentLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Setup views
        commentLabel.numberOfLines = 3
        backgroundColor = Colors.gray

        author.font = Fonts.title
        author.textColor = Colors.white
        contentView.addSubview(author)
        author.snp_makeConstraints { (make) in
            make.left.bottom.equalTo(0).inset(8)
        }
        
        dateLabel.font = Fonts.light
        dateLabel.textColor = Colors.lightGray
        contentView.addSubview(dateLabel)
        dateLabel.snp_makeConstraints { (make) in
            make.right.top.equalTo(0).inset(8)
        }
        
        commentLabel.font = Fonts.light
        commentLabel.textColor = Colors.white
        contentView.addSubview(commentLabel)
        commentLabel.snp_makeConstraints { (make) in
            make.right.left.equalTo(0).inset(8)
            make.bottom.equalTo(author.snp_top).offset(-8)
            make.top.equalTo(dateLabel.snp_bottom).offset(8)
        }
        
        contentView.snp_updateConstraints { (make) in
            make.leftMargin.equalTo(Int(indentationWidth) * indentationLevel)
            make.rightMargin.equalTo(0)
        }
        
        // Setup NSDateFormatter
        HNewsCommentTableViewCell.dateCompsFormatter.unitsStyle = .Short
        HNewsCommentTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .DropAll
        HNewsCommentTableViewCell.dateCompsFormatter.maximumUnitCount = 1
        
        let doubletapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsCommentTableViewCell.didDoubleTapOnComment))
        doubletapGestureRecog.numberOfTapsRequired = 2
        addGestureRecognizer(doubletapGestureRecog)
        
        let longpressGestureRecog = UILongPressGestureRecognizer(target: self, action: #selector(HNewsCommentTableViewCell.didLongPressOnComment(_:)))
        addGestureRecognizer(longpressGestureRecog)
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            identityURLsIn(comment.text) { (result, urls) in
                self.commentLabel.attributedText = result
                self.urlsInComment = urls
            }
            commentLabel.text = comment.text // Add initial text for sizing purposes
            author.text = comment.author
            dateLabel.text? += " ago"
            dateLabel.text = HNewsCommentTableViewCell.dateCompsFormatter.stringFromTimeInterval(-comment.date.timeIntervalSinceNow)
            indentationLevel = comment.offset
            indentationWidth = 15.0
            setNeedsDisplay() // Renders the cell before it comes into sight
        }
    }
    
    private func identityURLsIn(string: String, completed: (result: NSAttributedString, urls: [String]) -> ()) {
        Dispatcher.async {
            var urls: [String] = []
            let URLattributes: [String : AnyObject] = [
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
            ]
            let attributedString = NSMutableAttributedString(string: string)
            HNewsCommentTableViewCell.dataDetector.enumerateMatchesInString(string, options: [], range: NSMakeRange(0, string.characters.count))    { (result, _, _) in
                guard let url = result?.URL else { return }
                let urlRange = attributedString.mutableString.rangeOfString(url.absoluteString)
                attributedString.addAttributes(URLattributes, range: urlRange)
                urls.append(url.absoluteString)
            }
            Dispatcher.main({ completed(result: attributedString, urls: urls) })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.snp_updateConstraints { (make) in
            make.leftMargin.equalTo(Int(indentationWidth) * indentationLevel)
        }
    }
    
    private var urlsInComment: [String] = []
    
    func didLongPressOnComment(sender: UILongPressGestureRecognizer) {
        guard urlsInComment.count > 0 else { return }
        let alertContr = UIAlertController(title: "URLs", message: "Open a link in Safari", preferredStyle: .ActionSheet)
        for url in urlsInComment {
            let action = UIAlertAction(title: url, style: .Default, handler: { (action) in
                guard let URL = NSURL(string: url) else { return }
                UIApplication.sharedApplication().openURL(URL)
            })
            alertContr.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertContr.addAction(cancelAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertContr, animated: true, completion: nil)
    }
    
    private var textExpanded = false
    
    func didDoubleTapOnComment() {
        let lines = textExpanded ? 3 : 0
        UIView.animateWithDuration(0.5) { () -> Void in
            self.commentLabel.numberOfLines = lines
            self.contentView.layoutIfNeeded()
        }
        textExpanded = !textExpanded
        // This will recompute the cell's height
        guard let tableView = superview?.superview as? UITableView else { return }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

class TableViewCellMenu: UIView {
    
    private let buttons = [UIButton(), UIButton()]
    
    override func didMoveToSuperview() {
        for button in buttons {
            button.titleLabel?.text = "I AM A BUTTON"
            addSubview(button)
            button.snp_makeConstraints(closure: { (make) in
                make.left.top.equalTo(0)
                make.size.equalTo(20)
                make.bottom.equalTo(0)
            })
        }
    }
}