import Foundation

/// Wrapper around Grand Central Dispatch (GCD) to make it more Swift-like.
class Dispatcher {
    /// Takes a block/closure and executes it on the main queue after a delay in seconds
    class func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    /// Takes a block/closure and executes it on a background queue (QOS_CLASS_UTILITY) with low prio after a delay in seconds
    class func delayAsync(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    /// Takes a block/closure and executes it on a high-prio background queue
    class func async(_ closure: @escaping () -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: closure)
    }
    
    /// Takes a block/closure and executes it on the main queue
    class func main(_ closure: @escaping () -> ()) {
        DispatchQueue.main.async(execute: closure)
    }
}
