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


		============================

After having a baked file of the scene, to get the colors of the baked model as a per-face colors or if we want to export as .obj file with .mtl 
we can use the code in  

meshTexturing/code/color_and_mesh_from_obj/change_images_names_to_object_name_and_export.py

this code will create a folder with the same name of the opened blender file,
inside this folder it will export the images from the .blend file and the .obj and the .mtl file

after having the exported images and .obj and .mtl we can now have a per-face colors using the code in 
meshTexturing/code/color_and_mesh_from_obj/get_faces_colors_from_obj.m

to run this file it has to be in the same folder with other files alongside it in the same folder.
the data which this file will work on should be on another folder inside this folder which this code in.

the name of the folder which data is in should be manually set inside the code in "folder_name"

this code should output two things:
>> .ply file which contain the mesh of our scene because we will need it later 

>> _baked_colors_per_face.mat which contain the [r,g,b] colors corresponding to each face accord

		===================================================

with having the "cam_info" folder which has the "camera" and "frame" folders and "intrinsics.txt" file

we should place these files inside the  "meshTexturing/code/data" folder  as another scene "scenex"
 
we should place them inside the scene folder.
 
inside the same "scene" folder we have to place the ".ply" file of our scene and it should be named with the same name of the scene folder.(the same with the intrinsic file).

using these available information only we can calculate the average per-face colors from the rendered multi-view images using the code in 

>>meshTexturing/code/Main.m

we only have to set the scene name in "mesh.scene_name" then run up to line :

"[faces_colors]=getFacesColors_and_TexturingMesh2_only_for_average_purpose(mesh);"

this line will output the file "scenex_average_colors_per_face.mat" inside the scene folder.

		=================================

if we want to compare between the average per-face colors and the baked per-face colors (which we got it before as "_baked_colors_per_face.mat"),
we should place this "_baked_colors_per_face.mat" file inside the scene folder.

then run the main up to the line "get_difference_between_baked_and_average(mesh)"

this command will create three folders "baked_images" , "averaged_images" , and "difference_images"

		==================================

Recently I created some files for preparing a dataset:
to add a diffuse shader alongside with the gloss shader we can use the file:

meshTexturing/code/create_datascenes_in_blender/add_diffuse_to_gloss.py

we added this function as when we tried to have the diffuse map from the scene, we find that the objects which have gloss shader only give black diffuse, but at real life it should be very small value at least, so we added a diffuse shader with the same color but it will be like 3% of the gloss, mean render = diffuse(0.03)+ gloss(0.97)  for glossy objects, we can change this values.

Note: do not run it more than one time, otherwise it will create extra diffuse shader alongside with the old one.

there also part of the commented code to do the same for emmition nodes, but we do not need it for now.

========================================

the other created file is for creating the rendering passes (['Albedo','Image','Emit','DiffDir','DiffInd','GlossDir','GlossInd','GlossCol', 'Normal','Depth','Shadow','IndexOB','Diffuse','Specular','Transmission','Lightmap'] ) which will create also another folder called (result) all of these output images will be on it, each on its related folder (have its name e.g. "Depth") inside "result" folder.

meshTexturing/code/create_datascenes_in_blender/Enable_rendering_passes.py

Note: remember that we set the max of depth is 200

Note: remember that we set the max of number of objects is 50 and the object pass_index is random not based on semantics (the id of each object has been set on the file (cam_pro2.py) also note that the name of the output file is the same number of current keyframe which I change with each render.

>> Albedo = DiffCol + GlossCol + Emit 

>> Diffuse = (( DiffInd + DiffDir ) * DiffCol )

>> Specular = (( GlossDir + GlossInd ) *  GlossCol)

>> lightmap = Diffuse + Specular + Transmittion + Emit + Env       exactly like blender combination of passes but without using the colors (DiffCol, GlossCol, TransCol), only shading  (IMG/blenderpasses.png)
