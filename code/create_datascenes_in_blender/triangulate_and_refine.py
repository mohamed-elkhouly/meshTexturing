
import bpy
import bmesh
from mathutils import Vector
import os
import mathutils
import subprocess
import time
from shutil import copyfile
bpy.app.debug_wm = False
    
# 3D tri area ABC is half the length of AB cross product AC 
def tri_area( co1, co2, co3 ):
    return (co2 - co1).cross( co3 - co1 ).length / 2.0

def mesh_refine_blender(obj,maxfacearea=0.008):
    #'''
    #reduceFraction  agressiveness  maxfacearea   number_of_iterations   max face area
    reduceFraction=0;
    agressiveness=0;
    minfacearea=0;
    number_of_iterations=0;
    # Construct bmesh
    
    obj.select = True
    # make the current selected object we're at the active one
    bpy.context.scene.objects.active = obj
    
    if bpy.ops.object.mode_set.poll():
        bpy.ops.object.mode_set(mode='EDIT')
    else:
        print("mode_set() context is incorrect, current mode is", bpy.context.mode)
        scn = bpy.context.scene
        scn.objects.link(obj)        
    
    
    
    try:
        bpy.ops.object.mode_set(mode='EDIT')
    except:
        print('can not convert to edit mode')
        print(bpy.ops.object.mode)        
    #maxfacearea=0.008
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.quads_convert_to_tris(quad_method='BEAUTY', ngon_method='BEAUTY')
    obj_edit = bpy.context.edit_object
    #print('1')
    me = obj_edit.data
    #print('2')
    bm = bmesh.from_edit_mesh(me)
    #print('3')
    # enumerate the faces
    for face in bm.faces:
        #print('4')
        # Get the face area (can also be 'face.calc_area()')
        face_area = tri_area( *(v.co for v in face.verts) )
        #print('5')
        if(face_area>maxfacearea):
            #print('6')            
            required_div=face_area/maxfacearea
            #print('7')
            #print('here ' , required_div)
            #subdivide the face
            bpy.ops.mesh.subdivide(number_cuts=1)
            #print('8')
 

blend_file_path = bpy.data.filepath
directory = os.path.dirname(blend_file_path) 
path=os.path.join(directory,"temp_directory")
# try:
#     os.mkdir(path)
# except OSError:
#     print ("Creation of the directory %s failed" % path)
#     if os.path.isdir(path):
        
#         for root, dirs, files in os.walk(path):
#             for file in files:
#                 os.remove(os.path.join(root, file))
#         #copyfile(os.path.join(directory,"SimplifyMesh.exe "), os.path.join(path,"SimplifyMesh.exe "))
#         directory=path
# else:
#     print ("Successfully created the directory %s " % path)
#     #copyfile(os.path.join(directory,"SimplifyMesh.exe "), os.path.join(path,"SimplifyMesh.exe "))
#     directory=path 
        
try:
    bpy.ops.object.mode_set(mode='OBJECT')
except:
    d=[]
#print('#####################################')
obj_num=1
meshes_to_remove = set()

try:
    bpy.ops.object.mode_set(mode='OBJECT')
except:
    d=[]
bpy.ops.object.select_all(action = 'DESELECT')
            
for obj in bpy.data.objects:
    # if the object is a mesh and it is not hidden, do the following

     if(obj.type== "CURVE" and obj.hide==False):
        try:
            bpy.ops.object.mode_set(mode='OBJECT')
        except:
            d=[]
        bpy.ops.object.select_all(action = 'DESELECT')
        #select the current object
        obj.select = True
        # make the current selected object we're at the active one
        bpy.context.scene.objects.active = obj
        bpy.ops.object.convert(target='MESH')
        
     if obj.type == "MESH" and obj.hide==False:
        try:
            bpy.ops.object.mode_set(mode='OBJECT')
        except:
            d=[]
        #print('1')
        file_name=str(obj_num)+ '.obj'
        new_file_name=str(obj_num)+ 'new.obj'
        #print('1')
        bpy.ops.object.select_all(action = 'DESELECT')
#       #print(obj.matrix_world)
        #print(obj.hide)
        #select the current object
        obj.select = True
        # make the current selected object we're at the active one
        bpy.context.scene.objects.active = obj
        
        
        # UNPARENT THE OBJECT IF IT IS A CHILD to other but keep transform.
        try:
            bpy.ops.object.parent_clear(type='CLEAR_KEEP_TRANSFORM')
        except:
            continue
        bpy.ops.object.make_single_user(object=True,obdata=True,material=True, animation=True)
        
        
        # Set the current scale to object as the original scale (e.g. if the object enlarged, this enlarge will be as its original size)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)


        bpy.ops.object.modifier_add(type='DECIMATE')
        obj.modifiers["Decimate"].delimit={'NORMAL', 'MATERIAL', 'SEAM'}
        obj.modifiers["Decimate"].angle_limit=5*3.14/180
        obj.modifiers["Decimate"].decimate_type="DISSOLVE"
        
        if  obj.modifiers:
            for mod in  bpy.context.object.modifiers:
                try:
                    bpy.ops.object.modifier_apply(modifier=mod.name)
                except:
                    d=[]
        
        bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY')
        
        
        
        
        #print(bpy.context.active_object.name)
        
        try:
            bpy.ops.object.mode_set(mode='EDIT')
            bpy.ops.mesh.select_all(action='SELECT')
            bpy.ops.mesh.remove_doubles()
            bpy.ops.object.mode_set(mode='OBJECT')
            obj.select = True
            # make the current selected object we're at the active one
            bpy.context.scene.objects.active = obj
        
            d=[]
            mesh_refine_blender(obj,0.008)
        except:
            try:
                bpy.ops.object.mode_set(mode='OBJECT')
            except:
                d=[]
            print(obj.name, ' deleted',obj.type)
            bpy.ops.object.delete()


# cycle though all objects
try:
    bpy.ops.object.mode_set(mode='OBJECT')
except:
    d=[]
for obj in bpy.data.objects:
    if obj.type == "MESH" and obj.hide_render==True:
        bpy.ops.object.select_all(action = 'DESELECT')
        #select the current object
        obj.select = True
        # make the current selected object we're at the active one
        bpy.context.scene.objects.active = obj
        bpy.ops.object.delete()

            
print('done11')              
print('done')
 







   