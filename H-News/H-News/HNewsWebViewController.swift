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
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private let webView = WKWebView()
    
    /// The url to load
    var url: NSURL? {
        didSet {
            loadWebViewWith(url!)
        }
    }
    
    /// The data to load
    var data: NSData? {
        didSet {
            loadWebViewWith(data!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.bounds
        view.addSubview(webView)
        webView.navigationDelegate = self

        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        
        // view.addSubview(toolbar)
        // toolbar.center = view.center
    }
    
    private func loadWebViewWith(data: NSData) {
        guard let string = NSString(data: data, encoding: 0) as? String else { return }
        webView.loadHTMLString(string, baseURL: nil)
        title = url?.host
    }
    
    private func loadWebViewWith(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
        title = url.host
    }
    
    @IBAction func onForward(sender: UIBarButtonItem) {
    
    }
    
    @IBAction func onBackward(sender: UIBarButtonItem) {
    
    }
    
    @IBAction func onRefresh(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func onShare(sender: UIBarButtonItem) {
        let shareSheet = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        presentViewController(shareSheet, animated: true, completion: nil)
    }
}

extension HNewsWebViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}