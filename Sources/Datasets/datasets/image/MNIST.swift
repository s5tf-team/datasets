struct MNISTBatch: S5TFLabeledBatch {
    var data: Int
    var labels: Int
}

struct MNIST: S5TFDataset {
    typealias _Iterator = MNISTIterator // swiftlint:disable:this type_name
    let data = [[1, 2], [3, 4], [5, 6]]
    func batched(_ batchSize: Int) -> MNISTIterator {
        return MNISTIterator(dataset: self)
    }
}

struct MNISTIterator: S5TFDatasetIterator {
    var dataset: MNIST

    var count = 0

    mutating func next() -> MNISTBatch? {
        guard count < dataset.data.count else { return nil }
        let data = dataset.data[count]
        count += 1
        return MNISTBatch(data: data[0], labels: data[1])
    }
}
