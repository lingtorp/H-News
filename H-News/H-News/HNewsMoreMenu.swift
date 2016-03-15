struct HNewsMoreMenuItem {
    let title: String
    let subtitle: String
    let image: UIImage
}

class HNewsMoreMenuItemView: UIView {
    
    convenience init(item: HNewsMoreMenuItem) {
        self.init()
        
        // Create title
        let title = UILabel()
        addSubview(title)
        title.text = item.title
        title.snp_makeConstraints { (make) -> Void in
            make.top.right.left.equalTo(8)
        }
        
        // Create subtitle
        let subtitle = UILabel()
        addSubview(subtitle)
        subtitle.text = item.subtitle
        subtitle.snp_makeConstraints { (make) -> Void in
            make.left.right.bottom.equalTo(8)
        }
        
        // Create image
        let image = UIImageView(image: item.image)
        addSubview(image)
        image.snp_makeConstraints { (make) -> Void in
            make.centerWithinMargins.equalTo(10)
        }
    }
}

/// Presents a group of MoreMenu items.
class HNewsMoreMenuView: UIView {
    
    convenience init(items: [HNewsMoreMenuItem]) {
        // Setup frame
        let width = UIScreen().applicationFrame.width
        let height = UIScreen().applicationFrame.height
        let frame = CGRect(x: 0, y: height, width: width, height: height / 3)
        self.init(frame: frame)
        
        // Setup subview - the items
        for item in items {
            let itemview = HNewsMoreMenuItemView(item: item)
            addSubview(itemview)
            itemview.snp_makeConstraints(closure: { (make) in
              make.centerWithinMargins.equalTo(8)
            })
        }
    }
    
    /// Called whenever the view was added in the view that it will present itself in
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        center = superview.center
        print("penis")
    }
}