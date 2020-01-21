protocol S5TFDataset {
    associatedtype _Iterator // swiftlint:disable:this type_name
    func batched(_ batchSize: Int) -> _Iterator
}

protocol S5TFDatasetIterator: Sequence, IteratorProtocol {}
