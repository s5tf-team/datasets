import Foundation

protocol S5TFDataLoader: Sequence, IteratorProtocol {
    func batched(_ batchSize: UInt) -> Self
    func shuffled() -> Self
}

protocol S5TFDataset where DataLoader: S5TFDataLoader {
    associatedtype DataLoader
    static var info: S5TFDatasetInfo { get }
    static var train: DataLoader { get }
    static var validation: DataLoader { get }
}

public struct S5TFDatasetInfo {
    var name: String
    var version: String
    var description: String
    var homepage: URL
}
