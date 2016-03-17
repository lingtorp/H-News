struct HNewsMoreMenuItem {
    let title: String
    let image: UIImage
    let callback: () -> Void
}

class HNewsMoreMenuItemView: UIView {
    
    var item: HNewsMoreMenuItem?  {
        didSet {
            guard let item = item else { return }
            backgroundColor = Colors.gray
            let textColor = Colors.white
            
            // Create title
            let title = UILabel()
            addSubview(title)
            title.text = item.title
            title.textAlignment = .Center
            title.textColor = textColor
            title.snp_makeConstraints { (make) -> Void in
                make.bottom.equalTo(0)
                make.right.left.equalTo(0)
            }
            
            // Create image - with tintcolor shining through (.AlwaysTemplate)
            let image = UIImageView(image: item.image.imageWithRenderingMode(.AlwaysTemplate))
            addSubview(image)
            image.tintColor = textColor
            image.snp_makeConstraints { (make) -> Void in
                make.center.equalTo(0)
                make.bottom.equalTo(title.snp_top)
            }
            
            let tapGestureRecog = UITapGestureRecognizer(target: self, action: "didTapOnItem:")
            addGestureRecognizer(tapGestureRecog)
        }
    }
    
    /// Call the item's callback
    func didTapOnItem(sender: UITapGestureRecognizer) {
        guard let item = item else { return }
        item.callback()
    }
}

/// MoreMenu main class.
class HNewsMoreMenuView: UIView {
    
    private let itemviews: [HNewsMoreMenuItemView] = [
        HNewsMoreMenuItemView(), HNewsMoreMenuItemView(),
        HNewsMoreMenuItemView(), HNewsMoreMenuItemView()
    ]
    
    var items: [HNewsMoreMenuItem] = [] {
        didSet {
            // Setup subview - the items
            for i in 0 ..< items.count where items.count == itemviews.count {
                itemviews[i].item = items[i]
            }
        }
    }
    
    /// Indicates if view is shown
    var shown: Bool = false
    
    /// Dismisses the more menu, does not remove it from the superview
    func dismiss() {
        shown = !shown
        // tell constraints they need updating
        setNeedsUpdateConstraints()
        // update constraints now so we can animate the change
        updateConstraints()
        // do the initial layout
        layoutIfNeeded()
        UIView.animateWithDuration(0.4) {
            guard let superview = self.superview else { return }
            // make animatable changes
            self.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(superview.snp_bottom).offset(superview.frame.height / 3)
            })
            // do the animation
            self.layoutIfNeeded()
        }
    }
    
    /// Shows the more menu in the superview
    func show() {
        shown = !shown
        // tell constraints they need updating
        setNeedsUpdateConstraints()
        // update constraints now so we can animate the change
        updateConstraints()
        // do the initial layout
        layoutIfNeeded()
        UIView.animateWithDuration(0.4) {
            guard let superview = self.superview else { return }
            // make animatable changes
            self.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(superview.snp_bottom).offset(0)
            })
            // do the animation
            self.layoutIfNeeded()
        }
    }
    
    /// Called whenever the view was added in the view that it will present itself in
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        
        /// Setup the more menu view
        // Hide the view under the superview, animate up when shown
        self.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(superview.snp_height).dividedBy(3)
            make.bottom.equalTo(superview.snp_bottom).offset(superview.frame.height / 3)
        }

        // Setup menu item grid ...
        let lowerleftitem = itemviews[0]
        addSubview(lowerleftitem)
        lowerleftitem.snp_makeConstraints { (make) in
            make.width.equalTo(superview.snp_width).dividedBy(2)
            make.height.equalTo(self.snp_height).dividedBy(2)
            make.bottom.left.equalTo(0)
        }
        
        let lowerrightitem = itemviews[1]
        addSubview(lowerrightitem)
        lowerrightitem.snp_makeConstraints { (make) in
            make.width.equalTo(superview.snp_width).dividedBy(2)
            make.height.equalTo(self.snp_height).dividedBy(2)
            make.bottom.right.equalTo(0)
        }
        
        let upperleftitem = itemviews[2]
        addSubview(upperleftitem)
        upperleftitem.snp_makeConstraints { (make) in
            make.width.equalTo(superview.snp_width).dividedBy(2)
            make.height.equalTo(self.snp_height).dividedBy(2)
            make.top.left.equalTo(0)
        }

        let upperrightitem = itemviews[3]
        addSubview(upperrightitem)
        upperrightitem.snp_makeConstraints { (make) in
            make.width.equalTo(superview.snp_width).dividedBy(2)
            make.height.equalTo(self.snp_height).dividedBy(2)
            make.top.right.equalTo(0)
        }
    }
}