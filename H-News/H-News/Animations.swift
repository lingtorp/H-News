import UIKit

/// Application wide used animations
/// Never create a object of this type, it is not needed.
class Animations {
    
    // TODO: Add ability for method chaining
    
    typealias Completion = () -> ()
    
    // Default animation duration specified in milliseconds (ms)
    static let animationDuration: Double = 0.2
    
    /// Fades the given view in
    class func fadeIn(view: UIView, startAlpha: Float = 0, endAlpha: Float = 1.0, completion: Completion? = nil) {
        view.alpha = CGFloat(startAlpha)
        UIView.animateWithDuration(Animations.animationDuration, animations: {
            view.alpha = CGFloat(endAlpha)
            }) { (completed) in
                completion?()
        }
    }
    
    /// Fades the given view out
    class func fadeOut(view: UIView, startAlpha: Float = 0, endAlpha: Float = 1.0, completion: Completion? = nil) {
        Animations.fadeIn(view, startAlpha: endAlpha, endAlpha: startAlpha, completion: completion)
    }
    
    /// Shakes the view in the x-axis while rotating it back and forth in the y-axis
    class func shake(view: UIView, completion: Completion? = nil) {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotation.values = [-3, 3, -3, 3, -2, 2, -1, 1, 0].map { Animations.toRadians($0) }
        
        let shakeGroup = CAAnimationGroup()
        shakeGroup.animations = [translation, rotation]
        shakeGroup.duration = 0.6
        view.layer.addAnimation(shakeGroup, forKey: #function)
    }
    
    class func pop(view: UIView, completion: Completion? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.values = [view.layer.contentsScale, 1.5, view.layer.contentsScale]
        animation.fillMode = kCAFillModeForwards
        animation.duration = 0.5
        animation.removedOnCompletion = false
        view.layer.addAnimation(animation, forKey: #function)
    }
    
    class func rotate(view: UIView, toDegrees: Double, completion: Completion? = nil) {
        UIView.animateWithDuration(Animations.animationDuration) { 
            view.transform = CGAffineTransformMakeRotation(CGFloat(Animations.toRadians(toDegrees)))
        }
    }
    
    
    // MARK: - Conversions
    class func toRadians(x: Double) -> Double { return x * M_PI/180 }
    class func toDegrees(x: Double) -> Double { return x * 180/M_PI }
}