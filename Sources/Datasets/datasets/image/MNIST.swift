import Foundation
import S5TF
import TensorFlow

public struct MNIST: S5TFDataset {
    typealias DataLoader = MNISTDataLoader

    public static var train: MNISTDataLoader {
        return MNISTDataLoader(split: .train)
    }
    public static var test: MNISTDataLoader {
        return MNISTDataLoader(split: .test)
    }

    public static let info = mnistInfo

    private init() {}
}

fileprivate let mnistInfo = S5TFDatasetInfo(
    name: "mnist",
    version: "0.0.1",
    description: "The MNIST database of handwritten digits. 60000 train examples and 10000 test examples with image and label features.",
    homepage: URL(string: "http://yann.lecun.com/exdb/mnist/")!,
    numberOfTrainExamples: 60000,
    numberOfValidExamples: 0,
    numberOfTestExamples: 10000,
    numberOfFeatures: 10
)

public struct MNISTDataLoader: S5TFDataLoader {
    private var index = 0
    public let count: Int

    public let batchSize: Int?
    private let data: Tensor<Float>
    private let labels: Tensor<Int32>

    private init(data: Tensor<Float>, labels: Tensor<Int32>, batchSize: Int? = nil) {
        self.data = data
        self.labels = labels
        self.batchSize = batchSize
        self.count = data.shape.dimensions.first!
    }

    public init(split: S5TFSplit) {
        let baseURL = URL(string: "https://storage.googleapis.com/cvdf-datasets/mnist")!
        let dataURL: URL
        let labelsURL: URL

        switch split {
            case .train:
                dataURL = S5TFUtils.downloadAndExtract(remoteURL: baseURL.appendingPathComponent("train-images-idx3-ubyte.gz"),
                                                       cacheName: "mnist", fileName: "train-images.gz")!
                labelsURL = S5TFUtils.downloadAndExtract(remoteURL: baseURL.appendingPathComponent("train-labels-idx1-ubyte.gz"),
                                                         cacheName: "mnist", fileName: "train-labels.gz")!
            case .test:
                dataURL = S5TFUtils.downloadAndExtract(remoteURL: baseURL.appendingPathComponent("t10k-images-idx3-ubyte.gz"),
                                                       cacheName: "mnist", fileName: "test-images.gz")!
                labelsURL = S5TFUtils.downloadAndExtract(remoteURL: baseURL.appendingPathComponent("t10k-labels-idx1-ubyte.gz"),
                                                         cacheName: "mnist", fileName: "test-labels.gz")!
            default:
                fatalError("Split does not exist for this dataset.")
        }

        let rawData = [UInt8](try! Data(contentsOf: URL(string: "file://" + dataURL.absoluteString)!)).dropFirst(16).map(Float.init)
        let rawLabels = [UInt8](try! Data(contentsOf: URL(string: "file://" + labelsURL.absoluteString)!)).dropFirst(8).map(Int32.init)

        let dataTensor = Tensor<Float>(shape: [rawLabels.count, 28 * 28], scalars: rawData) / 255.0
        let labelsTensor = Tensor<Int32>(rawLabels)

        self.init(data: dataTensor, labels: labelsTensor)
    }

    public func batched(_ batchSize: Int) -> MNISTDataLoader {
        return MNISTDataLoader(data: self.data,
                               labels: self.labels,
                               batchSize: batchSize)
    }

    public mutating func next() -> S5TFCategoricalBatch? {
        guard let batchSize = batchSize else {
            fatalError("This data loader does not have a batch size. Set a batch size by calling `.batched(...)`")
        }

        guard index < (count - 1) else {
            return nil
        }

        let thisBatchSize = Swift.min(count - index, batchSize)

        var batchFeatures = [Float]()
        var batchLabels = [Int32]()

        for i in index..<(index + thisBatchSize) {
            batchFeatures.append(contentsOf: data[i].scalars)
            batchLabels.append(contentsOf: labels[i].scalars)
        }

        let data = Tensor<Float>(batchFeatures).reshaped(to: TensorShape(thisBatchSize, 28 * 28))
        let labels = Tensor<Int32>(batchLabels)

        self.index += thisBatchSize

        return S5TFCategoricalBatch(data: data, labels: labels)
    }
}
