class HNMenuButtonView: UIView {
    
    class PlusButton: UIButton {
        
        override func drawRect(rect: CGRect) {
            let path = UIBezierPath(ovalInRect: rect)
            Colors.lightGray.setFill()
            path.fill()
            
            //set up the width and height variables
            //for the horizontal stroke
            let plusHeight: CGFloat = 3.0
            let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
            
            //create the path
            let plusPath = UIBezierPath()
            
            //set the path's line width to the height of the stroke
            plusPath.lineWidth = plusHeight
            
            //move the initial point of the path
            //to the start of the horizontal stroke
            plusPath.moveToPoint(CGPoint(
                x:bounds.width/2 - plusWidth/2 + 0.5,
                y:bounds.height/2 + 0.5))
            
            //add a point to the path at the end of the stroke
            plusPath.addLineToPoint(CGPoint(
                x:bounds.width/2 + plusWidth/2 + 0.5,
                y:bounds.height/2 + 0.5))
            
            //Vertical Line
            //move to the start of the vertical stroke
            plusPath.moveToPoint(CGPoint(
                x:bounds.width/2 + 0.5,
                y:bounds.height/2 - plusWidth/2 + 0.5))
            
            //add the end point to the vertical stroke
            plusPath.addLineToPoint(CGPoint(
                x:bounds.width/2 + 0.5,
                y:bounds.height/2 + plusWidth/2 + 0.5))
            
            //set the stroke color
            Colors.gray.setStroke()
            
            //draw the stroke
            plusPath.stroke()
        }
    }
    
    private let plusBtn = PlusButton()
    var didTapOnButton: ((sender: HNMenuButtonView) -> Void)?
    
    override func didMoveToSuperview() {
        addSubview(plusBtn)
        
        plusBtn.snp_makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(0)
        }
        UIView.animateWithDuration(0.1) { self.plusBtn.layoutIfNeeded() }
        
        let tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        plusBtn.addGestureRecognizer(tapGestureRecog)
    }
    
    func didTapView(sender: UIGestureRecognizer) {
        // Poplike animation
        self.plusBtn.snp_updateConstraints { (make) in
            make.left.top.equalTo(-8)
            make.right.bottom.equalTo(8)
        }
        UIView.animateWithDuration(0.2, animations: {
            self.plusBtn.layoutIfNeeded()
        }) { (completed) in
            self.plusBtn.snp_updateConstraints { (make) in
                make.left.top.right.bottom.equalTo(0)
            }
        }
        didTapOnButton?(sender: self)
    }
}
