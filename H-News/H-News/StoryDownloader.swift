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

import Alamofire

/// Downloader provides a interface to download something in batches async possibly combined with a Generator.
protocol Downloader {
    typealias Element
    func fetchNextBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void)
    /// Resets the Downloaders' internal state, clears buffers, et cetera.
    func reset()
}

/// I want to refactor the JSON parsing in these XYZDownloader classes so bad. It hurts.
class StoryDownloader: Downloader {
    typealias Element = Story
    typealias JSONDictionary = [String:AnyObject]
    typealias JSONArray = [JSONDictionary]
    
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
        if checkAPIStatus() {
            nextAPIBatch(offset, batchSize: batchSize, onCompletion: onCompletion)
        } else {
            nextFirebaseBatch(offset, batchSize: batchSize)
        }
    }
    
    private func nextAPIBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void) {
        let params = ["from" : offset + 1, "to" : offset + batchSize]
        Alamofire.request(.GET, "https://h-news.herokuapp.com/v1/news", parameters: params)
            .responseJSON { (response) -> Void in
                if let json = response.result.value as? JSONDictionary {
                    onCompletion(result: StoryDownloader.parseJSONPayloadAPI(json))
                }
        }
    }
    
    private func checkAPIStatus() -> Bool {
        return true
    }
    
    private let firebase = Firebase(url: "https://hacker-news.firebaseio.com/v0/")
    
    private func nextFirebaseBatch(offset: Int, batchSize: Int) {
        let topNewsRef = firebase.childByAppendingPath("topstories").queryOrderedByKey().queryStartingAtValue(String(offset)).queryEndingAtValue(String(offset + batchSize - 1))
        topNewsRef.observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            var itemIDs: [Int] = []
            if let arr = snapshot.value as? [Int] { itemIDs = arr } // For some reason. The first call returns an array.
            if let dict = snapshot.value as? [String:Int] { itemIDs = Array(dict.values) } // The second call returns an dictionary..
            for itemID in itemIDs {
                let itemRef = self.firebase.childByAppendingPath("item/\(itemID)")
                itemRef.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                    if let json = snapshot.value as? JSONDictionary {
                        if let parsedStory = StoryDownloader.parseJSONDictionaryFirebase(json) {
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
    
    private static func parseJSONPayloadAPI(json: JSONDictionary) -> [Element] {
        guard let values = json["news"] as? JSONArray else { return [] }
        var elements: [Element] = []
        for value in values {
            if let element = parseJSONDictionaryAPI(value) {
                elements.append(element)
            }
        }
        return elements
    }
    
    private static func parseJSONDictionaryAPI(json: JSONDictionary) -> Element? {
        guard let title  = json["title"]     as? String else { return nil }
        guard let id     = json["rank"]      as? Int    else { return nil }
        guard let author = json["author"]    as? String else { return nil }
        guard let time   = json["time"]      as? String else { return nil }
        guard let kids   = json["comments"]  as? Int    else { return nil }
        
        let df = NSDateFormatter()
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        guard let date = df.dateFromString(time)    else { return nil }
        
        guard let score = json["points"] as? Int    else { return nil }
        guard let tem   = json["link"]   as? String else { return nil }
        guard let url   = NSURL(string: tem)        else { return nil }
        
        return News(id: id, title: title, author: author, date: date, kids: [kids], url: url, score: score)
    }
    
    private static func parseJSONDictionaryFirebase(json: JSONDictionary) -> Element? {
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