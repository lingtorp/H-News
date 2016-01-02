//
//  RealmModels.swift
//  H-News
//
//  Created by Alexander Lingtorp on 02/01/16.
//  Copyright © 2016 Lingtorp. All rights reserved.
//

import RealmSwift

class StoryClass: Object {
    dynamic var id    : Int    = 0
    dynamic var title : String = ""
    dynamic var url   : String = ""
    dynamic var author: String = ""
    dynamic var score : Int    = 0
    dynamic var date  : NSDate = NSDate()
    dynamic var comments : Int = 0
    
    /// Indicates whether the Story has been read/viewed
    dynamic var read  : Bool   = false
    
    override class func primaryKey() -> String { return "id" }
}

class NewsClass: StoryClass {
    /// The downloaded html for the news story, length 0 == nil
    dynamic var html  : NSData = NSData()
    
    required convenience init(news: News) {
        self.init()
        id     = news.id
        title  = news.title
        url    = news.url.absoluteString
        author = news.author
        score  = news.score
        date   = news.date
        comments = news.comments
    }
    
    func convertToNews() -> News {
        return News(id: id, title: title, author: author, date: date, read: read, score: score, comments: comments, url: NSURL(string: url)!)
    }
}
