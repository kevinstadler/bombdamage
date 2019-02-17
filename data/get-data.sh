#!/bin/bash

# load tile geometry
cd `dirname "$0"`
source tile-geometry.sh

# create raw/ subdirectory for data
if [ ! -d "raw" ]; then
  mkdir raw
fi
cd raw

for ((col = 0; col < 8; col++ )); do
	for ((row = 0; row < 10; row++ )); do
		id=`printf "%02d" $(( 10 * $col + $row ))`
		if [[ " ${TILES[@]} " =~ " $id " ]]; then
			if [[ -f "$id.$FORMAT" ]]; then
				echo "File $id.$FORMAT already exists, skipping"
				continue
			fi
			XS=`bc <<< "$X0 + $DX * $col"`
			XE=`bc <<< "$XS + $DX"`
			YS=`bc <<< "$Y0 + $DY * $row"`
			YE=`bc <<< "$YS + $DY"`
			echo "Requesting tile #$id, extent: $XS $YS $XE $YE"
			wget -O "$id.$FORMAT" --quiet --show-progress "https://data.wien.gv.at/daten/wms?request=GetMap&version=1.1.1&width=$TILEWIDTH&height=$TILEHEIGHT&layers=BOMBENSCHADENOGD&styles=&format=image/$FORMAT&bbox=$XS,$YS,$XE,$YE&srs=$PROJ"
			status=$?
			if [ $status -ne 0 ]; then
				echo "Couldn't download tile #$id"
				rm "$id.FORMAT"
			fi
			echo
		fi
	done
done

cd ..
