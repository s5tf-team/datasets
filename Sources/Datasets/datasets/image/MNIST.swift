import Foundation
import S5TF
import TensorFlow

public struct MNIST: S5TFDataset {
    typealias DataLoader = MNISTDataLoader
    public static var train: MNISTDataLoader {
        get {
            return MNISTDataLoader(split: .train)
        }
    }
    public static var test: MNISTDataLoader {
        get {
            return MNISTDataLoader(split: .test)
        }
    }

    public static var info = mnistInfo

    private init() {}
}

fileprivate let mnistInfo = S5TFDatasetInfo(
    name: "mnist",
    version: "0.0.1",
    description: "The MNIST database of handwritten digits. 60000 train examples and 10000 test examples with image and label features.",
    homepage: URL(string: "http://yann.lecun.com/exdb/mnist/")!,
    numTrain: 60000,
    numTest: 10000,
    numFeatures: 10
)

public struct MNISTDataLoader: S5TFDataLoader {
    private var index = 0

    let split: S5TFSplit
    let batchSize: Int
    let data: Tensor<UInt8>
    let labels: Tensor<Int64>

    internal init(split: S5TFSplit, batchSize: Int) {
        self.batchSize = batchSize
        self.split = split

        let baseURL = "https://storage.googleapis.com/cvdf-datasets/mnist"
        var dataURL: URL? = nil
        var labelURL: URL? = nil

        print("Fetching files...")
        switch split {
            case .train:
                dataURL = S5TFUtils.downloadAndExtract(remoteURL: URL(string: baseURL + "/train-images-idx3-ubyte.gz")!,
                                                       cacheName: "mnist", fileName: "mnist_train_images")!
                labelURL = S5TFUtils.downloadAndExtract(remoteURL: URL(string: baseURL + "/train-labels-idx1-ubyte.gz")!,
                                                        cacheName: "mnist", fileName: "mnist_train_labels")!
            case .test:
                dataURL = S5TFUtils.downloadAndExtract(remoteURL: URL(string: baseURL + "/t10k-images-idx3-ubyte.gz")!,
                                                       cacheName: "mnist", fileName: "mnist_test_images")!
                labelURL = S5TFUtils.downloadAndExtract(remoteURL: URL(string: baseURL + "/t10k-labels-idx1-ubyte.gz")!,
                                                        cacheName: "mnist", fileName: "mnist_test_labels")!
            default:
                fatalError("Split does not exist for this dataset.")
        }
    }

    private init(batchSize: Int, data: Tensor<UInt8>, labels: Tensor<Int64>) {
        self.batchSize = batchSize
        self.data = data
        self.labels = labels
    }

    public init(split: S5TFSplit) {
        self.init(split: split, batchSize: nil)
    }

    public func batched(_ batchSize: Int) -> MNISTDataLoader {
        return MNISTDataLoader(batchSize: batchSize,
                               data: self.data,
                               labels: self.labels)
        )
    }
}
