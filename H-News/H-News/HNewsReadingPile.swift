
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
    func existsStory(_ id: Int) -> Bool {
        var flag = false
        realm?.objects(NewsClass).forEach {
            if $0.id == id { flag = true; return }
        }
        return flag
    }
    
    /// Removes the NewsClass in Realm with the passed id
    func removeNews(_ id: Int) {
        if let newsToBeRemoved = realm?.objects(NewsClass).filter("id = %@", id) {
            do {
                try realm?.write {
                    self.realm?.delete(newsToBeRemoved)
                }
            } catch _ {}
        }
    }
    
    /// Removes read/unread News from the Reading Pile
    func removeAllNews(read: Bool) {
        do {
            try realm?.write {
                guard let news = realm?.objects(NewsClass).filter("read = %@", read) else { return }
                self.realm?.delete(news)
            }
        } catch _ {}
    }
    
    /// Removes all the saved News from the Reading Pile
    func removeAllNews() {
        do {
            try realm?.write {
                realm?.deleteAll()
            }
        } catch _ {}
    }
    
    /// Add a News if it does not exist or update it if it does in the pile
    func addNews(_ news: News) {
        let newsClass = NewsClass(news: news)
        do {
            try realm?.write {
                self.realm?.add(newsClass, update: true)
            }
        } catch _ {}
    }

    /// Fetches all News read or unread from the pile
    func fetchAllNews(read: Bool) -> [News] {
        guard let objects = realm?.objects(NewsClass).filter("read = %@", read) else { return [] }
        var news: [News] = []
        for object in objects {
            news.append(object.convertToNews())
        }
        return news
    }
    
    /// Saves the html binary data to the News in the Realm
    func save(_ html: Data, newsID: Int) {
        guard let news = realm?.objects(NewsClass).filter("id = %@", newsID).first else { return }
        do {
            try realm?.write {
                news.html = html
            }
        } catch _ {}
    }
    
    /// Returns the HTML data for the News
    func html(_ news: News) -> Data? {
        return realm?.objects(NewsClass).filter("id = %@", news.id).first?.html as! Data
    }
    
    /// Returns the number of News objects in the Realm
    func newsCount() -> Int? {
        return realm?.objects(NewsClass).count
    }
    
    /// Marks a specific News as read, returns a updated News. 
    func markNewsAsRead(_ news: News) -> News? {
        addNews(news) // Updates the rest of the values
        guard let news = realm?.objects(NewsClass).filter("id = %@", news.id).first else { return nil }
        do {
            try realm?.write {
                news.read = true
            }
            try realm?.commitWrite()
        } catch _ {}
        return news.convertToNews()
    }
    
    /// Checks if the Story has been read before.
    func isStoryRead(_ id: Int) -> Bool {
        guard let story = realm?.objects(NewsClass).filter("id = %@", id).first else { return false }
        return story.read
    }
}

class StoryClass: Object {
    dynamic var id      : Int    = 0
    dynamic var title   : String = ""
    dynamic var url     : String = ""
    dynamic var author  : String = ""
    dynamic var score   : Int    = 0
    dynamic var date    : Date = Date()
    dynamic var comments: Int = 0
    
    /// Indicates whether the Story has been read/viewed
    dynamic var read: Bool   = false
    
    override class func primaryKey() -> String { return "id" }
}

class NewsClass: StoryClass {
    /// The downloaded html for the news story, length 0 == nil
    dynamic var html: Data = Data()
    
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
        return News(id: id, title: title, author: author, date: date, read: read, score: score, comments: comments, url: URL(string: url)!)
    }
}
