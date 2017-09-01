
// TODO: Add a button for submitting a new comment on the relevant News ...
// TODO: When doubled tapped the cell shall expand and reveal a textfield in which you can reply to the comment, et al
// TODO: Add a shortcut to scroll back to top.
// TODO: The view shall present button at the bottom when clicked
class HNewsCommentTableViewCell: UITableViewCell {
    
    fileprivate static let dateCompsFormatter = DateComponentsFormatter()
    static let cellID = "HNewsCommentTableViewCell"
    
    fileprivate let author = UILabel()
    fileprivate let dateLabel = UILabel()
    fileprivate let commentLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Setup views
        commentLabel.numberOfLines = 3
        
        backgroundColor = Colors.lightGray
        author.font = Fonts.light
        dateLabel.font = Fonts.light
        commentLabel.font = Fonts.light
        
        addSubview(author)
        author.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(0).inset(8)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.right.top.equalTo(0).inset(8)
        }
        
        addSubview(commentLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.right.left.equalTo(0).inset(8)
            make.bottom.equalTo(author.snp.top).offset(-8)
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
        }
        
        // Setup DateFormatter
        HNewsCommentTableViewCell.dateCompsFormatter.unitsStyle = .short
        HNewsCommentTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .dropAll
        HNewsCommentTableViewCell.dateCompsFormatter.maximumUnitCount = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            author.text = comment.author
            dateLabel.text? += " ago"
            commentLabel.text = comment.text
            dateLabel.text = HNewsCommentTableViewCell.dateCompsFormatter.string(from: -comment.date.timeIntervalSinceNow)
            
            let doubletapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsCommentTableViewCell.didDoubleTapOnComment))
            doubletapGestureRecog.numberOfTapsRequired = 2
            addGestureRecognizer(doubletapGestureRecog)
            
            setNeedsDisplay() // Renders the cell before it comes into sight
        }
    }
    
    func didSelectCell(_ tableView: UITableView) {
        
    }
    
    func didUnselectCell(_ tableView: UITableView) {
        
    }
    
    fileprivate var textExpanded = false
    
    func didDoubleTapOnComment() {
        let lines = textExpanded ? 3 : 0
        UIView.animate(withDuration: 0.75) { () -> Void in
            self.commentLabel.numberOfLines = lines
            self.contentView.layoutIfNeeded()
        }
        textExpanded = !textExpanded
        // This will recompute the cell's height
        guard let tableView = superview?.superview as? UITableView else { return }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    /// UI that changes dynamically ends up here
    /// Handle indentation: Sets the indentation depending on the offset property of the comment
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        guard let comment = comment else { return }
////        indentationConstraint.constant = CGFloat(comment.offset) * 15
//        self.snp_updateConstraints { (make) in
//            make.leftMargin.equalTo(CGFloat(comment.offset) * 15)
//        }
//        setNeedsDisplay()
//    }
}
