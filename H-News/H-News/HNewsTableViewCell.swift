import UIKit
import MCSwipeTableViewCell

class HNewsTableViewCell: MCSwipeTableViewCell {
    
    static let ID = "HNewsTableViewCell"
    
    static let trashImage       = UIImageView(image: Icons.trash)
    static let readingPileImage = UIImageView(image: Icons.save)
    static let upvoteImage      = UIImageView(image: Icons.upvote)
    
    private static let dateCompsFormatter = NSDateComponentsFormatter()
    
    private let title         = UILabel()
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
            make.top.greaterThanOrEqualTo(score.snp_bottom).offset(-4)
            make.bottom.equalTo(0).offset(-8)
            make.right.equalTo(0).offset(-8)
        }
        
        // Setup NSDateFormatter
        HNewsTableViewCell.dateCompsFormatter.unitsStyle = .Short
        HNewsTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .DropAll
        HNewsTableViewCell.dateCompsFormatter.maximumUnitCount = 1
        
        let gestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsTableViewCell.didClickOnComment(_:)))
        title.userInteractionEnabled = true
        title.addGestureRecognizer(gestureRecog)
        
        // Set selection color theme
        let view = UIView()
        view.backgroundColor = Colors.peach
        selectedBackgroundView = view
        defaultColor = Colors.gray
        
        contentView.backgroundColor = Colors.gray
        
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
            title.text  = story.title
            author.text = story.author
            time.text   = HNewsTableViewCell.dateCompsFormatter.stringFromTimeInterval(-story.date.timeIntervalSinceNow)
            
            if story.read {
                title.textColor = Colors.lightGray
            } else { // Return to default since UITableView is reusing the cells
                title.textColor = Colors.white
            }
            
            switch story {
            case let news as News:
                url.text   = news.url.host
                if news.score > 0 {
                    score.text = "\(news.score)"
                } else {
                    score.hidden = true
                }
            default: break
            }
            
            setNeedsDisplay()
        }
    }
    
    /// Tap gesture callback
    func didClickOnComment(sender: UITapGestureRecognizer) {
        guard let news = story as? News else { return }
        if let callback = showCommentsFor {
            callback(news: news)
        }
    }
}