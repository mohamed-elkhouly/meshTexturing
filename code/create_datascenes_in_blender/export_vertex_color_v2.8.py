import bpy
import os

# export_type 0: export .ply, 1: export .obj
export_type=1

blend_file_path = bpy.data.filepath
directory = os.path.dirname(blend_file_path) 
if (export_type==0):  
    path=os.path.join(directory,"ply_directory")
elif (export_type==1):  
    path=os.path.join(directory,"obj_directory")
    
    
try:
    os.mkdir(path)
except:
    d=[];
    if os.path.isdir(path):
        for root, dirs, files in os.walk(path):
            for file in files:
                os.remove(os.path.join(root, file))
                
if (export_type==0):                
    bpy.context.scene.render.engine = 'BLENDER_RENDER'
for obj in bpy.context.scene.objects:
    # if the object is a mesh and it is not hidden, do the following
    if obj.type == "MESH" and obj.hide_get()==False:
        obj.select_set( True)
        bpy.context.view_layer.objects.active = obj
        if (export_type==1):
                bpy.ops.export_scene.obj(filepath=(path+"/"+obj.name+".obj"), use_selection=True, use_normals=True, use_materials=True)
                #bpy.ops.export_mesh.obj(filepath=(path+"/"+obj.name+".obj"))
                obj.select_set( False)
                continue;
        
        
        for m in bpy.context.object.material_slots:
            mat=m.material
                
            mat.use_nodes =False
            mat.use_shadeless=True
            mtex = mat.texture_slots.add()
            
            cTex = bpy.data.textures.new(mat.name, type='IMAGE')
            #cTex.image =bpy.data.images[current_group_name]
            nodes = mat.node_tree.nodes
            # Iterate through all the nodes in the node tree and test each one to see if it's a diffuse shader:
            for node in nodes:
                if(node.bl_idname=='ShaderNodeTexImage'):
                    #print(node.image.name)
                    cTex.image =bpy.data.images[node.image.name]
                    break;
            mtex.texture = cTex
        bpy.ops.mesh.vertex_color_add()
        # Specify the bake type
        bpy.data.scenes["Scene"].render.bake_type = "TEXTURE"
        bpy.data.scenes["Scene"].render.use_bake_to_vertex_color=True
        bpy.ops.object.bake_image()
        bpy.ops.export_mesh.ply(filepath=(path+"/"+obj.name+".ply"))
        obj.select=False
                
                    