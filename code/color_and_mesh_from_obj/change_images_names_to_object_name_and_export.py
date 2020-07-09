import bpy
import bmesh
import sys
import os
import time
start = time.time()
bpy.app.debug_wm = False


blend_file_path = bpy.data.filepath
file_name=bpy.path.basename(blend_file_path)
abs_file_name=file_name[:-6]
#print(abs_file_name)
directory = os.path.dirname(blend_file_path) 
path=os.path.join(directory,abs_file_name)

try:
    os.mkdir(path)
except:
    d=[]

try:
    bpy.ops.object.mode_set(mode='OBJECT')
except:
    d=[]
    
                        

for obj in bpy.context.scene.objects:
    # if the object is a mesh and it is not hidden, do the following
    if obj.type == "MESH" and obj.hide==False:
        bpy.ops.object.select_all(action = 'DESELECT')
        obj.select = True
        bpy.context.scene.objects.active = obj
        for m in bpy.context.object.material_slots:
            flag=False
            mat=m.material            
            if(mat):
                d=[]
                #print('mat is ok')
            else:
                print('mat is not ok')
                continue 
            # Test if 'Use Nodes' is enabled:
            if mat.use_nodes == True:
                #print("using nodes")
                nodes = mat.node_tree.nodes
                # Iterate through all the nodes in the node tree and test each one to see if it's a diffuse shader:
                for node in nodes:
                    #print( node.bl_idname)
                    
                    if(node.bl_idname=='ShaderNodeTexImage'):
                        #print( node.image.colorspace_settings.name)
                        #print(node.image.name)
                        cur_img_name=node.image.name
                        #new_img_name=obj.name+"_dahy"
                        new_img_name=mat.name  
                        new_img_name=new_img_name.replace(" ","_")                      
                        print (cur_img_name,'  ', new_img_name)
                        bpy.data.images[cur_img_name].name=new_img_name
                        bpy.data.images[new_img_name].file_format='PNG'
                        bpy.data.images[new_img_name].filepath_raw=path+'/'+new_img_name+'.png'
                        bpy.data.images[new_img_name].save()
                        node.image.name=new_img_name
                        
                        
target_file = os.path.join(path, (abs_file_name+'.obj'))
bpy.ops.export_scene.obj(filepath=target_file, use_selection=False, use_normals=True, use_materials=True,
                         use_edges=False, use_triangles=False, axis_forward='Y' )
                        