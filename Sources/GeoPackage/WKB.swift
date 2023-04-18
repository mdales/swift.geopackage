import Foundation

import BinaryCoder

enum WKBError: Error {
	case NotEnoughData
	case TypeNotRecognised(UInt32)
	case EndianNotSupprted(WKBByteOrder)
	case NotImplemented(WKBGeometryType)
	case DecodingWrongType(got: WKBGeometryType, expected: WKBGeometryType)
}


// Each geometry struct has a fixed preeamble to declare the type
// and byte order
public enum WKBByteOrder: UInt8, Decodable {
	case BigEndian = 0
	case LittleEndian = 1
};

public enum WKBGeometryType: UInt32, Decodable {
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

struct WKBPreamble: WKBBase, Decodable {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType
}

func byteSwapDouble(_ val: Double) -> Double {
#if canImport(Darwin)
	let swapped = CFSwappedFloat64(v: val.bitPattern.littleEndian)
	return CFConvertDoubleSwappedToHost(swapped)
#else
	var temp = val // can't get withUnsafeBytes on a const
	var swapped: Double = 0.0
	withUnsafeMutableBytes(of: &swapped) { outptr in
		withUnsafeBytes(of: &temp) { inptr in
			for index in 0..<MemoryLayout<Double>.size {
				outptr[MemoryLayout<Double>.size - (index + 1)] = inptr[index]
			}
		}
	}
	return swapped
#endif
}

// Basic data types used in the structs
public struct Point: Decodable, Equatable {
	public let x: Double
	public let y: Double

	public init(x: Double, y: Double) {
		self.x = x
		self.y = y
	}

	public init(from decoder: Decoder) throws {
		// The data is meant to be streamed, rather than disk-read, which
		// means the bytes are the wrong way around
		var container = try decoder.unkeyedContainer()
		let tempx = try container.decode(Double.self)
		self.x = byteSwapDouble(tempx)
		let tempy = try container.decode(Double.self)
		self.y = byteSwapDouble(tempy)
	}
}

public struct LinearRing: Decodable {
	public let numPoints: UInt32
	public let points: [Point]

	public init(_ points: [Point]) {
		self.numPoints = UInt32(points.count)
		self.points = points
	}

	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		self.numPoints = try container.decode(UInt32.self).byteSwapped

		var points: [Point] = []
		for _ in 0..<self.numPoints {
			let point = try container.decode(Point.self)
			points.append(point)
		}
		self.points = points
	}
}

// The actual geometry definitions
public struct WKBPoint: WKBBase, Decodable {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let point: Point

	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()

		self.byteOrder = try container.decode(WKBByteOrder.self)
		self.type = try container.decode(WKBGeometryType.self)
		guard self.type == .Point else {
			throw WKBError.DecodingWrongType(got: self.type, expected: .Point)
		}

		self.point = try container.decode(Point.self)
	}
}

public struct WKBLineString: WKBBase, Decodable {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numPoints: UInt32
	public let points: [Point]

	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()

		self.byteOrder = try container.decode(WKBByteOrder.self)
		self.type = try container.decode(WKBGeometryType.self)
		guard self.type == .LineString else {
			throw WKBError.DecodingWrongType(got: self.type, expected: .LineString)
		}

		self.numPoints = try container.decode(UInt32.self).byteSwapped

		var points: [Point] = []
		for _ in 0..<self.numPoints {
			let point = try container.decode(Point.self)
			points.append(point)
		}
		self.points = points
	}
}

public struct WKBPolygon: WKBBase, Decodable {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numRings: UInt32
	public let rings: [LinearRing]

	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()

		self.byteOrder = try container.decode(WKBByteOrder.self)
		self.type = try container.decode(WKBGeometryType.self)
		guard self.type == .Polygon else {
			throw WKBError.DecodingWrongType(got: self.type, expected: .Polygon)
		}

		self.numRings = try container.decode(UInt32.self).byteSwapped

		var rings: [LinearRing] = []
		for _ in 0..<self.numRings {
			let ring = try container.decode(LinearRing.self)
			rings.append(ring)
		}
		self.rings = rings
	}
}

public struct WKBMultiPoint: WKBBase, Decodable {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numWkbPoints: UInt32
	public let WKBPoints: [WKBPoint]

	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()

		self.byteOrder = try container.decode(WKBByteOrder.self)
		self.type = try container.decode(WKBGeometryType.self)
		guard self.type == .MultiPoint else {
			throw WKBError.DecodingWrongType(got: self.type, expected: .MultiPoint)
		}

		self.numWkbPoints = try container.decode(UInt32.self).byteSwapped

		var points: [WKBPoint] = []
		for _ in 0..<self.numWkbPoints {
			let point = try container.decode(WKBPoint.self)
			points.append(point)
		}
		self.WKBPoints = points
	}
}

public struct WKBMultiLineString: WKBBase, Decodable {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numWkbLineStrings: UInt32
	public let WKBLineStrings: [WKBLineString]

	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()

		self.byteOrder = try container.decode(WKBByteOrder.self)
		self.type = try container.decode(WKBGeometryType.self)
		guard self.type == .MultiLineString else {
			throw WKBError.DecodingWrongType(got: self.type, expected: .MultiLineString)
		}

		self.numWkbLineStrings = try container.decode(UInt32.self).byteSwapped

		var lines: [WKBLineString] = []
		for _ in 0..<self.numWkbLineStrings {
			let line = try container.decode(WKBLineString.self)
			lines.append(line)
		}
		self.WKBLineStrings = lines
	}
}

public struct WKBMultiPolygon: WKBBase, Decodable {
	public let byteOrder: WKBByteOrder
	public let type: WKBGeometryType

	public let numWkbPolygons: UInt32;
	public let wkbPolygons: [WKBPolygon]

	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()

		self.byteOrder = try container.decode(WKBByteOrder.self)
		self.type = try container.decode(WKBGeometryType.self)
		guard self.type == .MultiPolygon else {
			throw WKBError.DecodingWrongType(got: self.type, expected: .MultiPolygon)
		}

		self.numWkbPolygons = try container.decode(UInt32.self).byteSwapped

		var polygons: [WKBPolygon] = []
		for _ in 0..<self.numWkbPolygons {
			let polygon = try container.decode(WKBPolygon.self)
			polygons.append(polygon)
		}
		self.wkbPolygons = polygons
	}
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
	case .Point:
		return try decoder.decode(WKBPoint.self, from: data)
	case .Polygon:
		return try decoder.decode(WKBPolygon.self, from: data)
	case .LineString:
		return try decoder.decode(WKBLineString.self, from: data)
	case .MultiPoint:
		return try decoder.decode(WKBMultiPoint.self, from: data)
	case .MultiPolygon:
		return try decoder.decode(WKBMultiPolygon.self, from: data)
	case .MultiLineString:
		return try decoder.decode(WKBMultiLineString.self, from: data)
	default:
		throw WKBError.NotImplemented(header.type)
	}
}
