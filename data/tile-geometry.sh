#!/bin/sh

# this file provides basic geometric information of the WMS data at
# https://data.gv.at/katalog/dataset/87282445-a02d-4f7f-9bf6-196d73d9b3a9
# which allows the data to be retrieved and processed in bulk. it merely
# defines local variables 

FORMAT=jpeg # what format to download the raw data in, one of jpeg, gif, png

# the projection that the data should be retrieved in
PROJ=EPSG:31256

## extent of the relevant data in projection coordinates, determined by eyeballing
# bottom left corner (of scanned paper): -5495.46 / 334255.26
# east end: 9716.12
# north end: 349453.096
## the underlying data was scanned from individual paper sheets, which provide
## a natural grid for us to download individual tiles 
# width: 15211.58 (~32451px) -- 8 sheets a 1901 units / 4056px
# height: 15197.836 (~32422px) -- 10 sheets a 1520 units / 3242px

## origin and individual sheet/tile width in map coordinates
X0=-5495.46
Y0=334255.26
DX=1901.45
DY=1519.8

# desired tile size in pixels
TILEWIDTH=4056
TILEHEIGHT=3242

## desired kernel for ImageMagick's Close operation
# (see http://www.imagemagick.org/Usage/morphology/#close)
# which is used as a first step in the data cleaning process (see create-tiles.sh)
KERNEL=Disk:9.3
# the kernel is defined here because the appropriate kernel size depends on the
# resolution of the data, i.e. when changing TILEWIDTH and TILEHEIGHT, the kernel
# should be changed accordingly


## as can be seen from a global overview of the raw WMS data:
# https://data.wien.gv.at/daten/wms?request=GetMap&version=1.1.1&width=2000&height=2000&layers=BOMBENSCHADENOGD&styles=&format=image/jpeg&bbox=-5495.46,334255.26,9716.12,349453.096&srs=EPSG:31256
# the data set is not rectangular, with some of the sheets missing or simply left
# out. this array lists all the positions where sheets (i.e. data) exists in the
# form COLUMN-ROW, starting at column 0 and row 0 in the bottom left corner.
TILES=(00 01 02 03 11 12 13 16 17 21 22 23 24 25 26 27 31 32 33 34 35 36 37 41 42 43 44 45 46 47 51 52 53 54 55 56 57 58 59 61 62 63 65 66 67 68 73 77)
