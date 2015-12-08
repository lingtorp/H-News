//
//  FeedFetcher.swift
//  H-News
//
//  __ Hacker News Firebase API Documentation ___
//  __ https://github.com/HackerNews/API __
//
//  Created by Alexander Lingtorp on 27/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

/// Downloader provides a interface to download something in batches async possibly combined with a Generator.
protocol Downloader {
    typealias Element
    func fetchNextBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void)
    /// Resets the Downloaders' internal state, clears buffers, et cetera.
    func reset()
}

class StoryDownloader: Downloader {
    private let firebase = Firebase(url: "https://hacker-news.firebaseio.com/v0/")

    typealias JSONDictionary = [String:AnyObject]
    typealias Element = Story
    
    private var onFinished: ([Element] -> Void)?
    
    private var buffer: [Element] = [] {
        didSet {
            if buffer.count >= 10 {
                onFinished?(buffer)
                buffer.removeAll(keepCapacity: true)
            }
        }
    }

    func fetchNextBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void) {
        onFinished = onCompletion
        let topNewsRef = firebase.childByAppendingPath("topstories").queryOrderedByKey().queryStartingAtValue(String(offset)).queryEndingAtValue(String(offset + batchSize - 1))
        topNewsRef.observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            var itemIDs: [Int] = []
            if let arr = snapshot.value as? [Int] { itemIDs = arr } // For some reason. The first call returns an array.
            if let dict = snapshot.value as? [String:Int] { itemIDs = Array(dict.values) } // The second call returns an dictionary..
            for itemID in itemIDs {
                let itemRef = self.firebase.childByAppendingPath("item/\(itemID)")
                itemRef.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                    if let json = snapshot.value as? JSONDictionary {
                        if let parsedStory = StoryDownloader.parseJSONDictionary(json) {
                            self.buffer.append(parsedStory)
                        }
                    }
                })
            }
        }
    }
    
    func reset() {
        buffer.removeAll(keepCapacity: true)
    }
    
    private static func parseJSONDictionary(json: JSONDictionary) -> Story? {
        guard let title  = json["title"]  as? String else { return nil }
        guard let id     = json["id"]     as? Int    else { return nil }
        guard let author = json["by"]     as? String else { return nil }
        guard let time   = json["time"]   as? Int    else { return nil }
        guard let kids   = json["kids"]   as? [Int]  else { return nil }
        guard let type   = json["type"]   as? String else { return nil }
        
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(time))
        
        switch type {
            case "comment":
                guard let text  = json["text"] as? String else { return nil }
                return Comment(id: id, title: title, author: author, date: date, kids: kids, text: text)
            
            case "story":
                guard let score = json["score"] as? Int    else { return nil }
                guard let tem   = json["url"]   as? String else { return nil }
                guard let url   = NSURL(string: tem)       else { return nil }
                return News(id: id, title: title, author: author, date: date, kids: kids, url: url, score: score)
            
            case "ask":
                guard let score = json["score"] as? Int    else { return nil }
                guard let text  = json["text"]  as? String else { return nil }
                return Ask(id: id, title: title, author: author, date: date, kids: kids, text: text, score: score)
            
            default:
                return nil
        }
    }
}
