//
//  ArticleTextExtractor.swift
//  H-News
//
//  Created by Alexander Lingtorp on 29/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import Foundation
import UIKit

class ArticleTextExtractor {
    
    func downloadArticle(url: NSURL, newsID: Int) {
        downloadHTMLFor(url, newsID: newsID)
    }
    
    private func downloadHTMLFor(url: NSURL, newsID: Int) {
        let request = NSMutableURLRequest(URL: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, err) -> Void in
            if let data = data {
                HNewsReadingPile()?.save(data, newsID: newsID)
            }
            print(response)
            print(data)
            print(err)
        }
        
        task.resume()
    }
}