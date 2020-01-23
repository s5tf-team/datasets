import Foundation

public struct MNISTBatch: S5TFLabeledBatch {
    public var data: Int
    public var labels: Int
}

fileprivate let MNISTInfo = S5TFDatasetInfo(
    name: "mnist",
    version: "0.0.1",
    description: "The MNIST database of handwritten digits. 60000 train examples and 10000 test examples with image and label features.",
    homepage: "http://yann.lecun.com/exdb/mnist/",
    citation: """
    @article{lecun2010mnist,
      title={MNIST handwritten digit database},
      author={LeCun, Yann and Cortes, Corinna and Burges, CJ},
      journal={ATT Labs [Online]. Available: http://yann.lecun.com/exdb/mnist},
      volume={2},
      year={2010}
    }
    """)

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

public struct MNIST: S5TFDataset {
    typealias _Iterator = MNISTIterator // swiftlint:disable:this type_name

    internal var data = [[1, 2], [3, 4], [5, 6]]

    public func batched(_ batchSize: Int) -> MNISTIterator {
        return MNISTIterator(dataset: self)
    }

    public var train: MNIST {
        guard self.split == .undefined else { fatalError("This property can only be accessed from an undefined split.") }
        return MNIST(split: .train)
    }
    public var validation: MNIST {
        fatalError("The split does not exist for this dataset.")
    }
    public var test: MNIST {
        guard self.split == .undefined else { fatalError("This property can only be accessed from an undefined split.") }
        return MNIST(split: .test)
    }
    public var all: MNIST {
        guard self.split == .undefined else { fatalError("This property can only be accessed from an undefined split.") }
        return MNIST(split: .all)
    }

    public let split: S5TFSplit
    
    public init() { self.split = .undefined }
    private init(split: S5TFSplit) {
        self.split = split
        let downloader = Downloader()
        func getTrain() {
            downloader.download(fileAt: URL(string: "https://storage.googleapis.com/cvdf-datasets/mnist/train-images-idx3-ubyte.gz")!,
            					cacheName: "mnist", fileName: "mnist_train_images") { url, error in }
            downloader.download(fileAt: URL(string: "https://storage.googleapis.com/cvdf-datasets/mnist/train-labels-idx1-ubyte.gz")!,
            					cacheName: "mnist", fileName: "mnist_train_labels") { url, error in }
        }
        func getTest() {
            downloader.download(fileAt: URL(string: "https://storage.googleapis.com/cvdf-datasets/mnist/t10k-images-idx3-ubyte.gz")!,
            					cacheName: "mnist", fileName: "mnist_test_images") { url, error in }
            downloader.download(fileAt: URL(string: "https://storage.googleapis.com/cvdf-datasets/mnist/t10k-labels-idx1-ubyte.gz")!,
            					cacheName: "mnist", fileName: "mnist_test_labels") { url, error in }
        }
        switch split {
            case .train:
                getTrain()
            case .test:
                getTest()
            case .all:
                getTrain()
                getTest()
            default:
                break            
        }
    }

    public var info = MNISTInfo
}
