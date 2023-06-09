import XCTest
@testable import GeoPackage

final class GeometryTests: XCTestCase {

	func testPointPackage() throws {
		let url = Bundle.module.url(
			forResource: "simple",
			withExtension: "gpkg")!
		let package = try GeoPackage(url.path)

		let layers = try package.getLayers()
		XCTAssertEqual(layers.count, 1, "Expected one layer")

		let layer = layers.first!
		XCTAssertEqual(layer.name, "onlylayer")
		XCTAssertEqual(layer.columns.count, 3)

		let features = try package.getFeaturesForLayer(layer: layer)
		XCTAssertEqual(features.count, 1, "Expected one feature")

		let geometry = try package.getGeometryForFeature(feature: features.first!)
		XCTAssertEqual(geometry.type, .Point, "Expected point")
		XCTAssertEqual(geometry.envelope.count, 0, "Expected just x,y envelope")
		XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")

		XCTAssertEqual(geometry.geometry.type, .Point, "Expected a point")
		let point = geometry.geometry as! WKBPoint
		XCTAssertEqual(point.type, .Point, "Also expected point")
		XCTAssertEqual(point.point, Point(x: 2.0, y: 3.0), "Unexpected point value")
	}

	func testMultiPointPackage() throws {
		let url = Bundle.module.url(
			forResource: "multi_point",
			withExtension: "gpkg")!
		let package = try GeoPackage(url.path)

		let layers = try package.getLayers()
		XCTAssertEqual(layers.count, 1, "Expected one layer")

		let features = try package.getFeaturesForLayer(layer: layers.first!)
		XCTAssertEqual(features.count, 1, "Expected one feature")

		let geometry = try package.getGeometryForFeature(feature: features.first!)
		XCTAssertEqual(geometry.type, .MultiPoint, "Expected multipoint")
		XCTAssertEqual(geometry.envelope, [-12.3, -11.5, -5.4, 10.2], "Expected x,y envelope")
		XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")

		XCTAssertEqual(geometry.geometry.type, .MultiPoint, "Expected a multipoint")
		let multipoint = geometry.geometry as! WKBMultiPoint
		XCTAssertEqual(multipoint.type, .MultiPoint, "Also expected polygon")
		XCTAssertEqual(multipoint.numWkbPoints, 4, "Expected four points")
		XCTAssertEqual(Int(multipoint.numWkbPoints), multipoint.WKBPoints.count, "Internal consistency error for points")

		let expectedPoints = [
			Point(x: -12.3, y: 10.2),
			Point(x: -11.5, y: 10.2),
			Point(x: -11.5, y: -5.4),
			Point(x: -12.3, y: -5.4)
		]
		XCTAssertEqual(multipoint.WKBPoints.map { $0.point }, expectedPoints, "Points don't match")
	}

	func testPolygonPackage() throws {
		let url = Bundle.module.url(
			forResource: "polygon",
			withExtension: "gpkg")!
		let package = try GeoPackage(url.path)

		let layers = try package.getLayers()
		XCTAssertEqual(layers.count, 1, "Expected one layer")

		let features = try package.getFeaturesForLayer(layer: layers.first!)
		XCTAssertEqual(features.count, 1, "Expected one feature")

		let geometry = try package.getGeometryForFeature(feature: features.first!)
		XCTAssertEqual(geometry.type, .Polygon, "Expected polygon")
		XCTAssertEqual(geometry.envelope, [-12.3, -11.5, -5.4, 10.2], "Expected x,y envelope")
		XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")

		XCTAssertEqual(geometry.geometry.type, .Polygon, "Expected a polygon")
		let polygon = geometry.geometry as! WKBPolygon
		XCTAssertEqual(polygon.type, .Polygon, "Also expected polygon")
		XCTAssertEqual(polygon.numRings, 1, "Expected one ring")
		XCTAssertEqual(Int(polygon.numRings), polygon.rings.count, "Internal consistency error for rings")

		let ring = polygon.rings[0]
		XCTAssertEqual(ring.numPoints, 5, "Expected 5 points")
		XCTAssertEqual(Int(ring.numPoints), ring.points.count, "Internal consistncy error for ring points")


		let expectedPoints = [
			Point(x: -12.3, y: 10.2),
			Point(x: -11.5, y: 10.2),
			Point(x: -11.5, y: -5.4),
			Point(x: -12.3, y: -5.4),
			Point(x: -12.3, y: 10.2)
		]
		XCTAssertEqual(ring.points, expectedPoints, "Points don't match")
	}

