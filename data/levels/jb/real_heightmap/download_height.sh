#!/bin/bash -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

# google: world height map
#   https://terrain.party/
#   https://tangrams.github.io/heightmapper

curl -o terrain-wr-gu.zip http://terrain.party/api/export?box=10.0505000,49.0936000,10.1030000,49.1194000

unzip -p terrain-wr-gu.zip 'terrainparty Height Map (SRTM3 v4.1).png' >heightmap.png
convert heightmap.png heightmap.pgm
rm heightmap.png
