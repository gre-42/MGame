#!/bin/bash -eux

cd "$(dirname "${BASH_SOURCE[0]}")"

for f in *.obj; do
    render_obj_file "$f" --output /tmp/out.png
    convert /tmp/out.png -trim -transparent 'rgb(255,0,255)' "${f%%.obj}_thumb.png"
    rm /tmp/out.png
done;
