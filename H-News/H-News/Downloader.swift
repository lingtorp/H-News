//
//  Downloader.swift
//  H-News
//
//
//  Created by Alexander Lingtorp on 27/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import Alamofire

extension Dictionary {
    mutating func unionInPlace(dictionary: Dictionary) {
        dictionary.forEach { self.updateValue($1, forKey: $0) }
    }
    
    func union(var dictionary: Dictionary) -> Dictionary {
        dictionary.unionInPlace(self)
        return dictionary
    }
}

/// Downloader provides a interface to download something in batches async possibly combined with a Generator.
protocol DownloaderType {
    typealias Element
    func fetchNextBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void)
    /// Resets the Downloaders' internal state, clears buffers, et cetera.
    func reset()
}

/// Something that adopts this protocol is able to convert from JSON to itself and thus makes it 'downloadable'
protocol Downloadable {
    static func parseJSON(json: [String:AnyObject]) -> Self?
}

extension News: Downloadable {
    static func parseJSON(json: [String:AnyObject]) -> News? {
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
        df.timeZone = try! NSTimeZone(abbreviation: "GMT")
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        guard let date = df.dateFromString(time) else { return nil }
        return News(id: id, title: title, author: author, date: date, read: read, score: score, comments: comments, url: url)
    }
}

extension Comment: Downloadable {
    static func parseJSON(json: [String : AnyObject]) -> Comment? {
        guard let id       = json["id"]      as? Int    else { return nil }
        guard let offset   = json["offset"]  as? Int    else { return nil }
        guard let author   = json["author"]  as? String else { return nil }
        guard let text     = json["text"]    as? String else { return nil }
        guard let time     = json["time"]    as? String else { return nil }
        
        let df = NSDateFormatter()
        df.timeZone = try! NSTimeZone(abbreviation: "GMT")
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSSSSSSSXXXXX" // RFC3339
        guard let date = df.dateFromString(time) else { return nil }
        return Comment(id: id, author: author, date: date, text: text, offset: offset)
    }
}

/// The API endpoint from which a Downloader fetches data
enum APIEndpoint: String {
    case News     = "https://h-news.herokuapp.com/v1/news"
    case Comments = "https://h-news.herokuapp.com/v1/comments"
}

class Downloader<T: Downloadable>: DownloaderType {
    typealias Element = T
    typealias JSONDictionary = [String:AnyObject]
    typealias JSONArray = [JSONDictionary]
    
    private var onFinished: ([Element] -> Void)?
    
    private var buffer: [Element] = [] {
        didSet {
            if buffer.count >= 1 {
                onFinished?(buffer)
                buffer.removeAll(keepCapacity: true)
            }
        }
    }
    
    /// The API endpoint to fetch Downloadables from
    private let apiendpoint: APIEndpoint
    /// Extra URL parameters to send for every request to API
    var extraParams: [String:AnyObject]
    
    init(_ apiendpoint: APIEndpoint, params: [String:AnyObject]? = nil) {
        self.apiendpoint = apiendpoint
        self.extraParams = params ?? [:]
    }
    
    func fetchNextBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void) {
        onFinished = onCompletion
        nextAPIBatch(offset, batchSize: batchSize, onCompletion: onCompletion)
    }
    
    private func nextAPIBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void) {
        let stdparams: [String:AnyObject] = ["from" : offset + 1, "to" : offset + batchSize]
        let params = extraParams.union(stdparams)
        Alamofire.request(.GET, apiendpoint.rawValue, parameters: params)
            .responseJSON { (response) -> Void in
                if let json = response.result.value as? JSONDictionary {
                    onCompletion(result: self.parseJSONArray(json))
                }
        }
    }
    
    func reset() {
        buffer.removeAll(keepCapacity: true)
    }
    
    private func parseJSONArray(json: JSONDictionary) -> [Element] {
        guard let values = json["values"] as? JSONArray else { return [] }
        var elements: [Element] = []
        for value in values {
            if let element = Element.parseJSON(value) {
                elements.append(element)
            }
        }
        return elements
    }
}