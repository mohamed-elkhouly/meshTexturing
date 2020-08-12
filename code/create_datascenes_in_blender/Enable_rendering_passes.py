import bpy
import bmesh
import sys
import os
import time
def create_directory(path):
    try:
        os.mkdir(path)
    except:
        d=[];
        if os.path.isdir(path):
            for root, dirs, files in os.walk(path):
                for file in files:
                    os.remove(os.path.join(root, file))
                    
bpy.context.scene.render.layers["RenderLayer"].use_pass_combined = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_z = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_ambient_occlusion = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_diffuse_direct = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_diffuse_indirect = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_diffuse_color = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_glossy_direct = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_glossy_indirect = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_glossy_color = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_transmission_direct = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_transmission_indirect = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_transmission_color = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_subsurface_direct = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_subsurface_indirect = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_subsurface_color = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_emit = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_environment = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_normal = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_object_index = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_material_index = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_mist = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_vector = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_uv = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_shadow = True

pass_index=0
for obj in bpy.context.scene.objects:
    # if the object is a mesh and it is not hidden, do the following
    if obj.type == "MESH" and obj.hide==False:
        obj.pass_index=pass_index
        pass_index=pass_index+1;


# switch on nodes and get reference
bpy.context.scene.use_nodes = True
tree = bpy.context.scene.node_tree


# clear default nodes
for node in tree.nodes:
    tree.nodes.remove(node)

# create input image node
NodeRLayers = tree.nodes.new(type='CompositorNodeRLayers')
NodeRLayers.location = 0,0

# create output node
out_node = tree.nodes.new('CompositorNodeOutputFile')   
out_node.location = 400,0
out_node.file_slots.remove(out_node.inputs[0])
# link nodes
links = tree.links

blend_file_path = bpy.data.filepath
directory = os.path.dirname(blend_file_path) 
result_path=os.path.join(directory,'result')
create_directory(result_path)
out_node.base_path=result_path
#outputs_required=['Image','Emit', 'Normal','Depth','Shadow','IndexOB','DiffCol']  
outputs_required=['Image','Emit','DiffDir','DiffInd','GlossDir','GlossInd','GlossCol', 'Normal','Depth','Shadow','IndexOB','DiffCol']  
for cur_out in outputs_required:
    create_directory(os.path.join(result_path,cur_out))
    #current_output='Emit'
    #out_node.select = True
    #tree.nodes.active = out_node
    #bpy.ops.node.output_file_remove_active_socket()
    out_node.file_slots.new(cur_out)
    out_node.file_slots[cur_out].format.file_format="PNG"
    link = links.new(NodeRLayers.outputs[cur_out], out_node.inputs[cur_out])
    if cur_out=='Depth' or cur_out=='IndexOB':
        out_node.file_slots[cur_out].use_node_format=False
        if cur_out=='Depth':
            out_node.file_slots[cur_out].format.file_format="OPEN_EXR"
            map_range_node = tree.nodes.new('CompositorNodeMapRange') 
            map_range_node.location = 200,200
            map_range_node.inputs[2].default_value=200
            link = links.new(NodeRLayers.outputs[cur_out], map_range_node.inputs[0])
            link = links.new(map_range_node.outputs[0], out_node.inputs[cur_out])
        
        if cur_out=='IndexOB':
            out_node.file_slots[cur_out].format.file_format="PNG"
            math_node = tree.nodes.new('CompositorNodeMath') 
            math_node.location = 200,-450
            math_node.operation='DIVIDE'
            math_node.inputs[1].default_value=50
            link = links.new(NodeRLayers.outputs[cur_out], math_node.inputs[0])
            link = links.new(math_node.outputs[0], out_node.inputs[cur_out])
            
        
        
    #out_node.inputs.new( type = 'RGBA', name = cur_out)
    #out_node.select = False
    
    #bpy.context.scene.update()
    # Wait for 5 seconds
    #time.sleep(1)
    #image.update ()
    #cur_img_name='Render Result' 
    #new_img_name='normal'
    #path=os.path.join(result_path,cur_out)
    #ilepath_raw=path+'/'+new_img_name+'.png'
    #img = bpy.data.images[cur_img_name]
    #img.save_render(ilepath_raw)