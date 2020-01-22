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
    typealias _Dataset = MNIST // swiftlint:disable:this type_name
    var dataset: MNIST

    private var index = 0

    init(dataset: MNIST) {
        self.dataset = dataset
    }

    mutating func next() -> MNISTBatch? {
        guard index < dataset.data.count else { return nil }
        let data = dataset.data[index]
        index += 1
        return MNISTBatch(data: data[0], labels: data[1])
    }
}
