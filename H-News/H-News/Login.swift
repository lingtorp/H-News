import Alamofire

/// TODO: Implement all of the login functionality 
let baseurl = "https://h-news.herokuapp.com"

enum Result {
    case success, loginRequired, noInternet
}

class Login {
    
    fileprivate static let LoginEndpointURL = URL(string: "\(baseurl)/v1/login")!

    class func login(_ username: String, password: String, callback: @escaping (_ success: Bool) -> Void) {
        let params = ["username" : username, "password" : password]
        Alamofire.request(LoginEndpointURL).responseJSON { (response) in
            var success = false
            if let json = response.result.value as? [String:AnyObject] {
                print(json)
                success = true
            }
            callback(success)
        }
    }
    
    fileprivate static let UpvoteEndpointURL = URL(string: "\(baseurl)/v1/login/upvote")!
    
    class func upvote(_ id: Int, callback: (_ result: Result) -> Void) {

    
    }
}
