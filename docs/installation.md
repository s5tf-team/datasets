# Installation

This guide shows how to install S5TF Datasets.

## Google Colab
The preferred way to use this repository is through Google Colab. Run the following code in the first cell:

```swift
%install-location $cwd/swift-install
%install '.package(url: "https://github.com/s5tf-team/datasets", .branch("master"))' Datasets
```

## Swift Package
To use this repository in a project you can use the Swift Package Manager.

Add the following line to `dependencies` in your `Package.swift` file:

```swift
.package(url: "https://github.com/s5tf-team/datasets", .branch("master"))
```

Then add `"Datasets"` as a dependency to a target:

```swift
dependencies: ["Datasets"]
```
