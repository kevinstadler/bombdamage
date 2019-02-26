#!/bin/sh

source tile-geometry.sh

if [ ! -d "`dirname $0`/raw" ]; then
	echo "Could not find raw map data in raw/"
	exit 1
fi

cd "`dirname $0`/raw"

for ((col = 0; col < 8; col++ )); do
	for ((row = 0; row < 10; row++ )); do
		tile=`printf "%02d" $(( 10 * $col + $row ))`
		if [[ " ${TILES[@]} " =~ " $tile " ]]; then
			RAW="$tile.$FORMAT"
			echo "\nProcessing tile $tile"
			if [ ! -f "$RAW" ]; then
				echo "File not found: $RAW"
				continue;
			fi

			echo " - Pre-processing"
			# Close, saturate colours and clean out near-white data to save disk space

			convert "$RAW" -morphology Close "$KERNEL" -modulate 100,300 -fuzz 25% -fill white -opaque white "$tile.png" || exit 1
		#	convert "$RAW" -modulate 100,300 -morphology Close "$KERNEL" 

			# create georeference for merged tile
			XS=`bc <<< "$X0 + $DX * $col"`
			XE=`bc <<< "$XS + $DX"`
			YS=`bc <<< "$Y0 + $DY * $row"`
			YE=`bc <<< "$YS + $DY"`
			gdal_translate -q -a_srs "$PROJ" -a_ullr "$XS" "$YE" "$XE" "$YS" -r near -of PNG "$tile.png" "$tile-merged.png" || exit 1
			rm "$tile-merged.png"

			echo " - Extracting red" &&
			convert "$tile.png" -fuzz 30% -fill white +opaque red -morphology Close "$KERNEL" "$tile-red-debug.png" &&
			convert "$tile-red-debug.png" -negate -threshold 0 -alpha copy "$tile-red.png" &&
			convert "$tile.png" "$tile-red.png" -compose Plus -composite "$tile-sinred.png" &&

			echo " - Extracting yellow" &&
			convert "$tile-sinred.png" -fuzz 18% -fill white +opaque yellow -morphology Close "$KERNEL" "$tile-yellow-debug.png" &&
			convert "$tile-yellow-debug.png" -negate -threshold 0 -alpha copy "$tile-yellow.png" &&
			convert "$tile-sinred.png" "$tile-yellow.png" -compose Plus -composite "$tile-sinyellow.png" &&

			echo " - Extracting blue" &&
			convert "$tile-sinyellow.png" -fuzz 14% -fill white +opaque "#684" -morphology Close "$KERNEL" "$tile-blue-debug.png" &&
			convert "$tile-blue-debug.png" -negate -threshold 0 -alpha copy "$tile-blue.png" &&
			convert "$tile-sinyellow.png" "$tile-blue.png" -compose Plus -composite "$tile-sinblue.png" &&

			echo " - Extracting green" && # was lime 45% // LimeGreen 25
			convert "$tile-sinblue.png" -fuzz 25% -fill white +opaque LimeGreen -morphology Close "$KERNEL" "$tile-green-debug.png" && 
			convert "$tile-green-debug.png" -negate -threshold 0 -alpha copy "$tile-green.png" &&
			convert "$tile-sinblue.png" "$tile-green.png" -compose Plus -composite "$tile-leftovers.png" &&

			# replace red - green scale with a colour-blindness friendly orange - blue one
			# https://www.vis4.net/blog/2011/11/goodbye-redgreen-scales/ (hue grade from 30deg to 220deg)

			# merge 4 layers into one, using a colourblind-friendly spectrum: orange, yellow, lime, blue
			convert \( "$tile-red.png" -fill "hsb(30, 100%, 100%)" -opaque white \) \
				\( "$tile-yellow.png" -fill "hsb(60, 100%, 100%)" -opaque white \) -compose Plus -composite \
				\( "$tile-green.png" -fill "hsb(120, 100%, 100%)" -opaque white \) -compose Plus -composite \
				\( "$tile-blue.png" -fill "hsb(220, 100%, 100%)" -opaque white \) -compose Plus -composite \
				-channel A -threshold 0 "PNG24:$tile-merged.png" || exit 1
				# force PNG24 output, otherwise ImageMagick would create a smaller paletted PNG8 file which
				# will cause trouble when merging the different files (due to their different palette orders)
				# using gdalwarp. see also https://imagemagick.org/Usage/formats/#png_formats
		fi
	done
done

echo "\nMerging tiles into master tile"
targets=""
for tile in "${TILES[@]}"; do
	targets="$targets $tile-merged.png"
done
gdalwarp -dstalpha -r near -co COMPRESS=LZW -co TILED=YES -overwrite $targets "../merged.tif" || exit 1

cd ..

echo "\nCreating web tiles"
# generate web tiles -- maximum required zoom level given the default download resolution is 17 
gdal2tiles.py --resampling=near --s_srs="$PROJ" --no-kml -w none merged.tif webtiles/
