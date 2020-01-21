# Datasets

## Documentation

Loading MNIST:

```swift
let mnist = MNIST()
for batch in mnist.batched(32) {
    print(batch.data, batch.labels)
}
```