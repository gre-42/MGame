#!/bin/bash -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

# google: world height map
#   https://terrain.party/
#   https://tangrams.github.io/heightmapper

# curl -o terrain-nyc.zip http://terrain.party/api/export?box=-74.0231000,40.7030000,-73.9911000,40.7180000

# curl -o gh2.xml https://overpass-api.de/api/map?bbox=12.594,47.069,12.985,47.379

../../../Mlib/GURelease/Bin/download_heightmap \
    --zoom 12 \
    --min_lat 35.6426 \
    --min_lon -113.4544 \
    --max_lat 35.7692 \
    --max_lon -113.3 \
    --tile_pixels 512 \
    --result_width 1024 \
    --result_height 1024 \
    --out_png heightmap.png
