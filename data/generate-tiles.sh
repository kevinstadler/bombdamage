#!/bin/sh

source tile-geometry.sh

if [ ! -d "`dirname $0`/raw" ]; then
	echo "foo"
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
			convert "$RAW" -morphology Close "$KERNEL" -modulate 100,300 -fuzz 25% -fill white -opaque white "$tile.png" &&
		#	convert "$RAW" -modulate 100,300 -morphology Close "$KERNEL" 

			# create georeference for merged tile
			XS=`bc <<< "$X0 + $DX * $col"`
			XE=`bc <<< "$XS + $DX"`
			YS=`bc <<< "$Y0 + $DY * $row"`
			YE=`bc <<< "$YS + $DY"`
			gdal_translate -q -a_srs "$PROJ" -a_ullr "$XS" "$YE" "$XE" "$YS" -r near -of PNG "$tile.png" "$tile-dummy.png"
			rm "$tile-dummy.png"
			mv "$tile-dummy.png.aux.xml" "$tile-merged.png.aux.xml"

			echo " - Extracting red" &&
			convert "$tile.png" -fuzz 30% -fill white +opaque red -morphology Close "$KERNEL" "$tile-red-debug.png" &&
			convert "$tile-red-debug.png" -negate -threshold 0 -alpha copy "$tile-red.png" &&
			convert "$tile.png" "$tile-red.png" -compose Plus -composite "$tile-sinred.png" &&

			echo " - Extracting yellow" &&
			convert "$tile-sinred.png" -fuzz 18% -fill white +opaque yellow -morphology Close "$KERNEL" "$tile-yellow-debug.png" &&
			convert "$tile-yellow-debug.png" -negate -threshold 0 -alpha copy "$tile-yellow.png" &&
			convert "$tile-sinred.png" "$tile-yellow.png" -compose Plus -composite "$tile-sinyellow.png" &&

			echo " - Extracting blue" && # was royalblue 45%
			convert "$tile-sinyellow.png" -fuzz 15% -fill white +opaque "#684" -morphology Close "$KERNEL" "$tile-blue-debug.png" &&
			convert "$tile-blue-debug.png" -negate -threshold 0 -alpha copy "$tile-blue.png" &&
			convert "$tile-sinyellow.png" "$tile-blue.png" -compose Plus -composite "$tile-sinblue.png" &&

			echo " - Extracting green" && # was lime 45%
			convert "$tile-sinblue.png" -fuzz 25% -fill white +opaque LimeGreen -morphology Close "$KERNEL" "$tile-green-debug.png" && 
			convert "$tile-green-debug.png" -negate -threshold 0 -alpha copy "$tile-green.png" &&
			convert "$tile-sinblue.png" "$tile-green.png" -compose Plus -composite "$tile-leftovers.png" &&

			# replace red - green scale with a colour-blindness friendly orange - blue one
			# https://www.vis4.net/blog/2011/11/goodbye-redgreen-scales/
			# hue grade from 30deg to 220deg
			# merge 4 layers into one, using a coluorblind-friendly spectrum: orange, strong yellow, lime, blue
			convert \( "$tile-red.png" -fill "hsb(30, 100%, 100%)" -opaque white \) \
				\( "$tile-yellow.png" -fill "hsb(60, 100%, 100%)" -opaque white \) -compose Plus -composite \
				\( "$tile-green.png" -fill "hsb(120, 100%, 100%)" -opaque white \) -compose Plus -composite \
				\( "$tile-blue.png" -fill "hsb(220, 100%, 100%)" -opaque white \) -compose Plus -composite \
				-channel A -threshold 0 "$tile-merged.png" || exit 1
		fi
	done
done

echo "Merging tiles into master tile"
#COLORS=(red yellow blue green)
COLORS=(merged)
for color in "${COLORS[@]}"; do
	echo " - $color"
	targets=""
	for tile in "${TILES[@]}"; do
		targets="$targets $tile-$color.png"
	done
	# -dstalpha makes sizex3, takes time -- TODO look into option to automatically use black fields as nodata/transparent?
	gdalwarp -dstalpha -r near -co COMPRESS=LZW -overwrite $targets "$color.tif" || exit 1
done

echo "Creating web tiles"
gdal2tiles.py --zoom=9-19 --resampling=average -w none --s_srs="$PROJ" --no-kml merged.tif .. || exit 1

cd ..
