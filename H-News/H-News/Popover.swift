import CRToast

class Popover {
    
    enum Mode {
        case success, noInternet, loginRequired
    }
    
    fileprivate var options: [AnyHashable: Any]
    
    init(title: String, mode: Mode) {
        options = [
            kCRToastTextAlignmentKey : NSInteger(NSTextAlignment.center.rawValue),
            kCRToastTextKey : title,
            kCRToastAnimationInTypeKey : NSInteger(CRToastAnimationType.gravity.rawValue),
            kCRToastAnimationOutTypeKey : NSInteger(CRToastAnimationType.gravity.rawValue)
        ]

        switch mode {
        case .success:
            options[kCRToastBackgroundColorKey] = Colors.success
        case .noInternet:
            options[kCRToastBackgroundColorKey] = Colors.failure
        case .loginRequired:
            options[kCRToastBackgroundColorKey] = Colors.failure
            // TODO: Add login required title, make clickable to login popover
        }
    }
    
    func present() {
        CRToastManager.showNotification(options: options, completionBlock: nil)
    }
}
