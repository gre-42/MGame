#!/bin/bash -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

# google: world height map
#   https://terrain.party/
#   https://tangrams.github.io/heightmapper

curl -o terrain-nyc.zip http://terrain.party/api/export?box=-74.0231000,40.7030000,-73.9911000,40.7180000

../../mlib/UDebug/Apps/Download_Heightmap/download_heightmap \
    --zoom 14 \
    --min_lat 40.7030000 \
    --min_lon -74.0231000 \
    --max_lat 40.7180000 \
    --max_lon -73.9911000 \
    --tile_pixels 256 \
    --result_pixels 1024 \
    --out_pgm heightmap_dh.pgm
