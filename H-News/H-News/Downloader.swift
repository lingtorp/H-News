import Alamofire

extension Dictionary {
    mutating func unionInPlace(dictionary: Dictionary) {
        dictionary.forEach { self.updateValue($1, forKey: $0) }
    }
    
    func union(dictionary: Dictionary) -> Dictionary {
        var dict = dictionary
        dict.unionInPlace(self)
        return dict
    }
}

/// Downloader provides a interface to download something in batches async possibly combined with a Generator.
protocol DownloaderType {
    associatedtype Element
    func fetchNextBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void)
    /// Resets the Downloaders' internal state, clears buffers, et cetera.
    func reset()
}

/// Something that adopts this protocol is able to convert from JSON to itself and thus makes it 'downloadable'
protocol Downloadable {
    static func parseJSON(json: [String:AnyObject], resource: Resource) -> Self?
}

extension Ask: Downloadable {
    static func parseJSON(json: [String:AnyObject], resource: Resource) -> Ask? {
        guard let id     = json["id"]     as? Int    else { return nil }
        guard let title  = json["title"]  as? String else { return nil }
        guard let author = json["author"] as? String else { return nil }
        guard let time   = json["time"]   as? String else { return nil }
        guard let score  = json["points"] as? Int    else { return nil }
        guard let comments = json["comments"] as? Int else { return nil }
        guard let read  = HNewsReadingPile()?.isStoryRead(id) else { return nil }
        guard let question = json["question"] as? String else { return nil }
        
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(abbreviation: "GMT")
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        guard let date = df.dateFromString(time) else { return nil }
        return Ask(id: id, title: title, author: author, date: date, read: read, score: score, comments: comments, question: question)
    }
}

extension News: Downloadable {
    static func parseJSON(json: [String:AnyObject], resource: Resource) -> News? {
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
        df.timeZone = NSTimeZone(abbreviation: "GMT")
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        guard let date = df.dateFromString(time) else { return nil }
        return News(id: id, title: title, author: author, date: date, read: read, score: score, comments: comments, url: url)
    }
}

extension Comment: Downloadable {
    static func parseJSON(json: [String : AnyObject], resource: Resource) -> Comment? {
        guard let id       = json["id"]      as? Int    else { return nil }
        guard let offset   = json["offset"]  as? Int    else { return nil }
        guard let author   = json["author"]  as? String else { return nil }
        guard let text     = json["text"]    as? String else { return nil }
        guard let time     = json["time"]    as? String else { return nil }
        
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(abbreviation: "GMT")
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSSSSSSSXXXXX" // RFC3339
        guard let date = df.dateFromString(time) else { return nil }
        return Comment(id: id, author: author, date: date, text: text, offset: offset)
    }
}

/// URLs to the API on Heroku server
private enum ServerURL: String {
    case Top      = "https://h-news.herokuapp.com/v1/top"
    case Show     = "https://h-news.herokuapp.com/v1/show"
    case Newest   = "https://h-news.herokuapp.com/v1/newest"
    case Ask      = "https://h-news.herokuapp.com/v1/ask"
    case Comments = "https://h-news.herokuapp.com/v1/comments"
}

private enum WebsiteURL: String {
    case Top      = "https://news.ycombinator.com/news"
    case Show     = "https://news.ycombinator.com/show"
    case Newest   = "https://news.ycombinator.com/newest"
    case Ask      = "https://news.ycombinator.com/ask"
    case Comments = "https://news.ycombinator.com/item?id=12105286"
}

enum Resource {
    case Top, Show, Newest, Ask, Comments
    
    var primaryURL: String {
        switch self {
        default:
            return ""
        }
    }
    
    enum Response {
        var fromURL: String {
            return ""
        }
    }
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
    private let resource: Resource
    /// Extra URL parameters to send for every request to API
    var extraParams: [String:AnyObject]
    
    init(_ resource: Resource, params: [String:AnyObject]? = nil) {
        self.resource = resource
        self.extraParams = params ?? [:]
        // TODO: Check if server is available or not..
    }
    
    func fetchNextBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void) {
        onFinished = onCompletion
        nextAPIBatch(offset, batchSize: batchSize, onCompletion: onCompletion)
    }
    
    private func nextAPIBatch(offset: Int, batchSize: Int, onCompletion: (result: [Element]) -> Void) {
        let stdparams: [String:AnyObject] = ["from" : offset + 1, "to" : offset + batchSize]
        let params = extraParams.union(stdparams)
        Alamofire.request(.GET, resource.primaryURL, parameters: params)
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
            if let element = Element.parseJSON(value, resource: resource) {
                elements.append(element)
            }
        }
        return elements
    }
}