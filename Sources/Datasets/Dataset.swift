protocol S5TFDataset {
    associatedtype _Iterator // swiftlint:disable:this type_name
    func batched(_ batchSize: Int) -> _Iterator
    var split : S5TFSplit { get }
    var info: S5TFDatasetInfo { get }
}

protocol S5TFDatasetIterator: Sequence, IteratorProtocol where _Dataset: S5TFDataset {
    associatedtype _Dataset // swiftlint:disable:this type_name
}

public struct S5TFDatasetInfo {
    var name: String
    var version: String
    var description: String
    var homepage: String
    var citation: String?
}

public enum S5TFSplit {
    case train
    case validation
    case test
    case all
    case undefined
}
