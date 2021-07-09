#!/bin/bash -eux

cd "$(dirname "${BASH_SOURCE[0]}")"

for f in *.obj; do
    ../../../../mlib/URelease/Apps/Render_Obj_File/render_obj_file $f --output /tmp/out.ppm
    convert /tmp/out.ppm -trim -transparent 'rgb(255,0,255)' ${f%%.obj}_thumb.png
    rm /tmp/out.ppm
done;
