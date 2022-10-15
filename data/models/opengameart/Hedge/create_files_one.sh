#!/bin/bash -eux

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

seed=1
for dir in Small Long SmallRound LongRound; do
    cd $dir
    for angle_y in 45 135; do
        render_obj_file \
            *Exp.obj \
            --nsamples_msaa 1 \
            --blend_mode binary_05 \
            --scale 0.7 \
            --output /tmp/out.png \
            --look_at_aabb \
            --y -10 \
            --light_configuration one \
            --no_shadows \
            --angle_y $angle_y \
            --light_x 0 \
            --light_y 0 \
            --light_z -40 \
            --light_angle_x -90 \
            --light_angle_y 90 \
            --light_angle_z 45 \
            --diffusivity 1 \
            --specularity 0
        convert /tmp/out.png -trim -transparent 'rgb(255,0,255)' card_$angle_y.png
        rm /tmp/out.png
    done
    cd -
done
