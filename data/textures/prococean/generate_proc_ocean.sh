#!/bin/bash -eux
cd "$(dirname "${BASH_SOURCE[0]}")"

../../../Mlib/GURelWithDebInfo/Bin/proc_terrain_perlin --frequency 32 --octaves 8 --seed 2 --size 1024 --out /tmp/heightmap.pgm --sigma 6 --alpha 0.5 --min 0.1 --max 1 --invert --seamless_overlap 100
convert /tmp/heightmap.pgm /tmp/heightmap.png
# NormaMap.png created using https://cpetry.github.io/NormalMap-Online
