
import UIKit
import MCSwipeTableViewCell

class HNewsTableViewCell: MCSwipeTableViewCell {
    
    private static let defaultTextColor = UIColor(red: 214, green: 214, blue: 214, alpha: 0.8)
    
    static let cellID = "Cell"
    
    static let trashImage       = UIImageView(image: UIImage(named: "UIButtonBarTrash"))
    static let readingPileImage = UIImageView(image: UIImage(named: "reading_list_icon"))
    static let upvoteImage      = UIImageView(image: UIImage(named: "upvote_arrow"))
    
    private static let dateCompsFormatter = NSDateComponentsFormatter()
    
    @IBOutlet var title: UILabel!
    @IBOutlet var commentsCount: UILabel!
    @IBOutlet var score: UILabel!
    @IBOutlet var url: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var time: UILabel!
    
    // Callback property called when the user clicks to see the comments for a News item
    var showCommentsFor: ((news: News) -> ())?
    
    var story: Story? {
        didSet {
            guard let story = story else { return }
    
            // Set selection color theme
            let view = UIView()
            view.backgroundColor = UIColor.orangeColor()
            selectedBackgroundView = view
            defaultColor = UIColor.darkGrayColor()
            
            // Setup NSDateFormatter
            HNewsTableViewCell.dateCompsFormatter.unitsStyle = .Short
            HNewsTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .DropAll
            HNewsTableViewCell.dateCompsFormatter.maximumUnitCount = 1

            title.text         = story.title
            commentsCount.text = "\(story.comments)"
            author.text        = story.author
            time.text          = HNewsTableViewCell.dateCompsFormatter.stringFromTimeInterval(-story.date.timeIntervalSinceNow)
            
            if story.read {
                title.textColor = UIColor.grayColor()
            } else { // Return to default since UITableView is reusing the cells
                title.textColor = HNewsTableViewCell.defaultTextColor
            }
            
            if let news = story as? News {
                url.text   = news.url.host
                score.text = "\(news.score)"
            }
            
            let gestureRecog = UITapGestureRecognizer(target: self, action: "didClickOnComment:")
            title.userInteractionEnabled = true
            title.addGestureRecognizer(gestureRecog)

            setNeedsDisplay()
        }
    }
    
    /// Tap gesture callback
    func didClickOnComment(sender: AnyObject) {
        guard let news = story as? News else { return }
        if let callback = showCommentsFor {
            callback(news: news)
        }
    }
}