import XCTest
@testable import GeoPackage

final class GeoPackageTests: XCTestCase {

    func testEmpyPackage() throws {
        let url = Bundle.module.url(
            forResource: "empty",
            withExtension: "gpkg")!
        let package = try GeoPackage(url.path)
        XCTAssertEqual(try package.getLayers().count, 0, "Expected no layers")
    }

    func testSimplePackage() throws {
        let url = Bundle.module.url(
            forResource: "simple",
            withExtension: "gpkg")!
        let package = try GeoPackage(url.path)

        let layers = try package.getLayers()
        XCTAssertEqual(layers.count, 1, "Expected one layer")

        let features = try package.getFeaturesForLayer(layer: layers.first!)
        XCTAssertEqual(features.count, 1, "Expected one feature")

        let geometry = try package.getGeometryForFeature(feature: features.first!)
        XCTAssertEqual(geometry.type, .Point, "Expected point")
        XCTAssertEqual(geometry.envelope.count, 0, "Expected just x,y envelope")
        XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")
    }

    func testMultiFeaturePackage() throws {
        let url = Bundle.module.url(
            forResource: "multiple_features",
            withExtension: "gpkg")!
        let package = try GeoPackage(url.path)

        let layers = try package.getLayers()
        XCTAssertEqual(layers.count, 1, "Expected one layer")

        let features = try package.getFeaturesForLayer(layer: layers.first!)
        XCTAssertEqual(features.count, 2, "Expected two features")

        for feature in features {
            let geometry = try package.getGeometryForFeature(feature: feature)
            XCTAssertEqual(geometry.type, .Point, "Expected point")
            XCTAssertEqual(geometry.envelope.count, 0, "Expected just x,y envelope")
            XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")
        }
    }

    func testPolygonPackage() throws {
        // contains a rectangular polygon of bounds (-12.5, 10.3) to (-11.6, -5.4)

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
        XCTAssertEqual(geometry.envelope, [-12.5, -11.6, -5.4, 10.3, 0.0, 0.0], "Expected x,y,z envelope")
        XCTAssertEqual(geometry.srs_id, 4326, "Unexpected SRS ID")


    }
}
