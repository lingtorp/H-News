//
//  HNewsReadingPile.swift
//  H-News
//
//  Created by Alexander Lingtorp on 31/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import RealmSwift

class HNewsReadingPile {
    
    var realm: Realm?
    
    init?() {
        do {
            realm = try Realm()
        } catch _ {
            return nil
        }
    }
    
    /// Checks if a Story with id exists
    func existsStory(id: Int) -> Bool {
        var flag = false
        realm?.objects(NewsClass).forEach {
            if $0.id == id { flag = true; return }
        }
        return flag
    }
    
    /// Removed the NewsClass in Realm with the passed id
    func removeNews(id: Int) {
        if let newsToBeRemoved = realm?.objects(NewsClass).filter("id = %@", id) {
            realm?.write {
                self.realm?.delete(newsToBeRemoved)
            }
        }
    }
    
    /// Removes all the saved News from the Reading Pile
    func removeAllNews() {
        realm?.write {
            self.realm?.deleteAll()
        }
    }
    
    /// Add a News to the pile
    func addNews(news: News) {
        guard !existsStory(news.id) else { return }
        let newsClass = NewsClass(news: news)
        realm?.write {
            self.realm?.add(newsClass)
        }
    }

    /// Fetches all News from the pile
    func fetchAllNews() -> [News] {
        var news: [News] = []
        if let objects = realm?.objects(NewsClass) {
            for object in objects {
                news.append(object.convertToNews())
            }
        }
        return news
    }
    
    /// Saves the html binary data to the News in the Realm
    func save(html: NSData, newsID: Int) {
        guard let news = realm?.objects(NewsClass).filter("id = %@", newsID) else { return }
        realm?.write {
            news.first?.html = html
        }
    }
    
    /// Returns the data for the News
    func html(news: News) -> NSData? {
        return realm?.objects(NewsClass).filter("id = %@", news.id).first?.html
    }
    
    /// Returns the number of News objects in the Realm
    func newsCount() -> Int? {
        return realm?.objects(NewsClass).count
    }
    
    /// Marks a specific News as read.
    func markNewsAsRead(news: News) -> Bool {
        guard let news = realm?.objects(NewsClass).filter("id = %@", news.id) else { return false }
        realm?.write {
            news.first?.read = true
        }
        return true
    }
}

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
