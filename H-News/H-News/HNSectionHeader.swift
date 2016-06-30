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
            dateCompsFormatter.unitsStyle = .Short
            dateCompsFormatter.zeroFormattingBehavior = .DropAll
            dateCompsFormatter.maximumUnitCount = 1
            date.text = dateCompsFormatter.stringFromTimeInterval(-news.date.timeIntervalSinceNow)
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        title.font = Fonts.title
        title.numberOfLines = 2
        addSubview(title)
        title.snp_makeConstraints { (make) in
            make.left.top.equalTo(8)
            make.right.equalTo(-8)
        }
        
        numComments.font = Fonts.light
        numComments.textColor = Colors.lightGray
        addSubview(numComments)
        numComments.snp_makeConstraints { (make) in
            make.top.equalTo(title.snp_bottom).offset(8)
            make.left.equalTo(8)
        }
        
        score.font = Fonts.light
        score.textColor = Colors.lightGray
        addSubview(score)
        score.snp_makeConstraints { (make) in
            make.top.equalTo(title.snp_bottom).offset(8)
            make.left.equalTo(numComments.snp_right).offset(8)
        }
        
        author.font = Fonts.light
        addSubview(author)
        author.snp_makeConstraints { (make) in
            make.top.equalTo(title.snp_bottom).offset(8)
            make.left.equalTo(score.snp_right).offset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
