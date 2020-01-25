import Foundation

protocol S5TFDataLoader: Sequence, IteratorProtocol {
    var batchSize: Int { get }
    var split: S5TFSplit { get }
    func batched(_ batchSize: Int) -> Self
    init(split: S5TFSplit, batchSize: Int)
}

protocol S5TFDataset where DataLoader: S5TFDataLoader {
    associatedtype DataLoader
    static var info: S5TFDatasetInfo { get }
    static var train: DataLoader { get }
}

public enum S5TFSplit {
    case train
    case validation
    case test
}

public struct S5TFDatasetInfo {
    var name: String
    var version: String
    var description: String
    var homepage: URL
}
