
import bpy
import bmesh
from mathutils import Vector
import os
import mathutils
import subprocess
import time
from shutil import copyfile
bpy.app.debug_wm = True

def agreement_between_strings(str1,str2):
    sum=0
    for i in range(0, min(len(str1),len(str2))):
        if (str1[i]==str2[i]):
            sum=sum+1;
        
    return sum

def assign_original_material(new_mat,old_mat):
    size_of_old=-1;
    while(1):
        try:
            size_of_old=size_of_old+1
            print(old_mat[size_of_old])
        except:
            break
    
    #print('size_of_old')
    #print(size_of_old)
    
    
    size_of_new=-1;
    while(1):
        try:
            size_of_new=size_of_new+1
            print(new_mat[size_of_new])
        except:
            break
    #print('size_of_new')
    #print(size_of_new)
    
    mat_indexes=[i for i in range (0,size_of_new)]
    for i in range(0, size_of_new):
        max_agreement=0
        max_material_agreement_index=0
        for j in range(0, size_of_old):
            curr_agr=agreement_between_strings(new_mat[i].name,old_mat[j].name)
            if(curr_agr>max_agreement):
                max_agreement=curr_agr;
                max_material_agreement_index=j;
        mat_indexes[i]=max_material_agreement_index
    return mat_indexes

# 3D tri area ABC is half the length of AB cross product AC 
def tri_area( co1, co2, co3 ):
    return (co2 - co1).cross( co3 - co1 ).length / 2.0

def export_to_wavefront_obj(directory, file_name, triangles=True, materials=True):
    target_file = os.path.join(directory, file_name)
    bpy.ops.export_scene.obj(filepath=target_file, use_selection=True, use_normals=True, use_materials=materials,
                             use_edges=False, use_triangles=triangles)
    return True


def import_from_wavefront_obj(directory,file_name):
    try:
        target_file = os.path.join(directory,file_name)
        bpy.ops.import_scene.obj(filepath=target_file,use_edges=False)
        #loaded_obj = bpy.context.object
        sel = bpy.context.selected_objects

        for obj in sel:
            d=[]
            #print(obj.name)
            #print(loaded_obj.name)
        return obj
    except:
        return False
    

def quadratic_simplify(directory,file_name,obj_num,agressiveness=1):
    #'''

    #SimplifyMesh.exe reduceFraction  agressiveness  maxfacearea   number_of_iterations  
    reduceFraction=0.01;
    #agressiveness=1;
    minfacearea=20;
    number_of_iterations=100;
    FNULL = open(os.devnull, 'w')    #use this if you want to suppress output to stdout from the subprocess
    args = os.path.join(directory,"SimplifyMesh.exe ") + os.path.join(directory,file_name)+" "+ os.path.join(directory,obj_num)+"new.obj "+str(reduceFraction)+" "+str(agressiveness)+" "+str(minfacearea)+" "+str(number_of_iterations)+" "
    #args = directory+"SimplifyMesh.exe " +directory+"region10.obj "+ directory+"new.obj 0 0 0 0 0.1"
    subprocess.call(args, stdout=FNULL, stderr=FNULL, shell=False)
    #'''
    
def mesh_refine(directory,file_name,obj_num,maxfacearea=0.008):
    #'''
    #reduceFraction  agressiveness  maxfacearea   number_of_iterations   max face area
    reduceFraction=0;
    agressiveness=0;
    minfacearea=0;
    number_of_iterations=0;
    #maxfacearea=0.008
    FNULL = open(os.devnull, 'w')    #use this if you want to suppress output to stdout from the subprocess
    if (os.path.exists(os.path.join(directory,obj_num)+"new.obj")):
        args = os.path.join(directory,"SimplifyMesh.exe ") + os.path.join(directory,obj_num)+"new.obj "+ os.path.join(directory,obj_num)+"new.obj 0 0 0 0 "+str(maxfacearea)
    else:
        args = os.path.join(directory,"SimplifyMesh.exe ") + os.path.join(directory,obj_num)+".obj "+ os.path.join(directory,obj_num)+"new.obj 0 0 0 0 " +str(maxfacearea)
    
    
    
    subprocess.call(args, stdout=FNULL, stderr=FNULL, shell=False)
    #'''
