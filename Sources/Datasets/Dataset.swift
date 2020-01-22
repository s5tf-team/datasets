protocol S5TFDataset {
    associatedtype _Iterator // swiftlint:disable:this type_name
    func batched(_ batchSize: Int) -> _Iterator
}

protocol S5TFDatasetIterator: Sequence, IteratorProtocol where _Dataset: S5TFDataset {
    associatedtype _Dataset // swiftlint:disable:this type_name
}
