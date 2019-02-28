# Data retrieval, processing and tile creation

The Bash (UNIX shell) scripts in this directory retrieve the geo-referenced version of these historic map sheets (provided by the City of Vienna [through their WMS service](https://www.data.gv.at/katalog/dataset/87282445-a02d-4f7f-9bf6-196d73d9b3a9) under a [(CC BY 3.0 AT) license](https://creativecommons.org/licenses/by/3.0/at/deed.de)) in bulk and perform automated visual cleanup operations which allow the yellow, red, blue and green area annotations of the data set to be isolated. Afterwards, the isolated regions are visually coded in a colourblind-friendly fashion and merged together into a master data file, from which transparent raster tiles are created to be used in web mapping applications.

## Underlying data

The underlying data set is based on the [Kriegsschädenplan](https://www.geschichtewiki.wien.gv.at/Kriegsschädenplan_(um_1946)) documenting war damage to buildings in Vienna that was compiled [under unknown circumstances](https://www.geschichtewiki.wien.gv.at/Kriegssch%C3%A4denplan_(um_1946)#Entstehung) in (or shortly after) 1946. The original data consists of 48 sheets of the Generalstadtplan ([original digitalisation available from WAIS](https://www.wien.gv.at/actaproweb2/benutzung/archive.xhtml?id=Akt+++++00000651m08alt#Akt_____00000651m08alt)) that were colour-coded by hand to signify different types of damage. As can be seen from [the legend at the top of the sheets](https://www.wien.gv.at/actaproweb2/benutzung/image.xhtml?id=TwKSo67xQgUqg55JnK2TO+M0+8OkdD4Jp25sfgC2ACs1), the original data distinguished between six different types of damage (see also the interactive map of the data provided by [Stadt Wien Kulturgut](https://www.wien.gv.at/kulturportal/public/grafik.aspx?bookmark=nyltRs9CK0bADiJEbjW5QxwZlCQ-b)):

* "Totalschaden" (yellow fill of affected areas/buildings)
* "Ausgebrannt" (red fill of affected areas/buildings)
* "Schwerer Schaden" (blue fill of affected areas/buildings)
* "Leichter Schaden" (green fill of affected areas/buildings)
* "Bombentreffer" (marked by light gray hatching)
* "Beschuss" (marked by light green hatching)

Both the unclear definitions of the individual categories as well as the fact that the underlying Generalstadtplan already uses an often undistinguishable strong black hatching to highlight public buildings calls the usefulness of the last two categories in question.

## Data processing approach

The goal of the data cleaning process was to automatically extract all those areas of the maps which are clearly marked with one of the first four damage categories, i.e. those areas filled in with yellow, red, blue and green respectively. In order to automate the process, the raw maps first undergo pre-processing using the simple ImageMagick command line image processing tools: firstly, detailed annotations are "smudged" out using the morphological Close operator, which 
Secondly, the saturation of the images is increased, which enhances the identifiability of the coloured annotations on top of the original black/white map. Lastly, near-white areas are cleared, which removes the leftovers of smaller annotations created by the initial Close operation.

<img src="https://kevinstadler.github.io/bombdamage/build/preprocessing.png" align="center" alt="The original map and three stages of pre-processing: smudging using the morphological Close operator, enhancing of hue saturation, and removal of near-white areas" title="The original map and three stages of pre-processing" />

Based on the pre-processing output, the different coloured areas can be extracted through fuzzy matching of the image against four idealised target colours. At the moment setting these target colours by hand yielded the best results, although the results are not perfect and the approach can certainly still be improved (see Lessons learned section below).

<img src="https://kevinstadler.github.io/bombdamage/build/extraction.png" align="center" alt="The four individual extracted colour masks corresponding to different degrees of damage" title="The four individual extracted colour masks corresponding to different degrees of damage" />

These four image masks extracted from the original data can now be combined and coloured freely. For the sake of this project the choice was to re-apply a more homogeneous colouring according to the original damage categories, but choosing a spectrum of colours that is more distinguishable under a wide range of colour-blindness conditions. The resulting (transparent) damage mask is here shown next to the corresponding section of the original map.

<img src="https://kevinstadler.github.io/bombdamage/build/merged.png" align="center" alt="The final transparent damage mask next to the corresponding section of the original map" title="The final transparent damage mask next to the corresponding section of the original map" />

Finally, the resulting georeferenced damage mask was converted into a set of map tiles which can be used as a semi-transparent overlay over any other online map resource. An interactive map making use of the tiles can be found at <https://kevinstadler.github.io/bombdamage/>

<!-- generate pipeline demonstration picture
TILE=44
X0=1730
Y0=66
XE=2842
YE=946
WIDTH=1112
HEIGHT=880
CROP="${WIDTH}x${HEIGHT}+${X0}+${Y0}"
source "tile-geometry.sh"
convert "raw/$TILE.jpeg" -morphology Close "$KERNEL" close.png
convert close.png -modulate 100,300 mod.png
convert mod.png -fuzz 25% -fill white -opaque white raw.png

montage "raw/$TILE.jpeg" close.png mod.png raw.png -crop $CROP -tile 4x1 -geometry 185x147+10+10 -background lightgray ../build/preprocessing.png
montage "raw/$TILE-red-debug.png" "raw/$TILE-yellow-debug.png" "raw/$TILE-green-debug.png" "raw/$TILE-blue-debug.png" -crop $CROP -tile 4x1 -geometry 185x147+10+10 -background lightgray ../build/extraction.png

montage "raw/$TILE-merged.png" "raw/$TILE.jpeg" -crop $CROP -tile 2x1 -geometry 185x147+10+10 -background lightgray ../build/merged.png
-->

## Lessons learned/TODOs

## How to run & dependencies

In order to run the scripts in this directory, the shell scripts will need to have access to the following binaries:

* `build.sh` 
* `tile-geometry.sh`

* `get-data.sh`
  * `wget`
* `generate-tiles.sh`
  * `convert` (ImageMagick)
  * `gdal_translate` and `gdalwarp` (GDAL)
  * `gdal2tiles.py` (gdal2-python)

## Storage/Computation time

