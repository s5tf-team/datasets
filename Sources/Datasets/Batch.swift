protocol S5TFBatch {}

struct S5TFUnlabeledBatch: S5TFBatch {
    var data: Float { get }
}

struct S5TFLabeledBatch: S5TFBatch {
    var data: Int { get }
    var labels: Int { get }
}
