#!/bin/bash -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

# google: world height map
#   https://terrain.party/
#   https://tangrams.github.io/heightmapper

# curl -o terrain.zip http://terrain.party/api/export?box=10.4701,51.4688,10.491,51.4811

# curl -o terrain-wr.zip http://terrain.party/api/export?box=10.7074300,49.7492800,10.7234400,49.7556500

# curl -o terrain-er.zip http://terrain.party/api/export?box=10.9976000,49.5892900,11.0136100,49.5956800

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
