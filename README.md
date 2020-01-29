# Datasets

`Datasets` is a collection of ready-to-use `S5TFDataLoader`s.

## Documentation

Datasets can be loaded in just a **single line of code**:

```swift
Iris.train
```

To loop over batches, use `batched()`:

```swift
for batch in Iris.train.batched(32) {
  print(batch.data, batch.labels)
}
```

View an interactive Google Colab example [here](https://colab.research.google.com/github/s5tf-team/examples/blob/master/Iris_Classification_S5TF.ipynb).

## Contributing ❤️
Thanks for even considering contributing.

Make sure to run [`swiftlint`](https://github.com/realm/SwiftLint) on your code. If you are not sure about how to format something, refer to the [Google Swift Style Guide](https://google.github.io/swift/).

Please link to the completed GitHub Actions `build` test in your fork with your PR.
