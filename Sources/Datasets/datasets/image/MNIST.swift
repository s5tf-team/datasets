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

        let semaphore = DispatchSemaphore(value: 0)
        let baseURL = "https://storage.googleapis.com/cvdf-datasets/mnist"
        var dataURL: URL? = nil
        var labelURL: URL? = nil

        print("Fetching files... Waiting for the download to finish before continuing...")
        let downloader = Downloader()

        #if os(macOS)
            let binaryLocation = "/usr/bin/"
        #else
            let binaryLocation = "/bin/"
        #endif

        switch split {
            case .train:
                downloader.download(fileAt: URL(string: baseURL + "/train-images-idx3-ubyte.gz")!,
                                      cacheName: "mnist", fileName: "mnist_train_images") { url, err in
                                      guard let url = url else {
                                      fatalError("Data not downloaded.")
                                      }
                                      dataURL = url
                                      semaphore.signal()
                                    }
                semaphore.wait()
                do {
                    try S5TFUtils.shell(URL(string: binaryLocation + "gunzip")!, ".s5tf-datasets/mnist/mnist_train_images")
                }
                catch {
                    fatalError("Extract command not executed.")
                }
                downloader.download(fileAt: URL(string: baseURL + "/train-labels-idx1-ubyte.gz")!,
                                      cacheName: "mnist", fileName: "mnist_train_labels") { url, err in
                                      guard let url = url else {
                                      fatalError("Data not downloaded.")
                                      }
                                      labelURL = url
                                      semaphore.signal()
                                    }
                semaphore.wait()
                do {
                    try S5TFUtils.shell(URL(string: binaryLocation + "gunzip")!, ".s5tf-datasets/mnist/mnist_train_labels")
                }
                catch {
                    fatalError("Extract command not executed.")
                }
            case .test:
                downloader.download(fileAt: URL(string: baseURL + "/t10k-images-idx3-ubyte.gz")!,
                                      cacheName: "mnist", fileName: "mnist_test_images") { url, err in
                                      guard let url = url else {
                                      fatalError("Data not downloaded.")
                                      }
                                      dataURL = url
                                      semaphore.signal()
                                    }
                semaphore.wait()
                do {
                    try S5TFUtils.shell(URL(string: binaryLocation + "gunzip")!, ".s5tf-datasets/mnist/mnist_test_images")
                }
                catch {
                    fatalError("Extract command not executed.")
                }
                downloader.download(fileAt: URL(string: baseURL + "/t10k-labels-idx1-ubyte.gz")!,
                                      cacheName: "mnist", fileName: "mnist_test_labels") { url, err in
                                      guard let url = url else {
                                      fatalError("Data not downloaded.")
                                      }
                                      labelURL = url
                                      semaphore.signal()
                                    }
                semaphore.wait()
                do {
                    try S5TFUtils.shell(URL(string: binaryLocation + "gunzip")!, ".s5tf-datasets/mnist/mnist_test_labels")
                }
                catch {
                    fatalError("Extract command not executed.")
                }
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
        self.init(split: split, batchSize: 0)
    }

    public func batched(_ batchSize: Int) -> MNISTDataLoader {
        return MNISTDataLoader(batchSize: batchSize,
                               data: self.data,
                               labels: self.labels)
        )
    }
}
