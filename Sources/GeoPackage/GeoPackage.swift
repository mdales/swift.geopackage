import Foundation
import SQLite

public enum GeoPackageError: Error {
    case MalformattedDataType(String)
    case MalformattedGeometryType(String)
    case NoResultsFound
    case TooManyResults
}

public struct GeometryColumn {
    let TableName: String
    let ColumnName: String
    let GeometryType: GeometryType
    let SRSID: Int
    let Z: Int  // should be an enum one day
    let M: Int // should be an enum one day
}

public struct GeoPackage {
    let path: String
    let db: Connection

    public init(_ path: String) throws {
        self.path = path
        self.db = try Connection(path)
    }

    public func getLayers() throws -> [Layer] {
        let table = Table("gpkg_contents")
        let name = Expression<String>("table_name")
        let data_type = Expression<String>("data_type")
        let srs_id = Expression<Int>("srs_id")

        return try db.prepare(table).map {
            let datatypestr = $0[data_type]
            guard let datatype = LayerDataType.init(rawValue: datatypestr) else {
                throw GeoPackageError.MalformattedDataType(datatypestr)
            }
            return Layer(
                name: $0[name],
                dataType: datatype,
                SRSID: $0[srs_id]
            )
        }
    }

    public func getFeaturesForLayer(layer: Layer) throws -> [Feature] {
        let table = Table(layer.name)
        let fid = Expression<Int>("fid")
        return try db.prepare(table).map {
            return Feature(
                layer: layer,
                fid: $0[fid]
            )
        }
    }

    public func getGeometryForFeature(feature: Feature) -> Geometry {
        return Geometry()
    }

    func getGeometryColumn(layer: Layer) throws -> GeometryColumn {
        let table = Table("gpkg_geometry_columns")
        let name = Expression<String>("table_name")
        let column = Expression<String>("column_name")
        let geo_type = Expression<String>("geometry_type_name")
        let srs_id = Expression<Int>("srs_id")
        let z = Expression<Int>("z")
        let m = Expression<Int>("m")

        let filter = table.filter(name == layer.name)
        let result = try db.pluck(filter)
        guard let result = result else {
            throw GeoPackageError.NoResultsFound
        }
        let geotypestr = result[geo_type]
        guard let geotype = GeometryType.init(rawValue: geotypestr) else {
            throw GeoPackageError.MalformattedGeometryType(geotypestr)
        }
        return GeometryColumn(
            TableName: result[name],
            ColumnName: result[column],
            GeometryType: geotype,
            SRSID: result[srs_id],
            Z: result[z],
            M: result[m]
        )
    }
}
