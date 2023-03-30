import XCTest

import SQLite

@testable import GeoPackage

final class GeoPackageTests: XCTestCase {

    func testEmpyPackage() throws {
        let url = Bundle.module.url(
            forResource: "empty",
            withExtension: "gpkg")!
        let package = try GeoPackage(url.path)
        XCTAssertEqual(try package.getLayers().count, 0, "Expected no layers")
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

    func testFilterFeaturesHit() throws {
        let url = Bundle.module.url(
            forResource: "multiple_features",
            withExtension: "gpkg")!
        let package = try GeoPackage(url.path)
        let layer = try package.getLayers().first!

        let column = layer.columns["id_no"] as! Expression<String>
        let features = try package.getFeaturesForLayer(layer: layer, predicate: column == "42")
        XCTAssertEqual(features.count, 1, "Expected single result hit")
    }

    func testFilterFeaturesMiss() throws {
        let url = Bundle.module.url(
            forResource: "multiple_features",
            withExtension: "gpkg")!
        let package = try GeoPackage(url.path)
        let layer = try package.getLayers().first!

        let column = layer.columns["id_no"] as! Expression<String>
        let features = try package.getFeaturesForLayer(layer: layer, predicate: column == "foo")
        XCTAssertEqual(features.count, 0, "Expected single result hit")
    }

}
