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


for obj in bpy.context.scene.objects:
    # if the object is a mesh and it is not hidden, do the following
    if obj.type == "MESH" and obj.hide==False:
        
        bpy.ops.object.mode_set(mode='OBJECT')

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
                mat_links = mat.node_tree.links
                # Iterate through all the nodes in the node tree and test each one to see if it's a diffuse shader:
                for node in nodes:
                    #print( node.bl_idname)
                    if(node.bl_idname=='ShaderNodeBsdfGlossy'):
                        #replace glossy node with diffuse node.
                        print(" replace glossy")
                        new_node = nodes.new('ShaderNodeBsdfDiffuse')
                        mix_node = nodes.new('ShaderNodeMixShader')
                        new_node.inputs[0].default_value=node.inputs[0].default_value
                        new_node.inputs[1].default_value=node.inputs[1].default_value


                        followLinks_inputs(node,new_node,mat_links,10)
                        followLinks_outputs(node,mix_node,mat_links,10)

                        mix_node.inputs[0].default_value=0.03
                        mat_links.new(node.outputs[0],mix_node.inputs[1])
                        mat_links.new(new_node.outputs[0],mix_node.inputs[2])
                        
                                                #break;
                    # if(node.bl_idname=='ShaderNodeEmission'):
                    #     #replace emittion node with diffuse node.
                    #     print(" replace emittion")
                    #     new_node = nodes.new('ShaderNodeBsdfDiffuse')
                    #     new_node.inputs[0].default_value=node.inputs[0].default_value
                    #     #new_node.inputs[1].default_value=node.inputs[1].default_value
                    #     followLinks_inputs(node,new_node,mat_links,1)
                    #     followLinks_outputs(node,new_node,mat_links,1)
             
                    node.select=False