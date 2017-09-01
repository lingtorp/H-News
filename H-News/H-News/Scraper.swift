import Alamofire
import Kanna

/// Downloader provides a interface to download something in batches async possibly combined with a Generator.
protocol ScraperType {
    associatedtype Element
    func fetchNextBatch(_ offset: Int, batchSize: Int, onCompletion: @escaping (_ result: [Element]) -> Void)
    /// Resets the Downloaders' internal state, clears buffers, et cetera.
    func reset()
}

protocol Convertable {
    typealias JSON = [String:String]
    static func create(json: JSON) -> Self
}

extension News: Convertable {
    static func create(json: JSON) -> News {
        let title = json["title"] ?? "SOMETHING ELSE" as String
        let link  = json["link"] ?? "https://www.google.se" as String
        let news = News(id: 0, title: title, author: "", date: Date(), read: false, score: 0, comments: 0, url: URL(string: link)!)
        return news
    }
}

class Scraper<T: Convertable>: ScraperType {
    typealias Element = T
    typealias JSONDictionary = [String:AnyObject]
    typealias JSONArray = [JSONDictionary]
    
    private var onFinished: (([Element]) -> Void)?
    
    private var buffer: [Element] = [] {
        didSet {
            if buffer.count >= 1 {
                onFinished?(buffer)
                buffer.removeAll(keepingCapacity: true)
            }
        }
    }
    
    private let url: URL!
    
    init() {
        self.url = URL(string: "https://news.ycombinator.com")!
        Alamofire.request(url).responseString { (data: DataResponse<String>) in
            if let html = data.value {
                if let doc = HTML(html: html, encoding: .utf8) {
                    // Search for nodes by CSS
                    for title in doc.css("tr.athing .title a") {
                        var json: [String:String] = [:]
                        json["title"] = title.text ?? "HELLO1"
                        json["link"]  = title["href"] ?? "https://www.google.se"
                        self.buffer.append(Element.create(json: json))
                        print(title.text)
                    }
                }
            }
        }
    }
    
    func fetchNextBatch(_ offset: Int, batchSize: Int, onCompletion: @escaping ([T]) -> Void) {
        onFinished = onCompletion
        nextAPIBatch(offset, batchSize: batchSize, onCompletion: onCompletion)
    }
    
    fileprivate func nextAPIBatch(_ offset: Int, batchSize: Int, onCompletion: @escaping (_ result: [Element]) -> Void) {
        // TODO
    }
    
    func reset() {
        buffer.removeAll(keepingCapacity: true)
    }
}
