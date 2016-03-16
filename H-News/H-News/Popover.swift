import CRToast

class Popover {
    
    enum Mode {
        case Success, Failure
    }
    
    private var options: [NSObject : AnyObject]
    
    init(title: String, mode: Mode) {
        options = [
            kCRToastTextAlignmentKey : NSInteger(NSTextAlignment.Center.rawValue),
            kCRToastTextKey : title,
            kCRToastAnimationInTypeKey : NSInteger(CRToastAnimationType.Gravity.rawValue),
            kCRToastAnimationOutTypeKey : NSInteger(CRToastAnimationType.Gravity.rawValue)
        ]

        switch mode {
        case .Success:
            options[kCRToastBackgroundColorKey] = Colors.success
        case .Failure:
            options[kCRToastBackgroundColorKey] = Colors.failure
        }
    }
    
    func present() {
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }
}