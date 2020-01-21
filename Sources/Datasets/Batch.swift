protocol S5TFBatch {}

protocol S5TFUnlabeledBatch: S5TFBatch {
    var data: Float { get }
}

protocol S5TFLabeledBatch: S5TFBatch {
    var data: Int { get }
    var labels: Int { get }
}
