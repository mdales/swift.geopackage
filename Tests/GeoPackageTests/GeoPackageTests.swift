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
    }
}
