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
        let news = News(id: 0, title: title, author: "", date: Date(), read: false, score: 0, comments: 0, url: URL(string: "https://google.se")!)
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
                        let json: [String:String] = ["title" : title.text ?? "HELLO"]
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
