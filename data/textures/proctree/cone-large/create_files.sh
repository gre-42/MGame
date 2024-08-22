#!/bin/bash -eu

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

seed=1
for i in {0..3}; do
    for steps in 10; do
        mSeed=$seed mTreeSteps=$steps mTrunkLength=1.5 mLevels=5 mTwigScale=0.25 mDropAmount=0 mMaxRadius=0.12 proc_tree
        render_obj_file \
            tree.obj \
            --nsamples_msaa 0 \
            --blend_mode binary \
            --aggregate_mode off \
            --scale 2 \
            --output out.ppm \
            --width 2048 \
            --height 2048 \
            --y -5 \
            --light_configuration none \
            --background_light_ambience 1 \
            --color_cone_min_r 3 \
            --color_cone_max_r 7 \
            --color_cone_min_c 0.5 \
            --color_cone_max_c 1.5 \
            --color_cone_bottom 0 \
            --color_cone_top 15
        rm tree.obj tree.mtl
        convert out.ppm -trim -transparent 'rgb(255,0,255)' out-$seed-$steps.png
        rm out.ppm
        seed=$((seed + 1))
    done
done
