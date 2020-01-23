# Datasets

## Documentation

Loading MNIST:

```swift
let mnist = MNIST()
for batch in mnist.batched(32) {
    print(batch.data, batch.labels)
}
```

## Contributing ❤️
Thanks for even considering contributing.

Make sure to run [`swiftlint`](https://github.com/realm/SwiftLint) on your code. If you are not sure about how to format something, refer to the [Google Swift Style Guide](https://google.github.io/swift/).

Please link to the completed GitHub Actions `build` test in your fork with your PR.
