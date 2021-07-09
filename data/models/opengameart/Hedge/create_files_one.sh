#!/bin/bash -eux

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

seed=1
for dir in Small Long SmallRound LongRound; do
    make -C /home/kl/MySrc/mlib release
    cd $dir
    for angle_y in 45 135; do
        /home/kl/MySrc/mlib/URelease/Apps/Render_Obj_File/render_obj_file \
            *Exp.obj \
            --nsamples_msaa 0 \
            --blend_mode binary \
            --aggregate_mode off \
            --scale 0.2 \
            --output out.ppm \
            --width 2048 \
            --height 2048 \
            --y -5 \
            --light_configuration one \
            --no_cull_faces \
            --no_shadows \
            --angle_y $angle_y \
            --light_x 0 \
            --light_y 0 \
            --light_z -40 \
            --light_angle_x -90 \
            --light_angle_y 90 \
            --light_angle_z 45
        convert out.ppm -trim -transparent 'rgb(255,0,255)' card_$angle_y.png
        rm out.ppm
    done
    cd -
done
