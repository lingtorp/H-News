import Alamofire

let baseurl = "https://h-news.herokuapp.com"

enum Result {
    case Success, LoginRequired, NoInternet
}

class Login {
    
    private static let LoginEndpointURL = NSURL(string: "\(baseurl)/v1/login")!
    
    class func login(username: String, password: String, callback: (success: Bool) -> Void) {
        let params = ["username" : username, "password" : password]
        Alamofire.request(.POST, LoginEndpointURL, parameters: params).responseJSON { (response) in
            var success = false
            if let json = response.result.value as? [String : AnyObject] {
                print(json)
                success = true
            }
            callback(success: success)
        }
    }
    
    private static let UpvoteEndpointURL = NSURL(string: "\(baseurl)/v1/login/upvote")!
    
    class func upvote(id: Int, callback: (result: Result) -> Void) {
        Alamofire.request(.POST, UpvoteEndpointURL, parameters: nil).responseJSON { (response) in
            if let json = response.result.value as? [String : AnyObject] {
                print(json)
            }
            callback(result: .Success)
        }
    }
}