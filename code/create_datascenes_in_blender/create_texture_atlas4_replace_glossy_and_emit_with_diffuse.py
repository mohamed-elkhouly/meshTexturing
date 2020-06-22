import bpy
import bmesh
import sys
import os
import time

def followLinks_inputs(node_in,new_node,mat_links,num_in):
    counter=1
    for n_inputs in node_in.inputs:
        for node_links in n_inputs.links:
            from_socketID = node_links.from_socket.path_from_id()[-2:-1]
            to_socketID = node_links.to_socket.path_from_id()[-2:-1]  
            print("coming from " + node_links.from_node.name+ " going to " + node_links.to_node.name+ "from socket "+from_socketID+"to socket "+to_socketID)
            mat_links.new(node_links.from_node.outputs[int(from_socketID)],new_node.inputs[int(to_socketID)])
            #followLinks_inputs(node_links.from_node)
        if(num_in==counter):
            break;
        counter=counter+1;
            
            
def followLinks_outputs(node_in,new_node,mat_links,num_out):
    counter=1
    for n_outputs in node_in.outputs:
        for node_links in n_outputs.links:
            from_socketID = node_links.from_socket.path_from_id()[-2:-1]
            to_socketID = node_links.to_socket.path_from_id()[-2:-1]   
            print("coming from " + node_links.from_node.name+ " going to " + node_links.to_node.name+ "from socket "+from_socketID+"to socket "+to_socketID)
            mat_links.new(new_node.outputs[0],node_links.to_node.inputs[int(to_socketID)])
            #followLinks_outputs(node_links.to_node)
        if(num_out==counter):
            break;
        counter=counter+1;
                
                    
            

start = time.time()

def tri_area( co1, co2, co3 ):
    return (co2 - co1).cross( co3 - co1 ).length / 2.0

bpy.app.debug_wm = False

# a is a counter for objects
a=0 
# bake_type is the type of baking 0:full  1:diffuse  2:gloss  3:emit
bake_type= 1
end_obj=10000
max_object_area=50/4
max_GPU_cabability=8192;bpy.data.scenes['Scene'].cycles.samples=1000
#max_GPU_cabability=256;bpy.data.scenes['Scene'].cycles.samples=10
resolution_array=[256, 512, 1024, 2048, 4096, 8192, 16384]

