cd /D "%~dp0" || exit /b

GVSRelease\render_scene_file.exe ^
    data ^
    data\levels\main\main.scn.json ^
    --app_reldir osm_rally ^
    --nsamples_msaa 2 ^
    --show_mouse_cursor ^
    --windowed_width 1500 ^
    --windowed_height 900
pause
