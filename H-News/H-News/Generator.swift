
/// The Generator provides a interface to a possibly infinite datastream which is fetched in batches
protocol GeneratorType {
    associatedtype Element
    associatedtype FetchNextBatch
    mutating func next(_ batchSize: Int, _ fetchNextBatch: FetchNextBatch?, onFinish: (([Element]) -> Void)?)
    /// Resets the Generators' position in the datastream. Starts from the beginning again.
    func reset()
}

class Generator<T>: GeneratorType {
    typealias Element = T
    typealias FetchNextBatch = (_ offset: Int, _ batchSize: Int, _ onCompletion: @escaping (_ result: [Element]) -> Void) -> Void
    
    fileprivate var batchSize: Int
    fileprivate var offset   : Int
    
    init(offset: Int = 0, batchSize: Int = 25) {
        self.offset = offset
        self.batchSize = batchSize
    }
    
    func next(_ batchSize: Int, _ fetchNextBatch: FetchNextBatch?, onFinish: (([Element]) -> Void)?) {
        fetchNextBatch?(offset, batchSize) { [unowned self] (items) in
            self.offset += items.count
            Dispatcher.main { onFinish?(items) }
        }
    }
    
    func reset() {
        offset = 0
    }
}
