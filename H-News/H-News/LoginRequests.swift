
import Foundation
import Alamofire

class Login {
    
    static let LoginEndpointURL = NSURL(string: "https://h-news.herokuapp.com/v1/login")!
    
    class func login(username: String, password: String, callback: (success: Bool) -> ()) {
        let params = ["username" : username, "password" : password]
        Alamofire.request(.POST, LoginEndpointURL, parameters: params).responseJSON { (response) in
            var success = false
            if let json = response.result.value as? [String:AnyObject] {
                print(json)
                success = true
            }
            callback(success: success)
        }
    }
}