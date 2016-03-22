
// TODO: When clicked the cell shall expand and reveal a textfield in which you can reply to the comment and 
// TODO: Add a shortcut to scroll back to top.

import MCSwipeTableViewCell

class HNewsCommentTableViewCell: UITableViewCell {
    
    private static let dateCompsFormatter = NSDateComponentsFormatter()
    static let cellID = "HNewsCommentTableViewCell"
    
    @IBOutlet var indentationConstraint: NSLayoutConstraint!
    @IBOutlet var cellHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var author: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            
            author.text = comment.author
            
            // Setup NSDateFormatter
            HNewsCommentTableViewCell.dateCompsFormatter.unitsStyle = .Short
            HNewsCommentTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .DropAll
            HNewsCommentTableViewCell.dateCompsFormatter.maximumUnitCount = 1
            dateLabel.text = HNewsCommentTableViewCell.dateCompsFormatter.stringFromTimeInterval(-comment.date.timeIntervalSinceNow)
            dateLabel.text? += " ago"
            
            commentLabel.text = comment.text
            
            let doubletapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsCommentTableViewCell.didDoubleTapOnComment))
            doubletapGestureRecog.numberOfTapsRequired = 2
            addGestureRecognizer(doubletapGestureRecog)
            
            setNeedsDisplay() // Renders the cell before it comes into sight
        }
    }
    
    private var expanded = false
    
    func didDoubleTapOnComment() {
        let v = expanded ? 3 : 0
        UIView.animateWithDuration(0.75) { () -> Void in
            self.commentLabel.numberOfLines = v
            self.contentView.layoutIfNeeded()
        }
        expanded = !expanded
        // This will recompute the cell's height
        guard let tableView = superview?.superview as? UITableView else { return }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    /// UI that changes dynamically ends up here
    /// Handle indentation: Sets the indentation depending on the offset property of the comment
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let comment = comment else { return }
        indentationConstraint.constant = CGFloat(comment.offset) * 15
        setNeedsDisplay()
    }
}