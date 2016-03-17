import CRToast

class Popover {
    
    enum Mode {
        case Success, NoInternet, LoginRequired
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
        case .NoInternet:
            options[kCRToastBackgroundColorKey] = Colors.failure
        case .LoginRequired:
            options[kCRToastBackgroundColorKey] = Colors.failure
            // TODO: Add login required title, make clickable to login popover
        }
    }
    
    func present() {
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }
}