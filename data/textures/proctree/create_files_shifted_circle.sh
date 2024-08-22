#!/bin/bash -eu

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

seed=1
for i in {0..3}; do
    for steps in 5 10; do
        mSeed=$seed mTreeSteps=$steps mLevels=7 proc_tree
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
            --background_light_ambience 0.2 \
            --light_configuration shifted_circle
        rm tree.obj tree.mtl
        convert out.ppm -trim -transparent 'rgb(255,0,255)' out-$seed-$steps.png
        rm out.ppm
        seed=$((seed + 1))
    done
done
