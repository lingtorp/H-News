
import UIKit
import WebKit
import SnapKit

class HNewsWebViewController: UIViewController {
    
    private let moremenu = HNewsMoreMenuView()
    private let webView = WKWebView()
    private let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    /// The url to load
    var url: NSURL? {
        didSet {
            guard let url = url else { return }
            loadWebViewWith(url)
        }
    }
    
    /// The data to load
    var data: NSData? {
        didSet {
            guard let data = data else { return }
            loadWebViewWith(data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.bounds
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        view.addSubview(webView)
        
        view.addSubview(activitySpinner)
        view.bringSubviewToFront(activitySpinner)
        activitySpinner.color = Colors.hackerNews
        activitySpinner.startAnimating()
        activitySpinner.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(0)
            make.size.equalTo(25)
        }
        
        // Setup more menu
        view.addSubview(moremenu)
        let item0 = HNewsMoreMenuItem(title: "", subtitle: "Comments", image: Icons.comments) { (item) in print("item0"); self.moremenu.dismiss() }
        let item1 = HNewsMoreMenuItem(title: "", subtitle: "Upvote", image: Icons.upvote) { (item) in print("item1") }
        let item2 = HNewsMoreMenuItem(title: "", subtitle: "Save", image: Icons.readingList) { (item) in print("item2") }
        let item3 = HNewsMoreMenuItem(title: "", subtitle: "Share", image: Icons.comments) { (item) in print("item3") }
        moremenu.items = [item0, item1, item2, item3]
        
        //        guard let url = url else { return }
        //        let shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        //        presentViewController(shareSheet, animated: true, completion: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.more, style: .Plain, target: self, action: "didTapMore:")
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    private func loadWebViewWith(data: NSData) {
        guard let html = NSString(data: data, encoding: NSASCIIStringEncoding) as? String else { return }
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func loadWebViewWith(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func didTapMore(sender: UIBarButtonItem) {
        if moremenu.shown { moremenu.dismiss() } else { moremenu.show() }
    }
    
    // MARK: - WKWebView KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let _ = object as? WKWebView else {return}
        guard let keyPath = keyPath else {return}
        guard let change = change else {return}
        switch keyPath {
            case "loading":
                if let _ = change[NSKeyValueChangeNewKey] as? Bool {
                    activitySpinner.stopAnimating()
                }
            case "title":
                if let newTitle = change[NSKeyValueChangeNewKey] as? String {
                    title = newTitle
                }
            default: break
        }
    }
}