
import UIKit
import WebKit
import SnapKit

class HNewsWebViewController: UIViewController {
    
    fileprivate let moremenu = HNewsMoreMenuView()
    fileprivate let webView = WKWebView()
    fileprivate let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    /// The url to load
    var url: URL? {
        didSet {
            guard let url = url else { return }
            loadWebViewWith(url)
        }
    }
    
    /// The data to load
    var data: Data? {
        didSet {
            guard let data = data else { return }
            loadWebViewWith(data)
        }
    }
    
    /// The Story/item/entry related to this webview
    var item: News?
    
    override func viewDidLoad() {
        webView.frame = view.bounds
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        view.addSubview(webView)
        
        view.addSubview(activitySpinner)
        view.bringSubview(toFront: activitySpinner)
        activitySpinner.color = Colors.hackerNews
        activitySpinner.startAnimating()
        activitySpinner.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(0)
            make.size.equalTo(25)
        }
        
        // Setup more menu
        view.addSubview(moremenu)
        let item0 = HNewsMoreMenuItem(title: "Comments", image: Icons.comments) { () in
            self.moremenu.dismiss()
            let commentVC = HNewsCommentsViewController()
            commentVC.news = self.item
            self.navigationController?.pushViewController(commentVC, animated: true)
        }
        let item1 = HNewsMoreMenuItem(title: "Upvote", image: Icons.upvote) { () in
            self.moremenu.dismiss()
            // TODO: Add visual cue that the item was upvoted successfully or not
        }
        let item2 = HNewsMoreMenuItem(title: "Save", image: Icons.readingList) { () in
            self.moremenu.dismiss()
            guard let item = self.item else { return }
            HNewsReadingPile()?.addNews(item)
            Popover(title: "Saved", mode: .success).present()
        }
        let item3 = HNewsMoreMenuItem(title: "Share", image: Icons.comments) { () in
            self.moremenu.dismiss()
            guard let url = self.url else { return }
            let shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            shareSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem!
            self.present(shareSheet, animated: true, completion: nil)
        }
        moremenu.items = [item0, item1, item2, item3]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.more, style: .plain, target: self, action: #selector(HNewsWebViewController.didTapMore(_:)))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Add a dismiss button to the webview on a iPad
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .plain, target: self, action: #selector(HNewsWebViewController.didTapDismiss(_:)))
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    fileprivate func loadWebViewWith(_ data: Data) {
        guard let html = NSString(data: data, encoding: String.Encoding.ascii.rawValue) as String? else { return }
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    fileprivate func loadWebViewWith(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    func didTapMore(_ sender: UIBarButtonItem) {
        if moremenu.shown { moremenu.dismiss() } else { moremenu.show() }
    }
    
    func didTapDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - WKWebView KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let _ = object as? WKWebView else {return}
        guard let keyPath = keyPath else {return}
        guard let change = change else {return}
        switch keyPath {
            case "loading":
                if let _ = change[NSKeyValueChangeKey.newKey] as? Bool {
                    activitySpinner.stopAnimating()
                }
            case "title":
                if let newTitle = change[NSKeyValueChangeKey.newKey] as? String {
                    title = newTitle
                }
            default: break
        }
    }
}
