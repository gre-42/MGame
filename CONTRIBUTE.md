# Contribute

New maps can be added by

- creating a pull request to the main repository, or by
- having a separate repository and adding its directory to the render_scene_filecommand-line. The first argument of the render_scene_file program is a semicolon-separated list of pathes, which is shown in the following screenshot.

Linux: Edit the file `osm_racing_game`

```bash
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:GURelease" GURelease/render_scene_file \
    "data;/home/user/my_private_data_directory" \
    data/levels/main/main.scn.json \
    --app_reldir .osm_rally \
    --nsamples_msaa 2 \
    --show_mouse_cursor \
    --windowed_width 1500 \
    --windowed_height 900
```

Windows: Edit the file `osm_racing_game.cmd`

```cmd
GVSRelease\render_scene_file.exe ^
    data;my_private_data_directory ^
    data\levels\main\main.scn.json ^
    --app_reldir osm_rally ^
    --nsamples_msaa 2 ^
    --show_mouse_cursor ^
    --windowed_width 1500 ^
    --windowed_height 900
```

There is no stage editor yet, the existing stages were created using

- [JOSM](https://josm.openstreetmap.de/),
- the [download_height_map](https://github.com/gre-42/Mlib/blob/master/Apps/Download_Heightmap/download_heightmap.cpp) tool (see e.g. [the canyon1 download script](https://github.com/gre-42/MGame/blob/main/data/levels/canyon1/download_height.sh))
- and manual editing of [JSON stage files](https://github.com/gre-42/MGame/blob/main/data/levels/desert1/osm_resource_desert1.scn.json).
