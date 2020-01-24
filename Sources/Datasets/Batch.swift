protocol S5TFBatch {}

public struct S5TFUnlabeledBatch: S5TFBatch {
    var data: Float
}

public struct S5TFLabeledBatch: S5TFBatch {
    var data: Int
    var labels: Int
}
