import Foundation

import BinaryCoder
import SQLite

public enum GeometryType: String {
	// Core types (Table 30)
	case Geometry = "GEOMETRY"
	case Point = "POINT"
	case LineString = "LINESTRING"
	case Polygon = "POLYGON"
	case MultiPoint = "MULTIPOINT"
	case MultiString = "MULTISTRING"
	case MultiPolygon = "MULTIPOLYGON"
	case GeometryCollection = "GEOMETRYCOLLECTION"

	// Extension types (Table 31)
	case CircularString = "CIRCULARSTRING"
	case CompoundCurve = "COMPOUNDCURVE"
	case CurvePolygon = "CURVEPOLYGON"
	case MultiCurve = "MULTICURVE"
	case MultiSurface = "MULTISURFACE"
	case Curve = "CURVE"
	case Surface = "SURFACE"
}

struct GeoPackageBinaryHeader: Codable {
	let magic: UInt16
	let version: UInt8
	let flags: UInt8
	let srs_id: Int32
}

enum GeometryError: Error {
	case DataTooSmallForHeader
	case DataTooSmallForEnvelope
	case MissingHeaderMagic
	case BigEndianNotSupported
	case NotImplementedYet
	case EnvelopeTypeInvalid(UInt8)
}

public struct Geometry {
	let type: GeometryType
	let srs_id: Int
	let envelope: [Double]

	let geometry: WKBBase

	init(type: GeometryType, rawbytes: Blob) throws {
		self.type = type

		let header_size = MemoryLayout<GeoPackageBinaryHeader>.size
		guard rawbytes.bytes.count >= header_size else {
			throw GeometryError.DataTooSmallForHeader
		}
		let data = Data(rawbytes.bytes)
		let decoder = BinaryDecoder()
		let header = try decoder.decode(GeoPackageBinaryHeader.self, from: data)
		guard header.magic == 0x4750 else {
			throw GeometryError.MissingHeaderMagic
		}

		guard header.flags & 0x1 == 0x1 else {
			throw GeometryError.BigEndianNotSupported
		}
		// Erm, this isn't what I expected given the preceding code
		self.srs_id = Int(Int32(bigEndian: header.srs_id))

		let envelope_type = (header.flags >> 1) & 0x7
		var envelope_size = 0
		switch envelope_type {
		case 0:
			break
		case 1:
			envelope_size = 32
		case 2:
			envelope_size = 48
		case 3:
			envelope_size = 48
		case 4:
			envelope_size = 64
		default:
			throw GeometryError.EnvelopeTypeInvalid(envelope_type)
		}

		if envelope_size > 0 {
			guard rawbytes.bytes.count >= (header_size + envelope_size) else {
				throw GeometryError.DataTooSmallForEnvelope
			}
			let buffer = UnsafeMutableBufferPointer<Double>.allocate(capacity: envelope_size / 8)
			rawbytes.bytes[header_size..<(header_size+envelope_size)].copyBytes(to: buffer)
			self.envelope = Array(buffer)
		} else {
			self.envelope = []
		}

		if header.flags & 0x10 == 0x00 {
			// now the envelope is out the way, load the actual geometry
			let payload = Data(rawbytes.bytes[header_size+envelope_size..<rawbytes.bytes.count])
			self.geometry = try loadGeometryFromData(payload)
		} else {
			throw GeometryError.NotImplementedYet
		}

	}
}
