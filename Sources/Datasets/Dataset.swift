protocol S5TFDataset {
    associatedtype _Iterator // swiftlint:disable:this type_name
    func batched(_ batchSize: Int) -> _Iterator
    var info: S5TFDatasetInfo { get }
}

protocol S5TFDatasetIterator: Sequence, IteratorProtocol where _Dataset: S5TFDataset {
    associatedtype _Dataset // swiftlint:disable:this type_name
}

public struct S5TFDatasetInfo {
	var name = ""
	var version = ""
	var description = ""
	var homepage = ""
	var citation = ""
	public init(name: String = "", version: String = "", description: String = "", homepage: String = "", citation: String = "") {
		self.name = name
		self.version = version
		self.description = description
		self.homepage = homepage
		self.citation = citation
	}
}
