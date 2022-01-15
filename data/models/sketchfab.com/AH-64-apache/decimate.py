import bpy
from bpy import data as D
from bpy import context as C
from mathutils import *
from math import *
import os
import glob
import re

decimate_ratio = 0.5
# decimate_ratio = 0

for obj_filename in glob.glob('AH-64.obj'):
    if re.search('_d[.\\d]+\.obj', obj_filename):
        print('Skipping file "%s"' % obj_filename)
        continue
    print('Processing file "%s"' % obj_filename)
    out_obj_filename = obj_filename.replace('.obj', '_d%g.obj' % (10 * decimate_ratio))
    out_mtl_filename = out_obj_filename.replace('.obj', '.mtl')

    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(confirm=False)
    for material in bpy.data.materials:
        bpy.data.materials.remove(material, do_unlink=True)

    bpy.ops.import_scene.obj(filepath=obj_filename, use_split_groups=True)
    # bpy.ops.object.select_all(action='SELECT')
    for so in bpy.context.selected_objects:
        bpy.context.view_layer.objects.active = so

        bpy.ops.object.modifier_add(type='DECIMATE')
        if decimate_ratio != 0:
            bpy.context.object.modifiers["Decimate"].ratio = decimate_ratio
        else:
            bpy.context.object.modifiers["Decimate"].decimate_type = 'DISSOLVE'
            bpy.context.object.modifiers["Decimate"].delimit = {'UV'}

    # "obj groups" option not available in scripts, save manually instead
    # bpy.ops.export_scene.obj(filepath=out_obj_filename, group_by_object=True)
    # os.remove(out_mtl_filename)
    # with open(out_obj_filename) as f:
    #     s = f.read().replace('_d%g.mtl' % (10 * decimate_ratio), '.mtl')
    # with open(out_obj_filename, 'w') as f:
    #     f.write(s)

# bpy.ops.wm.quit_blender()
