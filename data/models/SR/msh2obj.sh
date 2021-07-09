#!/bin/bash -eux

for f in "$@"; do
    b=$(basename "$f" .mesh)
    OgreMeshUpgrader -V 1.8 "$f" "$b.mesh"
    # assimp export "$b.mesh" "$b.obj"
    /media/HomeSSD1/Src/assimp-4.1.0/build/tools/assimp_cmd/assimp export "$b.mesh" "$b.obj"
done
