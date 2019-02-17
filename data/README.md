# Data retrieval, processing and tile creation

## Underlying data

The underlying data set is based on the [Kriegsschädenplan](https://www.geschichtewiki.wien.gv.at/Kriegsschädenplan_(um_1946)) documenting war damage to buildings in Vienna that was compiled [under unknown circumstances](https://www.geschichtewiki.wien.gv.at/Kriegssch%C3%A4denplan_(um_1946)#Entstehung) in (or shortly after) 1946. The original data consists of 48 sheets of the Generalstadtplan ([original digitalisation available from WAIS](https://www.wien.gv.at/actaproweb2/benutzung/archive.xhtml?id=Akt+++++00000651m08alt#Akt_____00000651m08alt)) that were colour-coded by hand to signify different types of damage. As can be seen from [the legend at the top of the sheets](https://www.wien.gv.at/actaproweb2/benutzung/image.xhtml?id=TwKSo67xQgUqg55JnK2TO+M0+8OkdD4Jp25sfgC2ACs1), the original data distinguished between six different types of damage (see also the interactive map of the data provided by [Stadt Wien Kulturgut](https://www.wien.gv.at/kulturportal/public/grafik.aspx?bookmark=nyltRs9CK0bADiJEbjW5QxwZlCQ-b)):

* "Totalschaden" (yellow fill of affected areas/buildings)
* "Ausgebrannt" (red fill of affected areas/buildings)
* "Schwerer Schaden" (blue fill of affected areas/buildings)
* "Leichter Schaden" (green fill of affected areas/buildings)
* "Bombentreffer" (marked by light gray hatching)
* "Beschuss" (marked by light green hatching)

Both the unclear definitions of the individual categories as well as the fact that the underlying Generalstadtplan already uses a very strong black hatching to highlight public buildings calls the usefulness of the last two categories in question.

## Data retrieval and processing

The Bash (UNIX shell) scripts in this directory retrieve the geo-referenced version of these historic map sheets (provided by the City of Vienna [through their WMS service](https://www.data.gv.at/katalog/dataset/87282445-a02d-4f7f-9bf6-196d73d9b3a9) under a [(CC BY 3.0 AT) license](https://creativecommons.org/licenses/by/3.0/at/deed.de)) in bulk and perform automated visual cleanup operations which allow the yellow, red, blue and green area annotations of the data set to be isolated. Afterwards, the isolated regions are visually coded in a colourblind-friendly fashion and merged together into a master data file, from which transparent raster tiles are created to be used in web mapping applications.

## Dependencies

In order to run the scripts in this directory, the shell scripts will need to have access to the following binaries:

* `convert` (ImageMagick)
* `gdal_translate` and `gdalwarp` (GDAL)
* `gdal2tiles.py` (gdal2-python)

## Storage/Computation time


