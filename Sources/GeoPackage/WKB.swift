import Foundation

import BinaryCoder

enum WKBError: Error {
	case NotEnoughData
	case TypeNotRecognised(UInt32)
	case EndianNotSupprted(WKBByteOrder)
	case NotImplemented(WKBGeometryType)
}


// Each geometry struct has a fixed preeamble to declare the type
// and byte order
public enum WKBByteOrder: UInt8, Codable {
	case BigEndian = 0
	case LittleEndian = 1
};

public enum WKBGeometryType: UInt32, Codable {
	case Point = 1
	case LineString = 2
	case Polygon = 3
	case MultiPoint = 4
	case MultiLineString = 5
	case MultiPolygon = 6
	case GeometryCollection = 7

	case PointZ = 1001
	case LineStringZ = 1002
	case PolygonZ = 1003
	case MultiPointZ = 1004
	case MultiLineStringZ = 1005
	case MultiPolygonZ = 1006
	case GeometryCollectionZ = 1007

	case PointM = 2001
	case LineStringM = 2002
	case PolygonM = 2003
	case MultiPointM = 2004
	case MultiLineStringM = 2005
	case MultiPolygonM = 2006
	case GeometryCollectionM = 2007

	case PointZM = 3001
	case LineStringZM = 3002
	case PolygonZM = 3003
	case MultiPointZM = 3004
	case MultiLineStringZM = 3005
	case MultiPolygonZM = 3006
	case GeometryCollectionZM = 3007

	public init(from decoder: Decoder) throws {
		// This is a bodge for now - the data stream is little endian,
		// but if you read it from fixed memory image then it ends up
		// big endian
		let container = try decoder.singleValueContainer()
		let val: UInt32 = try container.decode(UInt32.self)
		let swapped = UInt32(bigEndian: val)
		guard let t = WKBGeometryType(rawValue: swapped) else {
			throw WKBError.TypeNotRecognised(swapped)
		}
		self = t
	}
}

public protocol WKBBase {
	var byteOrder: WKBByteOrder { get }
	var type: WKBGeometryType { get }
}

struct WKBPreamble: WKBBase, Codable {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType
}

// Basic data types used in the structs
public struct Point {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let x: Double
	public let y: Double
}

public struct LinearRing {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numPoints: UInt32
	public let points: [Point]
}

// The actual geometry definitions
public struct WKBPoint: WKBBase {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let point: Point
}

public struct WKBLineString: WKBBase {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numPoints: UInt32
	public let points: [Point]
}

public struct WKBPolygon: WKBBase {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numRings: UInt32
	public let rings: [LinearRing]
}

public struct WKBMultiPoint: WKBBase {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numWkbPoints: UInt32
	public let WKBPoints: [WKBPoint]
}

public struct WKBMultiLineString: WKBBase {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numWkbLineStrings: UInt32
	public let WKBLineStrings: [WKBLineString]
}

public struct WKBMultiPolygon: WKBBase {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numWkbPolygons: UInt32;
	public let wkbPolygons: [WKBPolygon]
}

public struct WKBGeometryCollection: WKBBase {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numWkbGeometries: UInt32
	public let wkbGeometries: [WKBBase]
}


public func loadGeometryFromData(_ data: Data) throws -> WKBBase {
	guard data.count >= MemoryLayout<WKBPreamble>.size else {
		throw WKBError.NotEnoughData
	}
	let decoder = BinaryDecoder()
	let header = try decoder.decode(WKBPreamble.self, from: data)

	guard header.byteOrder == .LittleEndian else {
		throw WKBError.EndianNotSupprted(header.byteOrder)
	}

	switch header.type {
	default:
		throw WKBError.NotImplemented(header.type)
	}

	return header
}
