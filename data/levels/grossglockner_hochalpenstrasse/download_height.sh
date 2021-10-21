#!/bin/bash -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

# google: world height map
#   https://terrain.party/
#   https://tangrams.github.io/heightmapper

# curl -o terrain.zip http://terrain.party/api/export?box=22.7886000,37.5748000,22.9688000,37.6606000
# curl -o terrain.zip http://terrain.party/api/export?box=22.8293000,37.6125000,22.9285000,37.6537000
# curl -o terrain.zip http://terrain.party/api/export?box=22.8808000,37.5902000,22.9549000,37.6448000
curl -o terrain.zip http://terrain.party/api/export?box=12.7826000,47.1089000,12.8875000,47.1629000

unzip -p terrain.zip 'terrainparty Height Map (SRTM3 v4.1).png' >heightmap.png
convert heightmap.png heightmap.pgm
rm heightmap.png
