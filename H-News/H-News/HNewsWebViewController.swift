//
//  HNewsWebView.swift
//  H-News
//
//  Created by Alexander Lingtorp on 23/08/15.
//  Copyright © 2015 Lingtorp. All rights reserved.
//

import UIKit
import WebKit

class HNewsWebViewController: UIViewController {
        
    private let webView = WKWebView()
    
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
    
    @IBAction func onShare(sender: UIBarButtonItem) {
        guard let url = url else { return }
        let shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        presentViewController(shareSheet, animated: true, completion: nil)
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