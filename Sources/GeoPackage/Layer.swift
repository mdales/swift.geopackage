import Foundation

public enum LayerDataType: String {
	case Features = "features"
	case Tiles = "tiles"
	case Attributes = "attributes"
}

public struct Layer {
	let name: String
	let dataType: LayerDataType
	let SRSID: Int
}
