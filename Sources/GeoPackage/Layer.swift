import Foundation

import SQLite

public enum LayerDataType: String {
	case Features = "features"
	case Tiles = "tiles"
	case Attributes = "attributes"
}

public struct Layer {
	public let name: String
	public let dataType: LayerDataType
	public let SRSID: Int

	public let columns: [String:any ExpressionType]
}
