class HNMenuButtonView: UIView {
    
    class PlusButton: UIButton {
        
        override func drawRect(rect: CGRect) {
            let circle = UIBezierPath(ovalInRect: rect)
            Colors.lightGray.setFill()
            circle.fill()
            
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
    var didTapOnButton: ((sender: HNMenuButtonView, selected: Bool) -> Void)?
    
    override func didMoveToSuperview() {
        addSubview(plusBtn)
        plusBtn.snp_makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(0)
        }
        Animations.fadeIn(self)
        
        let tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        plusBtn.addGestureRecognizer(tapGestureRecog)
    }
    
    private var selected = false
    
    func didTapView(sender: UIGestureRecognizer) {
        if selected {
            Animations.pop(self)
            Animations.rotate(self, toDegrees: 0)
        } else {
            Animations.pop(self)
            Animations.rotate(self, toDegrees: -45.0)
        }
        didTapOnButton?(sender: self, selected: selected)
        selected = !selected
    }
}
