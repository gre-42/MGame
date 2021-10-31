#!/bin/bash -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

# google: world height map
#   https://terrain.party/
#   https://tangrams.github.io/heightmapper

# hinterglemm (47.379, 12.594)
# kolm-saigurn (47.069, 12.985)

# curl -o terrain-nyc.zip http://terrain.party/api/export?box=-74.0231000,40.7030000,-73.9911000,40.7180000

../../../Mlib/GUDebug/Bin/download_heightmap \
    --zoom 14 \
    --min_lat 47.069 \
    --min_lon 12.594 \
    --max_lat 47.379 \
    --max_lon 12.985 \
    --tile_pixels 256 \
    --result_width 1024 \
    --result_height 1024 \
    --out_pgm heightmap_dh.pgm \
    --out_png heightmap_dh.png
