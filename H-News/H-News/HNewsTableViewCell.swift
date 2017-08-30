
import UIKit
import MCSwipeTableViewCell

class HNewsTableViewCell: MCSwipeTableViewCell {
    
    static let cellID = "Cell"
    
    static let trashImage       = UIImageView(image: UIImage(named: "UIButtonBarTrash"))
    static let readingPileImage = UIImageView(image: UIImage(named: "reading_list_icon"))
    static let upvoteImage      = UIImageView(image: UIImage(named: "upvote_arrow"))
    
    fileprivate static let dateCompsFormatter = DateComponentsFormatter()
    
    @IBOutlet var title: UILabel!
    @IBOutlet var commentsCount: UILabel!
    @IBOutlet var score: UILabel!
    @IBOutlet var url: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var time: UILabel!
    
    // Callback property called when the user clicks to see the comments for a News item
    var showCommentsFor: ((_ news: News) -> ())?
    
    var story: Story? {
        didSet {
            guard let story = story else { return }
    
            // Set selection color theme
            let view = UIView()
            view.backgroundColor = UIColor.orange
            selectedBackgroundView = view
            defaultColor = UIColor.darkGray
            
            contentView.backgroundColor = UIColor.darkGray
            commentsCount.textColor = Colors.peach
            
            // Setup DateFormatter
            HNewsTableViewCell.dateCompsFormatter.unitsStyle = .short
            HNewsTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .dropAll
            HNewsTableViewCell.dateCompsFormatter.maximumUnitCount = 1

            title.text         = story.title
            commentsCount.text = "\(story.comments)"
            author.text        = story.author
            time.text          = HNewsTableViewCell.dateCompsFormatter.string(from: -story.date.timeIntervalSinceNow)
            
            if story.read {
                title.textColor = UIColor.gray
            } else { // Return to default since UITableView is reusing the cells
                title.textColor = Colors.white
            }
            
            if let news = story as? News {
                url.text   = news.url.host
                score.text = "\(news.score)"
            }
            
            let gestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsTableViewCell.didClickOnComment(_:)))
            title.isUserInteractionEnabled = true
            title.addGestureRecognizer(gestureRecog)

            setNeedsDisplay()
        }
    }
    
    /// Tap gesture callback
    func didClickOnComment(_ sender: AnyObject) {
        guard let news = story as? News else { return }
        if let callback = showCommentsFor {
            callback(news)
        }
    }
}
