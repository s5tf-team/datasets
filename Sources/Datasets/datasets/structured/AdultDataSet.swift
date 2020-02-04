// The Adult Data Set.
//
// Extraction was done by Barry Becker from the 1994 Census database. A set of reasonably clean records
// was extracted using the following conditions: ((AAGE>16) && (AGI>100) && (AFNLWGT>1)&& (HRSWK>0)) 
//
// Prediction task is to determine whether a person makes over 50K a year. 
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

public struct AdultDataSet: S5TFDataset {
    typealias DataLoader = CSVDataLoader
    public static var train: CSVDataLoader<S5TFCategoricalBatch> {
        guard let localURL = Downloader.download(
            fileAt: URL(string: "http://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data")!,
            cacheName: "adult-dataset",
            fileName: "adult-dataset.csv"
        ) else {
            fatalError("File not downloaded correctly.")
        }

        return CSVDataLoader<S5TFCategoricalBatch>(
            fromFileAt: localURL.absoluteString,
            columnNames: ["age",
                          "workclass",
                          "fnlwgt",
                          "education",
                          "education-num",
                          "marital-status",
                          "occupation",
                          "relationship",
                          "race",
                          "sex",
                          "capital-gain",
                          "capital-loss",
                          "hours-per-week",
                          "native-country",
                          "income"],
            inputColumnNames: ["age",
                               "workclass",
                               "fnlwgt",
                               "education",
                               "education-num",
                               "marital-status",
                               "occupation",
                               "relationship",
                               "race",
                               "sex",
                               "capital-gain",
                               "capital-loss",
                               "hours-per-week",
                               "native-country"],
            outputColumnNames: ["income"]
        )
    }

    public static let info = adultDataSetInfo
    public static let numberOfTrainingExamples = 48842
    public static let numberOfFeatures = 15

    private init() {}
}

// swiftlint:disable:next private_over_fileprivate
fileprivate let adultDataSetInfo = S5TFDatasetInfo(
    name: "Adult Data set",
    version: "0.0.1",
    description: """
    Extraction was done by Barry Becker from the 1994 Census database. A set of reasonably clean records
    was extracted using the following conditions: ((AAGE>16) && (AGI>100) && (AFNLWGT>1)&& (HRSWK>0))
    """,
    homepage: URL(string: "http://archive.ics.uci.edu/ml/datasets/Adult")!,
    numberOfTrainExamples: 48842,
    numberOfValidExamples: 0,
    numberOfTestExamples: 0,
    numberOfFeatures: 15
)
