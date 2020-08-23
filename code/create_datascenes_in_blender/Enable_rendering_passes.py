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




# blender set the color space to "Linear" instead of "sRGB" which corresponds more closely to nature, and makes computations more physically accurate.
bpy.data.scenes["Scene"].sequencer_colorspace_settings.name="Linear"
bpy.data.scenes["Scene"].view_settings.look='None'                         
bpy.context.scene.render.layers["RenderLayer"].use_pass_combined = True
bpy.context.scene.render.layers["RenderLayer"].use_pass_z = True
#bpy.context.scene.render.layers["RenderLayer"].use_pass_ambient_occlusion = True
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
out_node.location = 800,-200
out_node.file_slots.remove(out_node.inputs[0])
# link nodes
links = tree.links

blend_file_path = bpy.data.filepath
directory = os.path.dirname(blend_file_path) 
result_path=os.path.join(directory,'result')
create_directory(result_path)
out_node.base_path=result_path
position_f=0
pos_changer=-1
#outputs_required=['Image','Emit', 'Normal','Depth','Shadow','IndexOB','DiffCol']  
outputs_required=['Albedo','Image','Emit','DiffDir','DiffInd','GlossDir','GlossInd','GlossCol', 'Normal','Depth','Shadow','IndexOB','Diffuse','Specular','Transmission','Lightmap']  
for cur_out in outputs_required:
    current_out_path=os.path.join(result_path,cur_out)
    create_directory(current_out_path)
    out_node = tree.nodes.new('CompositorNodeOutputFile')   
    out_node.location = (890+pos_changer*90),position_f
    pos_changer=pos_changer*-1
    position_f=position_f-50
    out_node.file_slots.remove(out_node.inputs[0])
    out_node.file_slots.new(cur_out)
    out_node.file_slots[cur_out].use_node_format=False
    out_node.file_slots[cur_out].format.file_format="JPEG"    
    out_node.base_path=current_out_path
    if cur_out=='Albedo' : 
	    less_Than = tree.nodes.new('CompositorNodeMath') 
	    mult_albedo_node = tree.nodes.new('CompositorNodeMixRGB')
	    add_albedo_node = tree.nodes.new('CompositorNodeMixRGB')
	    add_albedo_emit_node = tree.nodes.new('CompositorNodeMixRGB')
	    less_Than.location = 330,200
	    mult_albedo_node.location = 480,200
	    add_albedo_node.location = 630,200
	    add_albedo_emit_node.location = 780,200
	    less_Than.operation='LESS_THAN'
	    mult_albedo_node.blend_type='MULTIPLY'
	    add_albedo_node.blend_type='ADD'            
	    add_albedo_emit_node.blend_type='ADD'            
	    less_Than.inputs[1].default_value=0.0039
	    link = links.new(NodeRLayers.outputs['DiffCol'], less_Than.inputs[0])
	    link = links.new(less_Than.outputs[0], mult_albedo_node.inputs[1])
	    link = links.new(NodeRLayers.outputs['GlossCol'], mult_albedo_node.inputs[2])
	    link = links.new(mult_albedo_node.outputs[0], add_albedo_node.inputs[1])
	    link = links.new(NodeRLayers.outputs['DiffCol'], add_albedo_node.inputs[2])
	    link = links.new(add_albedo_node.outputs[0], add_albedo_emit_node.inputs[1])
	    link = links.new(NodeRLayers.outputs['Emit'], add_albedo_emit_node.inputs[2])
	    link = links.new(add_albedo_emit_node.outputs[0], out_node.inputs[cur_out])
	    continue
        
    if cur_out=='Lightmap' : 
        add_diff_emit_Light = tree.nodes.new('CompositorNodeMixRGB') 
        add_diff_emit_spec_Light = tree.nodes.new('CompositorNodeMixRGB')
        add_diff_emit_spec_trans_Light = tree.nodes.new('CompositorNodeMixRGB')
        add_diff_emit_spec_trans_env_Light = tree.nodes.new('CompositorNodeMixRGB')

        add_diff_emit_Light.location = 1200,200
        add_diff_emit_spec_Light.location = 1200,0
        add_diff_emit_spec_trans_Light.location = 1200,-200
        add_diff_emit_spec_trans_env_Light.location = 1200,-400
        add_diff_emit_Light.blend_type='ADD'            
        add_diff_emit_spec_Light.blend_type='ADD'
        add_diff_emit_spec_trans_Light.blend_type='ADD'
        add_diff_emit_spec_trans_env_Light.blend_type='ADD'
        link = links.new(add_node.outputs[0], add_diff_emit_Light.inputs[1])
        link = links.new(NodeRLayers.outputs['Emit'], add_diff_emit_Light.inputs[2])
        link = links.new(add_diff_emit_Light.outputs[0], add_diff_emit_spec_Light.inputs[1])
        link = links.new(add_node_s.outputs[0], add_diff_emit_spec_Light.inputs[2])
        link = links.new(add_diff_emit_spec_Light.outputs[0], add_diff_emit_spec_trans_Light.inputs[1])
        link = links.new(add_node_tr.outputs[0], add_diff_emit_spec_trans_Light.inputs[2])
        link = links.new(add_diff_emit_spec_trans_Light.outputs[0], add_diff_emit_spec_trans_env_Light.inputs[1])
        link = links.new(NodeRLayers.outputs['Env'], add_diff_emit_spec_trans_env_Light.inputs[2])
        link = links.new(add_diff_emit_spec_trans_env_Light.outputs[0], out_node.inputs[cur_out])
        continue

    if cur_out=='Diffuse' or cur_out=='Specular' or cur_out=='Transmission': 
        if cur_out=='Diffuse':
            add_node = tree.nodes.new('CompositorNodeMixRGB') 
            mult_node = tree.nodes.new('CompositorNodeMixRGB')
            add_emit_node = tree.nodes.new('CompositorNodeMixRGB')
            add_node.location = 330,0
            mult_node.location = 480,0
            add_emit_node.location = 630,0
            add_node.blend_type='ADD'
            mult_node.blend_type='MULTIPLY'
            add_emit_node.blend_type='ADD'            
            link = links.new(NodeRLayers.outputs['DiffDir'], add_node.inputs[1])
            link = links.new(NodeRLayers.outputs['DiffInd'], add_node.inputs[2])
            link = links.new(add_node.outputs[0], mult_node.inputs[1])
            link = links.new(NodeRLayers.outputs['DiffCol'], mult_node.inputs[2])
            #link = links.new(mult_node.outputs[0], add_emit_node.inputs[1])
            #link = links.new(NodeRLayers.outputs['Emit'], add_emit_node.inputs[2])
            #link = links.new(add_emit_node.outputs[0], out_node.inputs[cur_out])
            link = links.new(mult_node.outputs[0], out_node.inputs[cur_out])              
        if cur_out=='Specular':
            add_node_s = tree.nodes.new('CompositorNodeMixRGB') 
            mult_node_s = tree.nodes.new('CompositorNodeMixRGB')
            add_node_s.location = 330,-570
            mult_node_s.location = 480,-570
            add_node_s.blend_type='ADD'
            mult_node_s.blend_type='MULTIPLY'
            link = links.new(NodeRLayers.outputs['GlossDir'], add_node_s.inputs[1])
            link = links.new(NodeRLayers.outputs['GlossInd'], add_node_s.inputs[2])
            link = links.new(add_node_s.outputs[0], mult_node_s.inputs[1])
            link = links.new(add_node_s.outputs[0], out_node.inputs[cur_out])
            link = links.new(NodeRLayers.outputs['GlossCol'], mult_node_s.inputs[2])
            link = links.new(mult_node_s.outputs[0], out_node.inputs[cur_out]) 
        if cur_out=='Transmission':
            add_node_tr = tree.nodes.new('CompositorNodeMixRGB') 
            mult_node_tr = tree.nodes.new('CompositorNodeMixRGB')
            add_node_tr.location = 330,-750
            mult_node_tr.location = 480,-750
            add_node_tr.blend_type='ADD'
            mult_node_tr.blend_type='MULTIPLY'
            link = links.new(NodeRLayers.outputs['TransDir'], add_node_tr.inputs[1])
            link = links.new(NodeRLayers.outputs['TransInd'], add_node_tr.inputs[2])
            link = links.new(add_node_tr.outputs[0], mult_node_tr.inputs[1])
            #link = links.new(add_node_tr.outputs[0], out_node.inputs[cur_out])
            link = links.new(NodeRLayers.outputs['TransCol'], mult_node_tr.inputs[2])
            link = links.new(mult_node_tr.outputs[0], out_node.inputs[cur_out]) 

        continue
        
    
    link = links.new(NodeRLayers.outputs[cur_out], out_node.inputs[cur_out])
    if cur_out=='Depth' or cur_out=='IndexOB':
        out_node.file_slots[cur_out].use_node_format=False
        if cur_out=='Depth':
            out_node.file_slots[cur_out].format.file_format="OPEN_EXR"
            map_range_node = tree.nodes.new('CompositorNodeMapRange') 
            map_range_node.location = 170,0
            map_range_node.inputs[2].default_value=200
            link = links.new(NodeRLayers.outputs[cur_out], map_range_node.inputs[0])
            link = links.new(map_range_node.outputs[0], out_node.inputs[cur_out])
        
        if cur_out=='IndexOB':
            out_node.file_slots[cur_out].format.file_format="PNG"
            math_node = tree.nodes.new('CompositorNodeMath') 
            math_node.location = 170,-450
            math_node.operation='DIVIDE'
            math_node.inputs[1].default_value=50
            link = links.new(NodeRLayers.outputs[cur_out], math_node.inputs[0])
            link = links.new(math_node.outputs[0], out_node.inputs[cur_out])