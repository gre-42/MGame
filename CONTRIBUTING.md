# Contributing

-   [Adding a new
    stage](#adding-a-new-stage)
-   [Stage editor](#stage-editor)
-   [Caching](#caching)
-   [Debugging](#debugging)
    -   [The TERRAIN_CONTOUR_FILENAME
        file](#the-terrain_contour_filename-file)
    -   [The TERRAIN_CONTOUR_TRIANGLES_FILENAME
        file](#the-terrain_contour_triangles_filename-file)
-   [Adjusting osm
    files](#adjusting-osm-files)
    -   [Add an additional node to
        bridges](#add-an-additional-node-to-bridges)
    -   [Buildings intersecting
        roads](#buildings-intersecting-roads)
    -   [Roundabouts](#roundabouts)
    -   [Crossings](#crossings)
    -   [Bridges and
        tunnels](#bridges-and-tunnels)
    -   [Add waypoints (including start/finish) to a race
        track](#add-waypoints-including-startfinish-to-a-race-track)

## Adding a new stage

New maps can be added to the game by

-   creating a pull request to the main repository, or by
-   having a separate repository and adding its directory to the
    `render_scene_file`command-line. The first argument of the
    `render_scene_file` program is a semicolon-separated list of pathes,
    which is shown in the following screenshot.

![Image](https://github.com/user-attachments/assets/098f0fb7-6580-49ef-8058-655a5cecafa7)

To get startet, it is suggested to copy&paste one of the existing stages, which are in the directory `data/levels`. Using the path configuration from the above figure, you might place the new stage in directory `/home/gre42/my_private_data_directory/levels`.

## Stage editor

There is no \"real\" stage editor yet, the existing stages were created
using

-   [JOSM](https://josm.openstreetmap.de/),
-   the
    [download_height_map](https://github.com/gre-42/Mlib/blob/master/Apps/Download_Heightmap/download_heightmap.cpp)
    tool (see e.g. [the canyon1 download
    script](https://github.com/gre-42/MGame/blob/main/data/levels/canyon1/download_height.sh))
-   and manual editing of [JSON stage
    files](https://github.com/gre-42/MGame/blob/main/data/levels/desert1/osm_resource_desert1.scn.json).

For a rationale why there is no stage editor yet, [see this
comment](https://github.com/gre-42/MGame/issues/6#issuecomment-2614450657).

## Caching

You should know about MGames\'s caching behavior when developing a new
level. Upon the first successful start of a level, the following files
are created:

Linux

    $HOME/.osm_rally/<level_id>.cereal.binary
    $HOME/.osm_rally/<level_id>.cereal.binary.version

Windows

    %APPDATA%/.osm_rally/<level_id>.cereal.binary
    %APPDATA%/.osm_rally/<level_id>.cereal.binary.version

If one of these files does not exist, or if the version-file contains an
incorrect version number, the cache files are regenerated. Caching can
be disabled entirely by setting the environment variable
`ENABLE_OSM_MAP_CACHE` to 0.

## Debugging

### The TERRAIN_CONTOUR_FILENAME file

If MGame cannot triangulate a .osm file, it sometimes suggests to set
the `CONTOUR_DEBUG_FILENAME` environment variable to generate a
debugging picture. While this is a correct advice, it should be noted
that the `CONTOUR_DEBUG_FILENAME` file is much harder to debug than the
`TERRAIN_CONTOUR_FILENAME` file, which looks as follows:

![Image](https://github.com/user-attachments/assets/df1741d9-95e6-4be0-be3b-424bd047cefe)

All red squares in the `TERRAIN_CONTOUR_FILENAME` file have to be gone
for a valid triangulation.

### The TERRAIN_CONTOUR_TRIANGLES_FILENAME file

If the `TERRAIN_CONTOUR_FILENAME` file cannot be generated, the
`TERRAIN_CONTOUR_TRIANGLES_FILENAME` provides
[.obj-files](https://en.wikipedia.org/wiki/Wavefront_.obj_file) of the
roads that can be inspected with [Blender](https://www.blender.org/).

## Adjusting osm files

The following adjustments have to be made to .osm files for them to be
compatible with MGame.

### Buildings intersecting roads

The roads either have to be made more narrow or moved somewhere else. To
find the intersection points, the environment variable
`TERRAIN_CONTOUR_FILENAME` can be set, to e.g.
`TERRAIN_CONTOUR_FILENAME=/tmp/contour.svg`

This will give you a picture that looks something like this:

![Image](https://github.com/user-attachments/assets/24925a2d-ec8f-4014-98e8-b9970e07fd5f)

The road width is controlled by

1.  The attributes in the JSON file:

-   default_street_width
-   default_lane_width

2.  The \"width\" attribute of the `.osm` file.

### Roundabouts

Roundabouts are one of the problematic regions. In general, nodes need
to be sufficiently far away from the center of intersections.

Before:

![Image](https://github.com/user-attachments/assets/1c854aab-977e-42ec-a78c-7d8767d90e05)
![Image](https://github.com/user-attachments/assets/7d389b07-b265-4e39-8a46-3daa281c025e)

After:

![Image](https://github.com/user-attachments/assets/68e427c8-6e13-4bed-af4a-a10bd40c8dec)
![Image](https://github.com/user-attachments/assets/63ed11bb-eb1e-4518-90ae-41cb67bbc945)

### Crossings

Also, some crossings need to be modified.

Before:

![Image](https://github.com/user-attachments/assets/52dfcca4-91e2-4059-b873-fc1b40c5b582)
![Image](https://github.com/user-attachments/assets/6f44568b-88a9-431e-84ea-0c566aa6e730)

After:

![Image](https://github.com/user-attachments/assets/67d0c626-77ae-4194-b924-4ba76d42629a)
![Image](https://github.com/user-attachments/assets/70ba35e6-a259-4569-9e92-02779a53fc03)

### Bridges and tunnels

Bridges and tunnels require at least 4 nodes: 2 nodes that are on the ground and 2
nodes in the air or underground.

![Image](https://github.com/user-attachments/assets/8c83f440-7022-42be-96f0-1c0715e12134)

Bridges and tunnels cannot start from from road intersections, and therefore require an
additional node before the point where the bridge or tunnel begins.
**The \"layer\" attribute of the new way segment that is at the crossing has to be removed**:

Before:

![Image](https://github.com/user-attachments/assets/e1b4934d-8d65-4757-8cb7-c144d6093313)

After:

![Image](https://github.com/user-attachments/assets/26425d91-f194-4f1c-9c2e-ef23dc0525a3)

Also, bridges should have the fields \"bridge:yes, \"bridge_height:0\"
and \"bridge_height_reference:ground\". Otherwise their height is
assumed to be relative to sea level.

![Image](https://github.com/user-attachments/assets/487f0ebc-c041-4a05-964f-1f2057c7842b)

The final height of the bridges is defined by the
\"layer_heights_layer\" and \"layer_heights_height\" parameters, which
maps the \"layer\" attribute to a height:
![Image](https://github.com/user-attachments/assets/947a83dc-cce6-45fe-90c9-061000699c0d)

The \"layer_heights_height\" is unfortunately a strange parameter, it
should be reimplemented to make more sense. Its current meaning is as
follows: The first parameter is the height of tunnels relative to sea
level. The following heights are treated relative to the first element.

### Add waypoints (including start/finish) to a race track

Two kinds of race tracks are currently implemented:

1.  Circular race tracks with an automatically calculated optimal line.
2.  Arbitrary race tracks with a recorded optimal line.

The following describes point 2 above.

1.  Create a way in JOSM that approximately follows the race track and
    give it the \"raceway:yes\" property.

![Image](https://github.com/user-attachments/assets/7589d9a7-22d8-4d84-83e3-264cfd016021)

2.  Change the \"raceway_beacon_distance\" from `"inf"` to `5`.

![Image](https://github.com/user-attachments/assets/5e5c3fc7-7ac4-4786-9c60-3b9519b945ad)

3.  Start MGame with the `--record_track_basename` parameter pointing to
    a file basename (release v1.1.8 is required for this step)

![Image](https://github.com/user-attachments/assets/b565ff2c-ace7-4172-9640-aac8ea212b9b)

4.  Drive the race track by following the white vertical bars.

![Image](https://github.com/user-attachments/assets/3bbf8bd2-2a61-4e63-94f4-8fcc61854183)

5.  Convert the recording to a racing line with the
    [recording_to_mgame.py](https://github.com/gre-42/Mlib/blob/main/racing_line/recording_to_mgame.py)
    script.

``` shell
MGame/Mlib/racing_line/recording_to_mgame.py \
    --mass 2000 \
    --down_sampling 10 \
    /tmp/track.m \
    MGame/data/levels/martigny/racing_line_martigny.m
```

6.  Change the \"raceway_beacon_distance\" from `5` to `"inf"`.

![Image](https://github.com/user-attachments/assets/96b746a4-b349-434b-a174-73af6b8d18fd)

7.  Change the \"globals\" in the \"scene_martigny.scn.json\" as
    follows.

![Image](https://github.com/user-attachments/assets/a351f72f-d720-4259-8a92-ca7f9c015c3e)

8.  Change the \"checkpoints_file\" and \"if_checkpoints\" in the
    \"scene_martigny.scn.json\" as follows.

![Image](https://github.com/user-attachments/assets/0da0f5e6-0536-4b52-967c-351a6017d46d)

9.  Start MGame, which should now have a racing line.

![Image](https://github.com/user-attachments/assets/5e0ac608-1523-49f5-8050-e9dc56c36aaa)
