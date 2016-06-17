
import UIKit
import MCSwipeTableViewCell

class HNewsTableViewCell: MCSwipeTableViewCell {
    
    static let ID = "HNewsTableViewCell"
    
    static let trashImage       = UIImageView(image: Icons.trash)
    static let readingPileImage = UIImageView(image: Icons.readingList)
    static let upvoteImage      = UIImageView(image: Icons.upvote)
    
    private static let dateCompsFormatter = NSDateComponentsFormatter()
    
    private let title         = UILabel()
    private let commentsCount = UILabel()
    private let score         = UILabel()
    private let url           = UILabel()
    private let author        = UILabel()
    private let time          = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        score.textColor = Colors.peach
        score.adjustsFontSizeToFitWidth = true
        score.baselineAdjustment = .AlignCenters
        addSubview(score)
        score.snp_makeConstraints { (make) in
            make.top.equalTo(0).offset(8)
            make.right.equalTo(0).offset(-10)
        }
        
        title.numberOfLines = 2
        title.font = Fonts.title
        title.adjustsFontSizeToFitWidth = true
        addSubview(title)
        title.snp_makeConstraints { (make) in
            make.left.equalTo(snp_left).offset(8)
            make.top.equalTo(snp_left).offset(8)
            make.right.lessThanOrEqualTo(score.snp_left).offset(-6)
        }
        
        url.textColor = Colors.lightGray
        url.font = Fonts.light
        addSubview(url)
        url.snp_makeConstraints { (make) in
            make.left.equalTo(snp_left).offset(8)
            make.top.equalTo(title.snp_bottom).offset(8)
            make.bottom.equalTo(0).offset(-8)
        }
        
        time.textColor = Colors.lightGray
        time.font = Fonts.light
        addSubview(time)
        time.snp_makeConstraints { (make) in
            make.bottom.equalTo(0).offset(-8)
            make.right.equalTo(0).offset(-8)
        }
        
=======
        commentsCount.textColor = Colors.peach
        addSubview(commentsCount)
        commentsCount.snp_makeConstraints { (make) in
            make.right.top.equalTo(self.snp_right).offset(8)
        }
        
        title.numberOfLines = 2
        addSubview(title)
        title.snp_makeConstraints { (make) in
            make.left.top.equalTo(self.snp_left).offset(8)
            make.right.equalTo(commentsCount.snp_left).offset(8)
        }
        
        url.textColor = Colors.lightGray
        addSubview(url)
        url.snp_makeConstraints { (make) in
            make.left.bottom.equalTo(0).offset(8)
            make.top.equalTo(title.snp_bottom).offset(8)
        }

>>>>>>> 158d943f151cfff489dcbaf446a7e6f8e2829505
        // do the initial layout
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
            
            contentView.backgroundColor = UIColor.darkGrayColor()
            commentsCount.textColor = Colors.peach
            
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
                title.textColor = Colors.white
            }
            
            if let news = story as? News {
                url.text   = news.url.host
                score.text = "\(news.score)"
            }
            
            let gestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsTableViewCell.didClickOnComment(_:)))
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