for obj in bpy.context.scene.objects:
    # if the object is a mesh and it is not hidden, do the following
    if obj.type == "MESH" and obj.hide==False:
        bpy.ops.object.mode_set(mode = 'EDIT')
        # select all
        bpy.ops.mesh.select_all()
        bpy.ops.mesh.remove_doubles()    
        bpy.ops.object.mode_set(mode='OBJECT')
        
        
        bm = bmesh.new()
        bm.from_mesh( obj.data )
        bm.faces.ensure_lookup_table()
        bpy.ops.object.mode_set(mode = 'EDIT')
        
        # enumerate the faces
        #print(bpy.context.active_object.name)
        sum_face_area=0
        for face in bm.faces:
            face.select=True
            try:
                # Get the face area 
                face_area = tri_area( *(v.co for v in face.verts) )
                sum_face_area=sum_face_area+face_area
            except :
                print("this face is not valid, may be still quad or it is not triangle")
        bpy.ops.object.mode_set(mode='OBJECT')
        #print(sum_face_area)
        required_resolution=sum_face_area*16384/max_object_area
        #print(required_resolution)

        #required_resolution=resolution_array-required_resolution
        res =  [abs(ele-required_resolution) for ele in resolution_array] 

        #print("resolution is ")
        print("resolution is ",resolution_array[res.index(min(res))])
        resolution=resolution_array[res.index(min(res))]
        if(resolution>max_GPU_cabability):
            resolution=max_GPU_cabability
        print(obj.name,"obj_number",a)
        #print("obj_number")
        #print(a)
        bpy.ops.object.select_all(action = 'DESELECT')
        obj.select = True
        bpy.context.scene.objects.active = obj
        bpy.ops.scene.ms_add_lightmap_group()
        print("group name is ###############################################################################")
        #print(bpy.data.scenes['Scene'].ms_lightmap_groups[-1].name)
        current_group_name=bpy.data.scenes['Scene'].ms_lightmap_groups[-1].name;
        #print("resolution is ")
        #print(bpy.data.scenes['Scene'].ms_lightmap_groups[-1].resolutionX)
        #print(bpy.data.scenes['Scene'].ms_lightmap_groups[-1].resolutionY)

        #resolution=256
        #resolution=512
        #resolution=1024
        #resolution=2048
        #resolution=4096
        #resolution=8192
        #resolution=16384        
        
        bpy.data.scenes['Scene'].ms_lightmap_groups[-1].resolutionX=str(resolution)
        bpy.data.scenes['Scene'].ms_lightmap_groups[-1].resolutionY=str(resolution)
        bpy.data.scenes['Scene'].render.tile_x=resolution
        bpy.data.scenes['Scene'].render.tile_y=resolution


        #print(bpy.data.scenes['Scene'].ms_lightmap_groups[-1].resolutionX)
        #print(bpy.data.scenes['Scene'].ms_lightmap_groups[-1].resolutionY)
        #print(" before ms_run")
        bpy.ops.object.ms_run()
        #print(" after ms_run")
        bpy.ops.object.mode_set(mode='EDIT')
        bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.uv.smart_project(island_margin=0.12)
        #print(" before ms_remove")
        sys.stdout = open(os.devnull, "w")
        bpy.ops.object.ms_run_remove()
        sys.stdout = sys.__stdout__
        #print(" after ms_remove")
        
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
                mat_links = mat.node_tree.links
                # Iterate through all the nodes in the node tree and test each one to see if it's a diffuse shader:
                for node in nodes:
                    #print( node.bl_idname)
                    if(node.bl_idname=='ShaderNodeBsdfGlossy'):
                        #replace glossy node with diffuse node.
                        print(" replace glossy")
                        new_node = nodes.new('ShaderNodeBsdfDiffuse')
                        new_node.inputs[0].default_value=node.inputs[0].default_value
                        new_node.inputs[1].default_value=node.inputs[1].default_value
                        followLinks_inputs(node,new_node,mat_links,10)
                        followLinks_outputs(node,new_node,mat_links,10)
                        #break;
                    if(node.bl_idname=='ShaderNodeEmission'):
                        #replace emittion node with diffuse node.
                        print(" replace emittion")
                        new_node = nodes.new('ShaderNodeBsdfDiffuse')
                        new_node.inputs[0].default_value=node.inputs[0].default_value
                        #new_node.inputs[1].default_value=node.inputs[1].default_value
                        followLinks_inputs(node,new_node,mat_links,1)
                        followLinks_outputs(node,new_node,mat_links,1)
                        #break;
                        
                    if(node.bl_idname=='ShaderNodeTexImage'):
                        #print( node.image.colorspace_settings.name)
                        #print(node.image.name)
                        if(node.image.name==current_group_name):
                            flag=True
                            #print("repeated");
                            #continue;
                        if(node.image.colorspace_settings.name=='sRGB' ):
                            try:
                                bpy.context.object.data.uv_textures['UVMap'].active_render = True
                            except:
                                d=[];
                            bpy.context.object.data.uv_textures[current_group_name].active = True
                        #print("node select",node.select)
                            
                    #print("node select",node.select)
                    node.select=False
            
            #break            
            #if(not flag):           
            uvnode = nodes.new(type="ShaderNodeTexImage")
            uvnode.location = (300*a),0
            uvnode.image=bpy.data.images[current_group_name]
            uvnode.select=True
            nodes.active = uvnode
            #else:
            #    print("repeated 2");
                
                
            bpy.data.scenes['Scene'].render.bake.use_clear=False
            try:
                if (bake_type==0):
                    #to bake all together
                    bpy.ops.object.bake(type='COMBINED')
                elif(bake_type==1):
                    # To bake diffuse only                
                    bpy.data.scenes['Scene'].render.bake.use_pass_color=True
                    bpy.data.scenes['Scene'].render.bake.use_pass_direct=False
                    bpy.data.scenes['Scene'].render.bake.use_pass_indirect=False
                    bpy.ops.object.bake(type='DIFFUSE')
                elif(bake_type==2):
                    # To bake GLOSSINESS only                
                    bpy.data.scenes['Scene'].render.bake.use_pass_color=True
                    bpy.data.scenes['Scene'].render.bake.use_pass_direct=False
                    bpy.data.scenes['Scene'].render.bake.use_pass_indirect=False
                    bpy.ops.object.bake(type='GLOSSY')
                elif(bake_type==3):
                    # To bake EMITTANCE only                
                    bpy.ops.object.bake(type='EMIT')
                
                
                uvnode.image.pack(as_png = True) # pack into blend file for exporting as a standalone player
                
            except:
                d=[]
            uvnode.select=False
                
                
            new_mat = bpy.data.materials.new(name=obj.name+"_dahy") #set new material to variable
            new_mat.use_nodes = True
            mat_nodes = new_mat.node_tree.nodes
            mat_links = new_mat.node_tree.links
            diffuse = mat_nodes.get("Diffuse BSDF")
            node_output = mat_nodes.get("Material Output")
            mat_nodes.remove(diffuse)


            imgnode = mat_nodes.new(type="ShaderNodeTexImage")
            imgnode.location = 0,0
            emissionnode = mat_nodes.new(type='ShaderNodeEmission')
            emissionnode.location = 300,0
            node_output.location = 600,0

            link = mat_links.new(imgnode.outputs[0],emissionnode.inputs[0])
            link = mat_links.new(emissionnode.outputs[0], node_output.inputs[0])

            imgnode.image=bpy.data.images[current_group_name]
        
        #break;
        a=a+1
        if(a==end_obj):
            break;
    
a=0
#'''  
for obj in bpy.context.scene.objects:
    # if the object is a mesh and it is not hidden, do the following
    if obj.type == "MESH" and obj.hide==False: 
        try:
            uv_textures = bpy.context.object.data.uv_textures
            uv_textures.remove(uv_textures['UVMap'])
        except:
            d=[]
            
        obj.select = True
        bpy.context.scene.objects.active = obj
        found_material=[]
        for mat in bpy.data.materials:
            if obj.name+"_dahy" == mat.name:
                found_material=mat
                break;
        #if obj.data.materials:
            # assign to 1st material slot
         #   obj.data.materials[0] = mat
        #else:
            # no slots
            #obj.data.materials.append(mat)
        for x,y in enumerate(obj.material_slots): #For all of the materials in the selected object:
            obj.active_material_index = x #select the top material
            bpy.ops.object.material_slot_remove() #delete it
        obj.data.materials.append(mat)
        obj.select = False
        a=a+1
        if(a==end_obj):
            break;

end = time.time()
print(end - start)
#''' 
            