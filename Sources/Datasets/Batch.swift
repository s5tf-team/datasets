import TensorFlow

public protocol S5TFBatch {}

public struct S5TFUnlabeledBatch: S5TFBatch {
    var data: Float
}

public struct S5TFLabeledBatch: S5TFBatch {
    var data: Tensor<Float>
    var labels: Tensor<Int32>
}
