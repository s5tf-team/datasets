# Datasets

## Documentation

Loading MNIST:

```swift
for batch in MNIST.train.batched(32) {
    print(batch.data, batch.labels)
}
```
View an interactive Google Colab example [here](https://colab.research.google.com/github/s5tf-team/examples/blob/master/Iris_Classification_S5TF.ipynb).

## Contributing ❤️
Thanks for even considering contributing.

Make sure to run [`swiftlint`](https://github.com/realm/SwiftLint) on your code. If you are not sure about how to format something, refer to the [Google Swift Style Guide](https://google.github.io/swift/).

Please link to the completed GitHub Actions `build` test in your fork with your PR.
