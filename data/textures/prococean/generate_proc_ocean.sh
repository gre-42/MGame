#!/bin/bash -eux
cd "$(dirname "${BASH_SOURCE[0]}")"

for seed in 2 3; do
    ../../../Mlib/GURelWithDebInfo/Bin/proc_terrain_perlin --frequency 32 --octaves 8 --seed $seed --size 512 --out heightmap_$seed.png --sigma 6 --alpha 0.5 --min 0.1 --max 1 --invert --seamless_overlap 50
done
# convert /tmp/heightmap.pgm /tmp/heightmap.png
# NormaMap.png created using https://cpetry.github.io/NormalMap-Online
