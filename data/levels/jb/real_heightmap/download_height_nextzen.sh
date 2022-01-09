#!/bin/bash -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

# google: world height map
#   https://terrain.party/
#   https://tangrams.github.io/heightmapper

# hinterglemm (47.379, 12.594)
# kolm-saigurn (47.069, 12.985)

# curl -o terrain-nyc.zip http://terrain.party/api/export?box=-74.0231000,40.7030000,-73.9911000,40.7180000

# curl -o gh2.xml https://overpass-api.de/api/map?bbox=12.594,47.069,12.985,47.379

../../../../Mlib/GURelWithDebInfo/Bin/download_heightmap \
    --zoom 12 \
    --min_lat 49.0936000 \
    --min_lon 10.0505000 \
    --max_lat 49.1194000 \
    --max_lon 10.1030000 \
    --tile_pixels 256 \
    --result_width 1024 \
    --result_height 1024 \
    --out_png heightmap_nextzen.png

