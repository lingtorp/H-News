//
//  HNewsReadingPile.swift
//  H-News
//
//  Created by Alexander Lingtorp on 31/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import UIKit
import RealmSwift

class HNewsReadingPile {
    
    var realm: Realm?
    
    init?() {
        do {
            realm = try Realm()
        } catch let err {
            print(err)
            return nil
        }
    }
    
    /// Removed the NewsClass in Realm with the passed id
    func removeNews(id: Int) {
        if let newsToBeRemoved = realm?.objects(NewsClass).filter("id = %@", id) {
            realm?.write {
                realm?.delete(newsToBeRemoved)
            }
        }
    }
    
    /// Add a News to the pile
    func addNews(news: News) {
        let newsClass = NewsClass(news: news)
        realm?.write {
            realm?.add(newsClass)
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
    
    func newsCount() -> Int? {
        return realm?.objects(NewsClass).count
    }
    
    func markNewsAsRead(news: News) -> Bool {
        guard let news = realm?.objects(NewsClass).filter("id = %@", news.id) else { return false }
        realm?.write {
            news.first?.read = true
        }
        return true
    }
}

class NewsClass: Object {
    dynamic var id    : Int    = 0
    dynamic var title : String = ""
    dynamic var url   : String = ""
    dynamic var author: String = ""
    dynamic var score : Int    = 0
    dynamic var date  : NSDate = NSDate()
    let kids  : List<RLMInt> = List<RLMInt>()
    
     /// Indicates whether the item is read/viewed
    dynamic var read  : Bool   = false
    
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
        for i in news.kids {
            let rlmInt = RLMInt()
            rlmInt.int = i
            kids.append(rlmInt)
        }
    }
    
    func convertToNews() -> News {
        return News(id: id, title: title, author: author, date: date, kids: kids.map { Int($0.int) }, url: NSURL(string: url)!, score: score)
    }
    
    override class func primaryKey() -> String { return "id" }
}

/// Class to support Arrays with primitive integers in Realm
class RLMInt: Object {
    dynamic var int: NSInteger = 0
}