	func testMultiPolygonPackage() throws {
		let url = Bundle.module.url(
			forResource: "multi_polygon",
			withExtension: "gpkg")!
		let package = try GeoPackage(url.path)

		let layers = try package.getLayers()
		XCTAssertEqual(layers.count, 1, "Expected one layer")

		let features = try package.getFeaturesForLayer(layer: layers.first!)
		XCTAssertEqual(features.count, 1, "Expected one feature")

		let geometry = try package.getGeometryForFeature(feature: features.first!)
		XCTAssertEqual(geometry.type, .MultiPolygon, "Expected multi polygon")
		XCTAssertEqual(geometry.envelope, [-12.3, 45.6, -42.1, 10.2], "Expected x,y envelope")
		XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")

		XCTAssertEqual(geometry.geometry.type, .MultiPolygon, "Expected a multi polygon")
		let polygon = geometry.geometry as! WKBMultiPolygon
		XCTAssertEqual(polygon.type, .MultiPolygon, "Also expected multi polygon")
		XCTAssertEqual(polygon.numWkbPolygons, 2, "Expected two polygons")
		XCTAssertEqual(Int(polygon.numWkbPolygons), polygon.wkbPolygons.count, "Internal consistency error for polygons")
	}

	func testLineStringPackage() throws {
		let url = Bundle.module.url(
			forResource: "linestring",
			withExtension: "gpkg")!
		let package = try GeoPackage(url.path)

		let layers = try package.getLayers()
		XCTAssertEqual(layers.count, 1, "Expected one layer")

		let features = try package.getFeaturesForLayer(layer: layers.first!)
		XCTAssertEqual(features.count, 1, "Expected one feature")

		let geometry = try package.getGeometryForFeature(feature: features.first!)
		XCTAssertEqual(geometry.type, .LineString, "Expected linestring")
		XCTAssertEqual(geometry.envelope, [-12.3, -11.5, -5.4, 10.2], "Expected x,y envelope")
		XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")

		XCTAssertEqual(geometry.geometry.type, .LineString, "Expected a linestring")
		let linestring = geometry.geometry as! WKBLineString
		XCTAssertEqual(linestring.type, .LineString, "Also expected linestring")
		XCTAssertEqual(linestring.numPoints, 4, "Expected one ring")
		XCTAssertEqual(Int(linestring.numPoints), linestring.points.count, "Internal consistency error for points")

		let expectedPoints = [
			Point(x: -12.3, y: 10.2),
			Point(x: -11.5, y: 10.2),
			Point(x: -11.5, y: -5.4),
			Point(x: -12.3, y: -5.4)
		]
		XCTAssertEqual(linestring.points, expectedPoints, "Points don't match")
	}

	func testMultiLineStringPackage() throws {
		let url = Bundle.module.url(
			forResource: "multi_linestring",
			withExtension: "gpkg")!
		let package = try GeoPackage(url.path)

		let layers = try package.getLayers()
		XCTAssertEqual(layers.count, 1, "Expected one layer")

		let features = try package.getFeaturesForLayer(layer: layers.first!)
		XCTAssertEqual(features.count, 1, "Expected one feature")

		let geometry = try package.getGeometryForFeature(feature: features.first!)
		XCTAssertEqual(geometry.type, .MultiLineString, "Expected multi linestring")
		XCTAssertEqual(geometry.envelope, [-12.3, 45.6, -42.1, 10.2], "Expected x,y envelope")
		XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")

		XCTAssertEqual(geometry.geometry.type, .MultiLineString, "Expected a linestring")
		let multi_linestring = geometry.geometry as! WKBMultiLineString
		XCTAssertEqual(multi_linestring.type, .MultiLineString, "Also expected linestring")
		XCTAssertEqual(multi_linestring.numWkbLineStrings, 2, "Expected two linestrings")
		XCTAssertEqual(Int(multi_linestring.numWkbLineStrings), multi_linestring.WKBLineStrings.count, "Internal consistency error for linestrings")

	}
}
