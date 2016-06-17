import UIKit

class HNSectionHeader: UITableViewHeaderFooterView {
    
    static let ID = "HNSectionHeader"
    static let height: CGFloat = 100.0
    
    private let title       = UILabel()
    private let author      = UILabel()
    private let date        = UILabel()
    private let numComments = UILabel()
    private let score       = UILabel()
    
    var news: News? {
        didSet {
            guard let news = news else { return }
            
            title.text = news.title
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        title.font = Fonts.title
        contentView.addSubview(title)
        title.snp_makeConstraints { (make) in
            make.left.top.equalTo(0).offset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
