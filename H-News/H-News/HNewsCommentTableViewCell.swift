
// TODO: Add a button for submitting a new comment on the relevant News ...
// TODO: When doubled tapped the cell shall expand and reveal a textfield in which you can reply to the comment, et al
// TODO: Add a shortcut to scroll back to top.
// TODO: The view shall present button at the bottom when clicked
// TODO: Show an indicator that the comment can be expanded
import MCSwipeTableViewCell

class HNewsCommentTableViewCell: UITableViewCell {
    
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
        
        // Setup NSDateFormatter
        HNewsCommentTableViewCell.dateCompsFormatter.unitsStyle = .Short
        HNewsCommentTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .DropAll
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
            dateLabel.text = HNewsCommentTableViewCell.dateCompsFormatter.stringFromTimeInterval(-comment.date.timeIntervalSinceNow)
            
            let doubletapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsCommentTableViewCell.didDoubleTapOnComment))
            doubletapGestureRecog.numberOfTapsRequired = 2
            addGestureRecognizer(doubletapGestureRecog)
            
            indentationLevel = 2
            indentationWidth = 50.0
            
            setNeedsDisplay() // Renders the cell before it comes into sight
        }
    }
    
    func didSelectCell(tableView: UITableView) {
        
    }
    
    func didUnselectCell(tableView: UITableView) {
        
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