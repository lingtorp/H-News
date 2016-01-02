//
//  HNewsReadingPile.swift
//  H-News
//
//  Created by Alexander Lingtorp on 31/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import RealmSwift

/// Represents the to-be-reading/saved stories
class HNewsReadingPile {
    
    // Public because someone might want to subscribe for changes
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
            do {
                try realm?.write {
                    self.realm?.delete(newsToBeRemoved)
                }
            } catch _ {}
        }
    }
    
    /// Removes all the saved News from the Reading Pile
    func removeAllNews() {
        do {
            try realm?.write {
                self.realm?.deleteAll()
            }
        } catch _ {}
    }
    
    /// Add a News to the pile
    func addNews(news: News) {
        guard !existsStory(news.id) else { return }
        let newsClass = NewsClass(news: news)
        do {
            try realm?.write {
                self.realm?.add(newsClass)
            }
        } catch _ {}
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
        do {
            try realm?.write {
                news.first?.html = html
            }
        } catch _ {}
    }
    
    /// Returns the HTML data for the News
    func html(news: News) -> NSData? {
        return realm?.objects(NewsClass).filter("id = %@", news.id).first?.html
    }
    
    /// Returns the number of News objects in the Realm
    func newsCount() -> Int? {
        return realm?.objects(NewsClass).count
    }
    
    /// Marks a specific News as read, returns a updated News. Also archives it to the ArchivePile.
    func markNewsAsRead(news: News) -> News? {
        if !existsStory(news.id) {
            addNews(news)
        }
        guard let news = realm?.objects(NewsClass).filter("id = %@", news.id) else { return nil }
        do {
            try realm?.write {
                news.first?.read = true
            }
            try realm?.commitWrite()
        } catch _ {}
        return news.first?.convertToNews()
    }
    
    /// Checks if the Story has been read before.
    func isStoryRead(id: Int) -> Bool {
        guard let story = realm?.objects(StoryClass).filter("id = %@", id) else { return false }
        return story.first?.read ?? false
    }
}