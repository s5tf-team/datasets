// The Breast Cancer dataset.
//
// Features are computed from a digitized image of a fine needle
// aspirate (FNA) of a breast mass.  They describe
// characteristics of the cell nuclei present in the image.
// A few of the images can be found at
// http://www.cs.wisc.edu/~street/images/
//
// Separating plane described above was obtained using
// Multisurface Method-Tree (MSM-T) [K. P. Bennett, "Decision Tree
// Construction Via Linear Programming." Proceedings of the 4th
// Midwest Artificial Intelligence and Cognitive Science Society,
// pp. 97-101, 1992], a classification method which uses linear
// programming to construct a decision tree.  Relevant features
// were selected using an exhaustive search in the space of 1-4
// features and 1-3 separating planes.
//
// The actual linear program used to obtain the separating plane
// in the 3-dimensional space is that described in:
// [K. P. Bennett and O. L. Mangasarian: "Robust Linear
// Programming Discrimination of Two Linearly Inseparable Sets",
// Optimization Methods and Software 1, 1992, 23-34].
//
// This database is also available through the UW CS ftp server:
//
// ftp ftp.cs.wisc.edu
// cd math-prog/cpo-dataset/machine-learn/WDBC/
//
// Attribute Information:
// 1) ID number 
// 2) Diagnosis (M = malignant, B = benign) 
// 3-32) 
// 
// Ten real-valued features are computed for each cell nucleus: 
// 
// a) radius (mean of distances from center to points on the perimeter) 
// b) texture (standard deviation of gray-scale values) 
// c) perimeter 
// d) area 
// e) smoothness (local variation in radius lengths) 
// f) compactness (perimeter^2 / area - 1.0) 
// g) concavity (severity of concave portions of the contour) 
// h) concave points (number of concave portions of the contour) 
// i) symmetry 
// j) fractal dimension ("coastline approximation" - 1)
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

public struct BreastCancer: S5TFDataset {
    typealias DataLoader = CSVDataLoader
    public static var train: CSVDataLoader<S5TFCategoricalBatch> {
        let localURL = Downloader.download(
            fileAt: URL(string: "https://archive.ics.uci.edu/ml/machine-learning-databases/" +
                                "breast-cancer-wisconsin/breast-cancer-wisconsin.data")!,
            cacheName: "breast-cancer",
            fileName: "breast-cancer.csv"
        )

        guard localURL != nil else {
            fatalError("File not downloaded correctly.")
        }

        return CSVDataLoader<S5TFCategoricalBatch>(
            fromFileAt: localURL!.absoluteString,
            columnNames: ["id number",
                          "Clump Thickness",
                          "Uniformity of Cell Size",
                          "Uniformity of Cell Shape",
                          "Marginal Adhesion",
                          "Single Epithelial Cell Size",
                          "Bare Nuclei",
                          "Bland Chromatin",
                          "Normal Nucleoli",
                          "Mitoses",
                          "Class"],
            inputColumnNames: ["Clump Thickness",
                                "Uniformity of Cell Size",
                                "Uniformity of Cell Shape",
                                "Marginal Adhesion",
                                "Single Epithelial Cell Size",
                                "Bare Nuclei",
                                "Bland Chromatin",
                                "Normal Nucleoli",
                                "Mitoses"],
            outputColumnNames: ["Class"] // 2 for malignant, 4 for benign.
        )
    }

    public static let info = breastCancerInfo
    public static let numberOfTrainingExamples = 150
    public static let numberOfFeatures = 4

    private init() {}
}

// swiftlint:disable:next private_over_fileprivate
fileprivate let breastCancerInfo = S5TFDatasetInfo(
    name: "Breast Cancer",
    version: "0.0.1",
    description: """
    Features are computed from a digitized image of a fine needle
    aspirate (FNA) of a breast mass.  They describe
    characteristics of the cell nuclei present in the image.
    A few of the images can be found at
    http://www.cs.wisc.edu/~street/images/

    Separating plane described above was obtained using
    Multisurface Method-Tree (MSM-T) [K. P. Bennett, "Decision Tree
    Construction Via Linear Programming." Proceedings of the 4th
    Midwest Artificial Intelligence and Cognitive Science Society,
    pp. 97-101, 1992], a classification method which uses linear
    programming to construct a decision tree.  Relevant features
    were selected using an exhaustive search in the space of 1-4
    features and 1-3 separating planes.

    The actual linear program used to obtain the separating plane
    in the 3-dimensional space is that described in:
    [K. P. Bennett and O. L. Mangasarian: "Robust Linear
    Programming Discrimination of Two Linearly Inseparable Sets",
    Optimization Methods and Software 1, 1992, 23-34].


    This database is also available through the UW CS ftp server:

    ftp ftp.cs.wisc.edu
    cd math-prog/cpo-dataset/machine-learn/WDBC/
    """,
    homepage: URL(string: "http://archive.ics.uci.edu/ml")!,
    numberOfTrainExamples: 150,
    numberOfValidExamples: 0,
    numberOfTestExamples: 0,
    numberOfFeatures: 4
)
