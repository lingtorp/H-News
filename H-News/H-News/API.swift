import Alamofire

// FIXME: Move into API with Swift 3.0
let baseurl = "https://h-news.herokuapp.com"

// FIXME: Move into API with Swift 3.0
enum Result {
    case Success, Failed, LoginRequired, NoInternet
}

// FIXME: All network calls need to be rewritten and handle failure properly
class API {
    
    typealias Callback = (result: Result) -> Void
    typealias JSON     = [String : AnyObject]
    
    // MARK: - Login
    private static let LoginEndpointURL = NSURL(string: "\(baseurl)/v1/login")!
    
    class func login(username: String, password: String, callback: Callback) {
        let params = ["username" : username, "password" : password]
        Alamofire.request(.POST, LoginEndpointURL, parameters: params).responseJSON { (response) in
            if let json = response.result.value as? JSON {
                print(json)
                callback(result: .Success)
            } else {
                callback(result: .Failed)
            }
        }
    }
    
    // MARK: - Upvote
    private static let UpvoteEndpointURL = NSURL(string: "\(baseurl)/v1/login/upvote")!
    
    class func upvote(id: Int, callback: (result: Result) -> Void) {
        Alamofire.request(.POST, UpvoteEndpointURL, parameters: nil).responseJSON { (response) in
            if let json = response.result.value as? JSON {
                print(json)
                callback(result: .Success)
            } else {
                callback(result: .Failed)
            }
        }
    }
    
    // MARK: - Submission 
    // MARK:   Link
    private static let SubmissionEndpointURL = NSURL(string: "\(baseurl)/v1/submit/link")!
    
    class func submit(title: String, url: String, callback: Callback) {
        Alamofire.request(.POST, SubmissionEndpointURL).responseJSON { (response) in
            if let json = response.result.value as? JSON {
                print(json)
                callback(result: .Success)
            } else {
                callback(result: .Failed)
            }
        }
    }
    
    // MARK:   Question
    
}
