#!/bin/sh

echo "Converting 4 band TIF to single band TIF"
# rgb2pct.py -pct "pct-palette.vrt" "merged.tif" "merged-pct.tif"
rgb2pct.py "merged.tif" "merged-pct.tif"
echo "Extracting polygons"
gdal_polygonize.py -overwrite "merged-pct.tif" "bombdamage.shp" bombdamage colorcode
echo "Filtering out background"
ogr2ogr -where "\"colorcode\" != 2" bombdamage-filtered.shp bombdamage.shp

