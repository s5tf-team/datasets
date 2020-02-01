// The Iris dataset.
//
// This is perhaps the best known database to be found in the pattern recognition
// literature. Fisher's paper is a classic in the field and is referenced
// frequently to this day. (See Duda & Hart, for example.) The data set contains
// 3 classes of 50 instances each, where each class refers to a type of iris
// plant. One class is linearly separable from the other 2; the latter are NOT
// linearly separable from each other.
// 
// BibTeX citation:
// @misc{Dua:2019,
//     author = "Dua, Dheeru and Graff, Casey",
//     year = "2017",
//     title = "{UCI} Machine Learning Repository",
//     url = "http://archive.ics.uci.edu/ml",
//     institution = "University of California, Irvine, School of Information and Computer Sciences"
// }

import Foundation
import S5TF
import TensorFlow

public struct Iris: S5TFDataset {
    typealias DataLoader = CSVDataLoader
    public static var train: CSVDataLoader<S5TFCategoricalBatch> {
        guard let localURL = Downloader.download(
            fileAt: URL(string: "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data")!,
            cacheName: "iris",
            fileName: "iris.csv"
        ) else {
            fatalError("File not downloaded correctly.")
        }

        return CSVDataLoader<S5TFCategoricalBatch>(
            fromFileAt: localURL.absoluteString,
            columnNames: ["sepal length in cm",
                          "sepal width",
                          "petal length",
                          "petal width",
                          "species"],
            inputColumnNames: ["sepal length in cm",
                               "sepal width",
                               "petal length",
                               "petal width"],
            outputColumnNames: ["species"]
        )
    }

    public static let info = irisInfo
    public static let numberOfTrainingExamples = 150
    public static let numberOfFeatures = 4

    private init() {}
}

// swiftlint:disable:next private_over_fileprivate
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
    homepage: URL(string: "http://archive.ics.uci.edu/ml")!,
    numberOfTrainExamples: 150,
    numberOfValidExamples: 0,
    numberOfTestExamples: 0,
    numberOfFeatures: 4
)
