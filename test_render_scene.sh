#!/bin/bash

for i in {1..1000}; do
    echo -e 'print $_exception\nthread apply all bt' | gdb -quiet -ex="catch throw" -ex=r --args Mlib/GURelWithDebInfo/Bin/render_scene_file data data/levels/race_track0/scene_race_track0.scn --print_render_residual_time --print_physics_residual_time --nsamples_msaa 2 --windowed_width 256 --windowed_height 256 --show_mouse_cursor --devel_mode --num_renderings 300 &>> /tmp/log.txt
done

grep -i -v thread /tmp/log.txt | grep -i -E -v '(fps|vendor|renderer:|starting|num_renderings|Reading|normally|No frame|quit|throw)'
