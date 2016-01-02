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
        nextAPIBatch(offset, batchSize: batchSize, onCompletion: onCompletion)
    }
    
    private func nextAPIBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void) {
        let params = ["from" : offset + 1, "to" : offset + batchSize]
        Alamofire.request(.GET, "https://h-news.herokuapp.com/v1/news", parameters: params)
            .responseJSON { (response) -> Void in
                if let json = response.result.value as? JSONDictionary {
                    onCompletion(result: StoryDownloader.parseJSONArray(json))
                }
        }
    }
    
    func reset() {
        buffer.removeAll(keepCapacity: true)
    }
    
    private static func parseJSONArray(json: JSONDictionary) -> [Element] {
        guard let values = json["news"] as? JSONArray else { return [] }
        var elements: [Element] = []
        for value in values {
            if let element = parseJSON(value) {
                elements.append(element)
            }
        }
        return elements
    }
    
    private static func parseJSON(json: JSONDictionary) -> Element? {
        guard let id     = json["id"]     as? Int    else { return nil }
        guard let title  = json["title"]  as? String else { return nil }
        guard let author = json["author"] as? String else { return nil }
        guard let time   = json["time"]   as? String else { return nil }
        guard let score  = json["points"] as? Int    else { return nil }
        guard let comments = json["comments"] as? Int else { return nil }
        guard let read  = HNewsReadingPile()?.isStoryRead(id) else { return nil }
        guard let tem   = json["link"]    as? String else { return nil }
        guard let url   = NSURL(string: tem)         else { return nil }

        let df = NSDateFormatter()
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        guard let date = df.dateFromString(time) else { return nil }
        return News(id: id, title: title, author: author, date: date, read: read, score: score, comments: comments, url: url)
    }
}