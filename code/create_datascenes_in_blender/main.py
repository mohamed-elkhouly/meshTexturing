
import bpy
import os

#bpy.ops.wm.console_toggle
bpy.app.debug_wm = False
blend_file_path = bpy.data.filepath
directory = os.path.dirname(blend_file_path) 

# Simplify (decimate)  and refine mesh
filename = "triangulate_and_refine.py"
path=os.path.join(directory,filename)
bpy.ops.text.open(filepath=path)
#exec(bpy.data.texts[filename].as_string())


# Enable rendering passes 
filename = "Enable_rendering_passes.py"
path=os.path.join(directory,filename)
bpy.ops.text.open(filepath=path)
#exec(bpy.data.texts[filename].as_string())


# Render related viewpoints 
filename = "cam_pro2.py"
path=os.path.join(directory,filename)
bpy.ops.text.open(filepath=path)
exec(bpy.data.texts[filename].as_string())










''' 
# Simplify (decimate)  and refine mesh
filename = "triangulate_and_get_area6.py"
path=os.path.join(directory,filename)
bpy.ops.text.open(filepath=path)
#exec(bpy.data.texts[filename].as_string())


# bake diffuse, gloss, emit and combine them to be visible as object diffuse
filename = "create_texture_atlas3.py"
path=os.path.join(directory,filename)
#bpy.ops.text.open(filepath=path)
#exec(bpy.data.texts[filename].as_string())


# bake the resulted diffuse from last step (this is albedo baking)
filename = "create_texture_atlas2.py"
path=os.path.join(directory,filename)
#bpy.ops.text.open(filepath=path)
#exec(bpy.data.texts[filename].as_string())


# copy albedo colors to vertices
filename = "export_vertex_color.py"
path=os.path.join(directory,filename)
#bpy.ops.text.open(filepath=path)
#exec(bpy.data.texts[filename].as_string())

'''