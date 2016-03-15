
import UIKit
import WebKit
import SnapKit

class HNewsWebViewController: UIViewController {
        
    private let webView = WKWebView()
    private let activitySpinner = UIActivityIndicatorView()
    
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
    
    func didTapMore() {
        // TODO: Open up HnewsMoreMenu
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.bounds
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        view.addSubview(webView)
        
        view.addSubview(activitySpinner)
        activitySpinner.snp_makeConstraints { (make) -> Void in
            make.left.right.top.bottom.equalTo(50)
        }
        
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
        let item = HNewsMoreMenuItem(title: "Title", subtitle: "Subtitle", image: UIImage(named: "more")!)
        let moremenu = HNewsMoreMenuView(items: [item])
        view.addSubview(moremenu)
//        guard let url = url else { return }
//        let shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        presentViewController(shareSheet, animated: true, completion: nil)
    }
    
    // MARK: - WKWebView KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let _ = object as? WKWebView else {return}
        guard let keyPath = keyPath else {return}
        guard let change = change else {return}
        switch keyPath {
            case "loading":
                if let loading = change[NSKeyValueChangeNewKey] as? Bool {
                    if loading {
                        // activity.startAnimating()
                    } else {
                        // activity.stopAnimating()
                    }
                }
            case "title":
                if let newTitle = change[NSKeyValueChangeNewKey] as? String {
                    title = newTitle
                }
            default: break
        }
    }
}