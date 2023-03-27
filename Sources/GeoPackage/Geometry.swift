

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

public struct Geometry {
}