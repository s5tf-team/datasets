import TensorFlow

public protocol S5TFBatch {}

public struct S5TFUnlabeledBatch: S5TFBatch {

}

public struct S5TFLabeledBatch: S5TFBatch {

}
