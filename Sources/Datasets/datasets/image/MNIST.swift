public struct MNISTBatch: S5TFLabeledBatch {
    public var data: Int
    public var labels: Int
}

public struct MNIST: S5TFDataset {
    typealias _Iterator = MNISTIterator // swiftlint:disable:this type_name
    internal let data = [[1, 2], [3, 4], [5, 6]]
    public func batched(_ batchSize: Int) -> MNISTIterator {
        return MNISTIterator(dataset: self)
    }
}

public struct MNISTIterator: S5TFDatasetIterator {
    typealias _Dataset = MNIST // swiftlint:disable:this type_name
    private var dataset: MNIST

    private var index = 0

    public init(dataset: MNIST) {
        self.dataset = dataset
    }

    mutating public func next() -> MNISTBatch? {
        guard index < dataset.data.count else { return nil }
        let data = dataset.data[index]
        index += 1
        return MNISTBatch(data: data[0], labels: data[1])
    }
}
