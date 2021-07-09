#!/bin/bash -eu

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

seed=1
for i in {0..3}; do
    for steps in 10; do
        twig_diffuse=twig.png \
        mSeed=$seed \
        mTreeSteps=$steps \
        mTrunkLength=1.5 \
        mLevels=5 \
        mTwigScale=0.25 \
        mDropAmount=0 \
        mMaxRadius=0.12 \
        proc_tree
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
            --light_configuration one \
            --no_shadows \
            --light_x 0 \
            --light_y 0 \
            --light_z -40 \
            --light_angle_x -90 \
            --light_angle_y 90 \
            --light_angle_z 45
        # rm tree.obj tree.mtl
        mv tree.obj tree-$seed-$steps.obj
        convert out.ppm -trim -transparent 'rgb(255,0,255)' out-$seed-$steps.png
        rm out.ppm
        seed=$((seed + 1))
    done
done
