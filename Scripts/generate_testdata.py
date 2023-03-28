from dataclasses import dataclass

from osgeo import ogr

@dataclass
class Area:
	left: float
	top: float
	right: float
	bottom: float


def make_empty():
	point = ogr.Geometry(ogr.wkbPoint)
	point.FlattenTo2D()
	srs = ogr.osr.SpatialReference()
	srs.ImportFromEPSG(4326)

	package = ogr.GetDriverByName("GPKG").CreateDataSource('empty.gpkg')
	package.Destroy()


def make_simple_point():
	point = ogr.Geometry(ogr.wkbPoint)
	point.FlattenTo2D()
	srs = ogr.osr.SpatialReference()
	srs.ImportFromEPSG(4326)

	package = ogr.GetDriverByName("GPKG").CreateDataSource('simple.gpkg')
	layer = package.CreateLayer("onlylayer", srs, geom_type=ogr.wkbPoint)
	id_field = ogr.FieldDefn("id_no", ogr.OFTInteger)
	layer.CreateField(id_field)

	point = ogr.Geometry(ogr.wkbPoint)
	point.AddPoint_2D(2.0, 3.0)
	feature_definition = layer.GetLayerDefn()
	feature = ogr.Feature(feature_definition)
	feature.SetGeometry(point)
	feature.SetField("id_no", 42)
	layer.CreateFeature(feature)

	package.Destroy()

def make_simple_polygon():
	poly = ogr.Geometry(ogr.wkbPolygon)
	poly.FlattenTo2D()
	srs = ogr.osr.SpatialReference()
	srs.ImportFromEPSG(4326)

	areas = [
		Area(
			left=-12.3,
			top=10.2,
			right=-11.5,
			bottom=-5.4
		)
	]

	for area in areas:
		geometry = ogr.Geometry(ogr.wkbLinearRing)
		geometry.AddPoint_2D(area.left, area.top)
		geometry.AddPoint_2D(area.right, area.top)
		geometry.AddPoint_2D(area.right, area.bottom)
		geometry.AddPoint_2D(area.left, area.bottom)
		geometry.AddPoint_2D(area.left, area.top)
		poly.AddGeometry(geometry)

	package = ogr.GetDriverByName("GPKG").CreateDataSource('polygon.gpkg')
	layer = package.CreateLayer("onlylayer", srs, geom_type=ogr.wkbPolygon)
	id_field = ogr.FieldDefn("id_no", ogr.OFTInteger)
	layer.CreateField(id_field)

	feature_definition = layer.GetLayerDefn()
	feature = ogr.Feature(feature_definition)
	feature.SetGeometry(poly)
	feature.SetField("id_no", 42)
	layer.CreateFeature(feature)

	package.Destroy()

def make_multiple_features():
	point = ogr.Geometry(ogr.wkbPoint)
	point.FlattenTo2D()
	srs = ogr.osr.SpatialReference()
	srs.ImportFromEPSG(4326)

	package = ogr.GetDriverByName("GPKG").CreateDataSource('multiple_features.gpkg')
	layer = package.CreateLayer("onlylayer", srs, geom_type=ogr.wkbPoint)
	id_field = ogr.FieldDefn("id_no", ogr.OFTInteger)
	layer.CreateField(id_field)

	point = ogr.Geometry(ogr.wkbPoint)
	point.AddPoint_2D(2.0, 3.0)
	feature_definition = layer.GetLayerDefn()
	feature = ogr.Feature(feature_definition)
	feature.SetGeometry(point)
	feature.SetField("id_no", 42)
	layer.CreateFeature(feature)

	point = ogr.Geometry(ogr.wkbPoint)
	point.AddPoint_2D(-2.0, -3.0)
	feature_definition = layer.GetLayerDefn()
	feature = ogr.Feature(feature_definition)
	feature.SetGeometry(point)
	feature.SetField("id_no", 43)
	layer.CreateFeature(feature)

	package.Destroy()

if __name__ == "__main__":
	make_empty()
	make_simple_point()
	make_simple_polygon()
	make_multiple_features()
