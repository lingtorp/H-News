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
    }
    
    private func loadWebViewWith(data: NSData) {
        guard let string = NSString(data: data, encoding: NSASCIIStringEncoding) as? String else { return }
        webView.loadHTMLString(string, baseURL: nil)
        title = url?.host
    }
    
    private func loadWebViewWith(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
        title = url.host
    }
    
    @IBAction func onShare(sender: UIBarButtonItem) {
        let shareSheet = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        presentViewController(shareSheet, animated: true, completion: nil)
    }
}