#!/bin/bash -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

# google: world height map
#   https://terrain.party/
#   https://tangrams.github.io/heightmapper

curl -o terrain-sf.zip http://terrain.party/api/export?box=-122.4475800,37.7869961,-122.428894,37.8075900

# google: SRTM30 Plus download api
#   https://www.researchgate.net/post/How-can-I-download-SRTM-data-of-30-m-resolution

# http://www.webservice-energy.org/mapserv/srtm?layers=srtm_s0&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=image%2Ftiff&SRS=EPSG:4326&BBOX=-122.4475800,37.7998000,-122.4344100,37.8075900&width=1024&height=1024

# http://www.webservice-energy.org/mapserv/srtm?layers=srtm_s0&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=image%2Ftiff&SRS=EPSG:4326&BBOX=-74.0231000,40.7030000,-73.9911000,40.7180000&width=1024&height=1024

# google: terrain.party github
#   https://github.com/tangrams/heightmapper
#   https://gist.github.com/unitycoder/bb0d64da971c6e74972ed5d8c41eab0a
#       https://tangrams.github.io/heightmapper/
#           https://www.mapzen.com/blog/elevation/

# gogle: srtm guide
#   https://wiki.openstreetmap.org/wiki/SRTM

# google: leaflet javascript zoom
#    https://leafletjs.com/examples/zoom-levels/

# ../../mlib/UDebug/Apps/Download_Heightmap/download_heightmap \
#     --zoom 14 \
#     --min_lat 37.7869961 \
#     --min_lon -122.4475800 \
#     --max_lat 37.8075900 \
#     --max_lon -122.428894 \
#     --tile_pixels 256 \
#     --result_pixels 1024 \
#     --out_pgm heightmap_raw.pgm
# 
# ../../mlib/URelease/Apps/Local_Polynomial_Regression/local_polynomial_regression \
#     heightmap_raw.pgm \
#     heightmap.pgm \
#     --sigma 40 \
#     --degree 2
