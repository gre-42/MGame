#!/bin/bash -eux

cd "${0%/*}"

../../../Mlib/URelWithDebInfo/Bin/proc_terrain --grf heightmap.pgm --size 256 --seed 0 --min -3 --max 100 --alpha -3
