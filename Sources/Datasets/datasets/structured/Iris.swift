/// The Iris dataset.
///
/// This is perhaps the best known database to be found in the pattern recognition
/// literature. Fisher's paper is a classic in the field and is referenced
/// frequently to this day. (See Duda & Hart, for example.) The data set contains
/// 3 classes of 50 instances each, where each class refers to a type of iris
/// plant. One class is linearly separable from the other 2; the latter are NOT
/// linearly separable from each other.
/// 
/// BibTeX citation:
/// @misc{Dua:2019,
///     author = "Dua, Dheeru and Graff, Casey",
///     year = "2017",
///     title = "{UCI} Machine Learning Repository",
///     url = "http://archive.ics.uci.edu/ml",
///     institution = "University of California, Irvine, School of Information and Computer Sciences"
/// }

import Foundation
import S5TF
import TensorFlow

public struct Iris: S5TFDataset {
    typealias DataLoader = IrisDataLoader
    public static var train: IrisDataLoader {
        get {
            return IrisDataLoader()
        }
    }

    public static var info = irisInfo
    public static let numberOfTrainingExamples = 150
    public static let numberOfFeatures = 4

    private init() {}
}

fileprivate let irisInfo = S5TFDatasetInfo(
    name: "Iris",
    version: "0.0.1",
    description: """
    This is perhaps the best known database to be found in the pattern recognition
    literature. Fisher's paper is a classic in the field and is referenced
    frequently to this day. (See Duda & Hart, for example.) The data set contains
    3 classes of 50 instances each, where each class refers to a type of iris
    plant. One class is linearly separable from the other 2; the latter are NOT
    linearly separable from each other.
    """,
    homepage: URL(string: "http://archive.ics.uci.edu/ml")!
)

public struct IrisDataLoader: S5TFDataLoader {
    private var index = 0

    let batchSize: Int
    let data: Tensor<Float>
    let labels: Tensor<Int32>

    // MARK: - Initializers.
    private init(batchSize: Int) {
        self.batchSize = batchSize

        // Download necessary files.
        let semaphore = DispatchSemaphore(value: 0)
        var csvUrl: URL? = nil
        print("Fetching files... Waiting for the download to finish before continuing...")
        Downloader().download(fileAt: URL(string: "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data")!,
            cacheName: "iris", fileName: "iris.csv") { url, err in
            guard let url = url else {
                fatalError("URL not saved.")
            }
            csvUrl = url
            semaphore.signal()
        }
        semaphore.wait()

        // Load data.
        let rawData = try! String(contentsOfFile: csvUrl!.absoluteString)
        // Use a flattened array because Swift does not support 2 dimensional arrays for initialization.
        var XValues = [Float]()
        var yValues = [Int32]()
        for line in rawData.split(separator: "\n") {
        let items = line.split(separator: ",")
            // Load features.
            // TOOD: use broadcasting when it's available.
            for j in 0...3 {
                XValues.append(Float(items[j])!)
            }

            // Load labels.
            switch items[4] {
            case "Iris-setosa": yValues.append(0)
            case "Iris-versicolor": yValues.append(1)
            case "Iris-virginica": yValues.append(2)
            default: fatalError("Unkown label: \(items[4])")
            }
        }

        // Convert so Swift Tensors and store on self.
        self.data = Tensor<Float>(XValues).reshaped(to: TensorShape(Iris.numberOfTrainingExamples, Iris.numberOfFeatures))
        self.labels = Tensor<Int32>(yValues)
    }

    private init(batchSize: Int, data: Tensor<Float>, labels: Tensor<Int32>) {
        self.batchSize = batchSize
        self.data = data
        self.labels = labels
    }

    public init() {
        self.init(batchSize: 1)
    }

    // MARK: Data loaders
    public func batched(_ batchSize: Int) -> IrisDataLoader {
        return IrisDataLoader(batchSize: 1,
                              data: self.data,
                              labels: self.labels)
    }

    // MARK: - Iterator
    public mutating func next() -> S5TFLabeledBatch? {
        guard index < (Iris.numberOfTrainingExamples - 1) else {
            return nil
        }
        // Use a partial batch is fewer items than the batch size are available.
        let thisBatchSize = Swift.min(Iris.numberOfTrainingExamples - index - batchSize, batchSize)

        // TODO: update with broadcoasting.
        var batchX = [Float]()
        var batchy = [Int32]()

        for i in index..<(index + thisBatchSize) {
            for j in data[i].array {
                batchX.append(j.scalar!)
            }
            batchy.append(labels[i].scalar!)
        }

        let data = Tensor<Float>(batchX).reshaped(to: TensorShape(thisBatchSize, Iris.numberOfFeatures))
        let labels = Tensor<Int32>(batchy)

        self.index += thisBatchSize

        return S5TFLabeledBatch(data: data, labels: labels)
    }
}
