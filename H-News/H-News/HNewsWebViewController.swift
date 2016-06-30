
import UIKit
import WebKit
import SnapKit

class HNewsWebViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let moremenu = HNewsMoreMenuView()
    private let webView = WKWebView()
    
    /// The url to load
    var url: NSURL? {
        didSet {
            guard let url = url else { return }
            loadWebViewWith(url)
        }
    }
        
    /// The Story/item/entry related to this webview
    var item: News?
    
    override func viewDidLoad() {
        webView.frame = view.bounds
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        view.addSubview(webView)
        
        let attribs: [String : AnyObject] = [
            NSForegroundColorAttributeName : Colors.peach]
        navigationController?.navigationBar.titleTextAttributes = attribs

        // Setup more menu
        view.addSubview(moremenu)
        let item0 = HNewsMoreMenuItem(title: "Comments", image: Icons.comments) { () in
            self.moremenu.dismiss()
            let commentVC = CommentsViewController()
            commentVC.news = self.item
            self.navigationController?.pushViewController(commentVC, animated: true)
        }
        
        let item1 = HNewsMoreMenuItem(title: "Upvote", image: Icons.upvote) { () in
            self.moremenu.dismiss()
            // TODO: Add visual cue that the item was upvoted successfully or not
        }
        
        let item2 = HNewsMoreMenuItem(title: "Save", image: Icons.save) { () in
            self.moremenu.dismiss()
            guard let item = self.item else { return }
            HNewsReadingPile()?.addNews(item)
            Popover(title: "Saved", mode: .Success).present()
        }
        
        let item3 = HNewsMoreMenuItem(title: "Share", image: Icons.share) { () in
            self.moremenu.dismiss()
            guard let url = self.url else { return }
            let shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            shareSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem!
            self.presentViewController(shareSheet, animated: true, completion: nil)
        }
        moremenu.items = [item0, item1, item2, item3]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.more, style: .Plain, target: self, action: #selector(HNewsWebViewController.didTapMore(_:)))
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // Add a dismiss button to the webview on a iPad
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .Plain, target: self, action: #selector(HNewsWebViewController.didTapDismiss(_:)))
        }

        let tapOnParentGestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsWebViewController.didTapOnParent(_:)))
        tapOnParentGestureRecog.delegate = self
        webView.addGestureRecognizer(tapOnParentGestureRecog)
        
        if #available(iOS 9.0, *) {
            webView.allowsLinkPreview = true
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Called whenever the superview was tapped
    func didTapOnParent(send: UITapGestureRecognizer) {
        if moremenu.shown {
            moremenu.dismiss()
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    private func loadWebViewWith(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func didTapMore(sender: UIBarButtonItem) {
        moremenu.shown ? moremenu.dismiss() : moremenu.show()
    }
    
    func didTapDismiss(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - WKWebView KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let _ = object as? WKWebView else {return}
        guard let keyPath = keyPath else {return}
        guard let change = change else {return}
        switch keyPath {
            case "title":
                if let newTitle = change[NSKeyValueChangeNewKey] as? String {
                    title = newTitle
                }
            default: break
        }
    }
}