def process_exists(process_name):
    call = 'TASKLIST', '/FI', 'imagename eq %s' % process_name
    # use buildin check_output right away
    output = subprocess.check_output(call)
    # check in last line for process name
    last_line = output.strip().split(b'\r\n')[-1]
    # because Fail message could be translated
    return last_line.lower().startswith(bytes(process_name.lower(), encoding='utf8'))    

blend_file_path = bpy.data.filepath
directory = os.path.dirname(blend_file_path) 
path=os.path.join(directory,"temp_directory")
try:
    os.mkdir(path)
except OSError:
    print ("Creation of the directory %s failed" % path)
    if os.path.isdir(path):
        
        for root, dirs, files in os.walk(path):
            for file in files:
                os.remove(os.path.join(root, file))
        copyfile(os.path.join(directory,"SimplifyMesh.exe "), os.path.join(path,"SimplifyMesh.exe "))
        directory=path
else:
    print ("Successfully created the directory %s " % path)
    copyfile(os.path.join(directory,"SimplifyMesh.exe "), os.path.join(path,"SimplifyMesh.exe "))
    directory=path 
        
try:
    bpy.ops.object.mode_set(mode='OBJECT')
except:
    d=[]
#print('#####################################')
obj_num=1
meshes_to_remove = set()
# cycle though all selected objects
for obj in bpy.context.scene.objects:
    # if the object is a mesh and it is not hidden, do the following
    if obj.type == "MESH" and obj.hide==False:
        
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
        bpy.ops.object.parent_clear(type='CLEAR_KEEP_TRANSFORM')
        bpy.ops.object.make_single_user(object=True,obdata=True,material=True, animation=True)
        if  obj.modifiers:
            for mod in  bpy.context.object.modifiers:
                try:
                    bpy.ops.object.modifier_apply(modifier=mod.name)
                except:
                    d=[]
        
        bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY')
        #print(bpy.context.active_object.name)
        
        bm = bmesh.new()
        bm.from_mesh(obj.data)
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.001)
        bm.to_mesh(obj.data)
        obj.data.update()
        bm.clear()
        bm.free()
        
        # export model as .obj
        finished=export_to_wavefront_obj(directory,file_name)
        # simplify the exported .obj model
        quadratic_simplify(directory,file_name,str(obj_num))        
        while(process_exists('SimplifyMesh.exe')):
            #print("still running")
            time.sleep(0.1)
        mesh_refine(directory,file_name,str(obj_num))
        while(process_exists('SimplifyMesh.exe')):
            #print("still running")
            time.sleep(0.1)
        
        if(obj):
            d=[]
        new_obj=import_from_wavefront_obj(directory,new_file_name)
        bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY')
        
        
        
        if (new_obj):
            bpy.ops.object.select_all(action = 'DESELECT')
            obj.select = True
            bpy.context.scene.objects.active = obj
            try:
                #new_obj.data.materials.append(obj.data.materials[0])                
                material_counter=0
                mat_indexes=assign_original_material(new_obj.data.materials,obj.data.materials)
                for i in range(0, len(mat_indexes)):
                    new_obj.data.materials[i]=obj.data.materials[mat_indexes[i]]
                new_obj.hide_render=obj.hide_render
                new_obj.hide=obj.hide_render
                temp_name=obj.name
                bpy.ops.object.delete()
                new_obj.name=temp_name
            except:
                print(obj.name)
                temp_name=obj.name
                bpy.ops.object.delete()
                new_obj.name=temp_name
                print('#######################################################################33')
        '''                
        if(obj_num==1):
            break;            
        '''          
        obj_num=obj_num+1  
        obj.select = False
        
print('done11')              
print('done')