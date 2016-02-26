
import Foundation

/// Wrapper around Grand Central Dispatch (GCD) to make it more Swift-like.
class Dispatcher {
    /// Takes a block/closure and executes it on the main queue after a delay in seconds
    class func delay(delay: Double, closure: () -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /// Takes a block/closure and executes it on a background queue (QOS_CLASS_UTILITY) with low prio after a delay in seconds
    class func delayAsync(delay: Double, closure: () -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), closure)
    }
    
    /// Takes a block/closure and executes it on a high-prio background queue
    class func async(closure: () -> ()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), closure)
    }
    
    /// Takes a block/closure and executes it on the main queue
    class func main(closure: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), closure)
    }
}