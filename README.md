# meshTexturing
trying to implement some mesh texturing techniques

all of the next code working in blender 2.79

Before getting any operation from the scene we may need to simplify our mesh and reduce the number of faces on it and also subdivide the large faces in the scene into small ones (refine), and convert squads into triangles
the code in 
meshTexturing/code/create_datascenes_in_blender/triangulate_and_get_area6.py is doing this
To Bake the scene: 
meshTexturing/code/create_datascenes_in_blender/create_texture_atlas2_for_create_each_alone.py

>> to bake full baking set "bake_type=0"

>> to bake diffuse only "bake_type=1"

>> to bake gloss only "bake_type=2"

>> to bake emit only "bake_type=3"


to Bake for theodore only diffuse values then export .ply files:
to bake
meshTexturing/code/create_datascenes_in_blender/create_texture_atlas4_replace_glossy_and_emit_with_diffuse.py

>> set bake type to diffuse only "bake_type=1"
 
to export to .ply after baking diffuse for him or after baking full baking
meshTexturing/code/create_datascenes_in_blender/export_vertex_color.py

>>"export_type=0" to export .ply 

>>"export_type=1" to export .obj >> but it is not accurate. 

if you want to export the .obj in a better way (but I still think it is not that good)
we can use blender version 2.8 with this code.
meshTexturing/code/create_datascenes_in_blender/export_vertex_color_v2.8.py


To render a predefined camera positions "cam_state" (I copied it from blender transform GUI)
we use the code 

>>meshTexturing/code/create_datascenes_in_blender/cam_pro2.py

this rendering will output a folder called "cam_info"
inside this folder there are three things:

>>"camera" folder which contain the camera positions as pose files (camera2world matrix) to get projection matrix from it we have to invert it and multiply with intrinsic matrix.

>>"frame" folder which has the rendered images from those camera positions.

>>scene_1_intrinsics.txt which is the intrinsic file contain the intrinsic matrix.

note that this organization follow the Matterport3D convention.


