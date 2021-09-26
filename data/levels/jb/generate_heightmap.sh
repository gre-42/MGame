#!/bin/bash -eux

cd "${0%/*}"

../../../Mlib/URelWithDebInfo/Bin/proc_terrain --grf heightmap.pgm --size 1024 --seed 0 --min -4 --max 120 --alpha -3
