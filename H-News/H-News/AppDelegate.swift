import UIKit
import BEMCheckBox

import Kanna
import Alamofire

class Scraper<T> {
    private let string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    func scrape(selector: String) -> [T] {
        if let doc = Kanna.HTML(html: string, encoding: NSUTF8StringEncoding) {
            var content: [T] = []
            for item in doc.css(selector) {
                if let text = item.text as? T {
                    content.append(text)
                }
            }
            return content
        }
        return []
    }
    
    func scrape(selector: String, innerHTML: String) -> [String] {
        if let doc = Kanna.HTML(html: string, encoding: NSUTF8StringEncoding) {
            var content: [String] = []
            for item in doc.css(selector) {
                let something = item[innerHTML] ?? ""
                content.append(something)
            }
            return content
        }
        return []
    }
}

func playground() {
    let page = 0
    let url = "https://news.ycombinator.com/newest?n=" + String(page * 30 + 1)
    Alamofire.request(.GET, NSURL(string: url)!).responseString { (reponse) in
        guard let html = reponse.result.value else { return }
        if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
            print(doc.title)
            
            let scores = Scraper<String>(html).scrape(".subtext .score")
            print(scores)
            
            let ranks = Scraper<String>(html).scrape(".athing * .rank")
            print(ranks)
            
            let authors = Scraper<String>(html).scrape(".subtext .hnuser")
            print(authors)
            
            let ages = Scraper<String>(html).scrape(".subtext .age a")
            print(ages)
            
            let aTags = Scraper<String>(html).scrape(".subtext a:last-child")
            let numComments = aTags.filter { $0.containsString("comments") }
            print(numComments)
            
            let titles = Scraper<String>(html).scrape(".title a.storylink")
            print(titles)
            
            var links = Scraper<String>(html).scrape(".title .storylink", innerHTML: "href")
            links = links.map { $0.containsString("item?id=") ? "\(url)/\($0)" : $0 }
            print(links)
            
            var news: [News] = []
            let maxLength = min(scores.count, ranks.count, authors.count, ages.count, numComments.count, titles.count, links.count)
            for i in 0..<maxLength {
//                news[i] = News(id: id, title: title, author: author, date: date, read: false, score: score, comments: comments, url: link)
            }
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let masterVC = MasterViewController()
        let masterNav = UINavigationController(rootViewController: masterVC)
        let detailVC = DetailViewController()
        let detailNav = UINavigationController(rootViewController: detailVC)
        
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [masterNav, detailNav]
        splitVC.delegate = self
        
        window?.rootViewController = splitVC
        window?.makeKeyAndVisible()
        
        /// Global appearance
        UINavigationBar.appearance().tintColor = Colors.peach
        UINavigationBar.appearance().barTintColor = Colors.gray
        UITableView.appearance().backgroundColor = Colors.gray
        
        // Checkbox default appearance
        BEMCheckBox.appearance().onTintColor = Colors.peach
        BEMCheckBox.appearance().tintColor = Colors.peach
        BEMCheckBox.appearance().onCheckColor = Colors.peach
        BEMCheckBox.appearance().lineWidth = 1.5
        BEMCheckBox.appearance().animationDuration = 0.2
        
        playground()
        
        return true
    }

    // MARK: - Split view
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let _ = secondaryAsNavController.topViewController as? DetailViewController {
                // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                return true
            }
        }
        return false
    }
}

