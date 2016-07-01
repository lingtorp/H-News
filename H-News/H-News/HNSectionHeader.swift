import UIKit

class HNSectionHeader: UITableViewHeaderFooterView {
    
    static let ID = "HNSectionHeader"
    static let height: CGFloat = 80.0
    
    private let title       = UILabel()
    private let author      = UILabel()
    private let date        = UILabel()
    private let numComments = UILabel()
    private let score       = UILabel()
    
    var news: News? {
        didSet {
            guard let news = news else { return }
            
            title.text = news.title
            numComments.text = "\(news.comments) comments"
            author.text = " by \(news.author)"
            score.text = "\(news.score) points"
            
            // Setup NSDateFormatter
            let dateCompsFormatter = NSDateComponentsFormatter()
            dateCompsFormatter.unitsStyle = .Abbreviated
            dateCompsFormatter.zeroFormattingBehavior = .DropAll
            dateCompsFormatter.maximumUnitCount = 1
            date.text = dateCompsFormatter.stringFromTimeInterval(-news.date.timeIntervalSinceNow)! + " ago"
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(author)
        addSubview(date)
        addSubview(score)
        addSubview(numComments)
        addSubview(title)
        
        title.font = Fonts.title
        title.textColor = Colors.peach
        title.numberOfLines = 2
        title.snp_makeConstraints { (make) in
            make.left.top.equalTo(8)
            make.right.equalTo(-8)
        }
        
        numComments.font = Fonts.light
        numComments.textColor = Colors.lightGray
        numComments.snp_makeConstraints { (make) in
            make.top.equalTo(title.snp_bottom).offset(8)
            make.left.equalTo(8)
        }
        
        score.font = Fonts.light
        score.textColor = Colors.lightGray
        score.snp_makeConstraints { (make) in
            make.top.equalTo(title.snp_bottom).offset(8)
            make.left.equalTo(numComments.snp_right).offset(8)
        }
        
        author.font = Fonts.light
        author.textColor = Colors.lightGray
        author.snp_makeConstraints { (make) in
            make.top.equalTo(title.snp_bottom).offset(8)
            make.left.equalTo(score.snp_right).offset(8)
        }
        
        date.font = Fonts.light
        date.textColor = Colors.lightGray
        date.snp_makeConstraints { (make) in
            make.top.equalTo(title.snp_bottom).offset(8)
            make.left.equalTo(author.snp_right).offset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
