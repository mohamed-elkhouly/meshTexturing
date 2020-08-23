import bpy
import bmesh
import sys
import os
import time
import numpy as np

import bpy_extras
from mathutils import Matrix
from mathutils import Vector

def get_calibration_matrix_K_from_blender_2(mode='simple'):

    scene = bpy.context.scene

    scale = scene.render.resolution_percentage / 100
    width = scene.render.resolution_x * scale # px
    height = scene.render.resolution_y * scale # px

    camdata = scene.camera.data

    if mode == 'simple':

        aspect_ratio = width / height
        K = np.zeros((3,3), dtype=np.float32)
        K[0][0] = width / 2 / np.tan(camdata.angle / 2)
        K[1][1] = height / 2. / np.tan(camdata.angle / 2) * aspect_ratio
        K[0][2] = width / 2.
        K[1][2] = height / 2.
        K[2][2] = 1.
        K.transpose()
    
    if mode == 'complete':

        focal = camdata.lens # mm
        sensor_width = camdata.sensor_width # mm
        sensor_height = camdata.sensor_height # mm
        pixel_aspect_ratio = scene.render.pixel_aspect_x / scene.render.pixel_aspect_y

        if (camdata.sensor_fit == 'VERTICAL'):
            # the sensor height is fixed (sensor fit is horizontal), 
            # the sensor width is effectively changed with the pixel aspect ratio
            s_u = width / sensor_width / pixel_aspect_ratio 
            s_v = height / sensor_height
        else: # 'HORIZONTAL' and 'AUTO'
            # the sensor width is fixed (sensor fit is horizontal), 
            # the sensor height is effectively changed with the pixel aspect ratio
            pixel_aspect_ratio = scene.render.pixel_aspect_x / scene.render.pixel_aspect_y
            s_u = width / sensor_width
            s_v = height * pixel_aspect_ratio / sensor_height

        # parameters of intrinsic calibration matrix K
        alpha_u = focal * s_u
        alpha_v = focal * s_v
        u_0 = width / 2
        v_0 = height / 2
        skew = 0 # only use rectangular pixels

        K = np.array([
           [alpha_u,    skew, u_0],
           [      0, alpha_v, v_0],
           [      0,       0,   1]
        ], dtype=np.float32)
        
        
    return Matrix(K)



#---------------------------------------------------------------
# 3x4 P matrix from Blender camera
#---------------------------------------------------------------

# Build intrinsic camera parameters from Blender camera data
#
# See notes on this in 
# blender.stackexchange.com/questions/15102/what-is-blenders-camera-projection-matrix-model
def get_calibration_matrix_K_from_blender(camd):
    f_in_mm = camd.lens
    scene = bpy.context.scene
    resolution_x_in_px = scene.render.resolution_x
    resolution_y_in_px = scene.render.resolution_y
    scale = scene.render.resolution_percentage / 100
    sensor_width_in_mm = camd.sensor_width
    sensor_height_in_mm = camd.sensor_height
    pixel_aspect_ratio = scene.render.pixel_aspect_x / scene.render.pixel_aspect_y
    if (camd.sensor_fit == 'VERTICAL'):
        # the sensor height is fixed (sensor fit is horizontal), 
        # the sensor width is effectively changed with the pixel aspect ratio
        s_u = resolution_x_in_px * scale / sensor_width_in_mm / pixel_aspect_ratio 
        s_v = resolution_y_in_px * scale / sensor_height_in_mm
    else: # 'HORIZONTAL' and 'AUTO'
        # the sensor width is fixed (sensor fit is horizontal), 
        # the sensor height is effectively changed with the pixel aspect ratio
        pixel_aspect_ratio = scene.render.pixel_aspect_x / scene.render.pixel_aspect_y
        s_u = resolution_x_in_px * scale / sensor_width_in_mm
        s_v = resolution_y_in_px * scale * pixel_aspect_ratio / sensor_height_in_mm
        
    #print('focal')
    #print(sensor_width_in_mm)
    #print(sensor_height_in_mm)
    #print(f_in_mm*resolution_x_in_px * scale * pixel_aspect_ratio / sensor_width_in_mm)
    #print(f_in_mm*resolution_y_in_px * scale * pixel_aspect_ratio / sensor_height_in_mm)
    # Parameters of intrinsic calibration matrix K
    alpha_u = f_in_mm * s_u
    alpha_v = f_in_mm * s_v
    u_0 = resolution_x_in_px * scale / 2
    v_0 = resolution_y_in_px * scale / 2
    skew = 0 # only use rectangular pixels

    K = Matrix(
        ((alpha_u, skew,    u_0),
        (    0  , alpha_v, v_0),
        (    0  , 0,        1 )))
    return K

# Returns camera rotation and translation matrices from Blender.
# 
# There are 3 coordinate systems involved:
#    1. The World coordinates: "world"
#       - right-handed
#    2. The Blender camera coordinates: "bcam"
#       - x is horizontal
#       - y is up
#       - right-handed: negative z look-at direction
#    3. The desired computer vision camera coordinates: "cv"
#       - x is horizontal
#       - y is down (to align to the actual pixel coordinates 
#         used in digital images)
#       - right-handed: positive z look-at direction
def get_3x4_RT_matrix_from_blender(cam):
    # bcam stands for blender camera
    R_bcam2cv = Matrix(
        ((1, 0,  0),
         (0, -1, 0),
         (0, 0, -1)))

    # Transpose since the rotation is object rotation, 
    # and we want coordinate rotation
    # R_world2bcam = cam.rotation_euler.to_matrix().transposed()
    # T_world2bcam = -1*R_world2bcam * location
    #
    # Use matrix_world instead to account for all constraints
    location, rotation = cam.matrix_world.decompose()[0:2]
    R_world2bcam = rotation.to_matrix().transposed()

    # Convert camera location to translation vector used in coordinate changes
    # T_world2bcam = -1*R_world2bcam*cam.location
    # Use location from matrix_world to account for constraints:     
    T_world2bcam = -1*R_world2bcam * location

    # Build the coordinate transform matrix from world to computer vision camera
    # NOTE: Use * instead of @ here for older versions of Blender
    # TODO: detect Blender version
    R_world2cv = R_bcam2cv*R_world2bcam
    T_world2cv = R_bcam2cv*T_world2bcam

    # put into 3x4 matrix
    RT = Matrix((
        R_world2cv[0][:] + (T_world2cv[0],),
        R_world2cv[1][:] + (T_world2cv[1],),
        R_world2cv[2][:] + (T_world2cv[2],)
         ))
    return RT

def get_3x4_P_matrix_from_blender(cam):
    K = get_calibration_matrix_K_from_blender_2('simple')
    RT = get_3x4_RT_matrix_from_blender(cam)
    return K*RT, K, RT

# ----------------------------------------------------------
# Alternate 3D coordinates to 2D pixel coordinate projection code
# adapted from https://blender.stackexchange.com/questions/882/how-to-find-image-coordinates-of-the-rendered-vertex?lq=1
# to have the y axes pointing up and origin at the top-left corner
def project_by_object_utils(cam, point):
    scene = bpy.context.scene
    co_2d = bpy_extras.object_utils.world_to_camera_view(scene, cam, point)
    render_scale = scene.render.resolution_percentage / 100
    render_size = (
            int(scene.render.resolution_x * render_scale),
            int(scene.render.resolution_y * render_scale),
            )
    return Vector((co_2d.x * render_size[0], render_size[1] - co_2d.y * render_size[1]))

# ----------------------------------------------------------



lens=18;
#shift_x=0;
#shift_y=0;
sensor_height=18;
sensor_width=32; 
#sensor_fit=AUTO;
width = 1280;
height = 1024;
render_samples=3000
output_format='JPEG'


#K = [[fx, 0, u0], [0, fy, v0], [0, 0, 1]]
K = np.array([[1076.01, 0, 635.509 ], [0, 1076.38, 511.001], [0, 0, 1]])
#bpy.context.scene.camera.data.lens=(K[0, 0] + K[1, 1]) / 2 * sensor_width / width
bpy.context.scene.camera.data.shift_x=(width/2 - K[0, 2]) / width
bpy.context.scene.camera.data.shift_y=(K[1, 2] - height/2) / width
bpy.context.scene.camera.data.sensor_width=sensor_width
bpy.context.scene.camera.data.sensor_height=sensor_height
bpy.context.scene.camera.data.sensor_fit='AUTO'

bpy.context.scene.camera.data.lens=lens
#bpy.context.scene.camera.data.shift_x=0
#bpy.context.scene.camera.data.shift_y=0
#bpy.context.scene.camera.data.sensor_width=35
#bpy.context.scene.camera.data.sensor_height=35



obj_camera = bpy.data.objects["Camera"]
bpy.data.scenes['Scene'].cycles.samples=render_samples

 
bpy.data.scenes['Scene'].render.resolution_x=width
bpy.data.scenes['Scene'].render.resolution_y=height
bpy.data.scenes['Scene'].render.resolution_percentage=100
bpy.data.scenes['Scene'].render.image_settings.file_format=output_format

bpy.context.scene.render.engine = 'CYCLES'
scene = bpy.context.scene.cycles.device = 'GPU'
blend_file_path = bpy.data.filepath
directory = os.path.dirname(blend_file_path) 
path=os.path.join(directory,"rendered_images/")


try:
    os.mkdir(path)
except:
    d=[]


#sunny room
cam_state=[
[4.45561,	-1.76682,	3.13218,		88.6962,	0.145373,	64.064],
[4.45561,	0.91318,	3.13218,		88.6962,	0.145373,	92.864],
[-1.93804,	-0.4712,	0.924459,		88.6962,	0.145345,	49.064],
[-1.32757,	1.5457,	1.03601,		88.6962,	0.145338,	86.364],
[-1.32757,	1.5457,	1.03601,		106.096,	0.145338,	126.964],
[-1.32757,	1.5457,	1.03601,		106.096,	0.145338,	214.864],
[1.00999,	-2.72009,	0.679639,		115.896,	0.145349,	376.964],
[1.00999,	-2.72009,	0.679639,		115.896,	0.145349,	312.364],
[3,	0.5,	1.5,		100,	0,	0],
[3,	0.5,	1.5,		100,	0,	90],
[3,	0.5,	1.5,		100,	0,	180],
[3,	0.5,	1.5,		100,	0,	270],
[-2,	0.5,	1.5,		100,	0,	0],
[-2,	0.5,	1.5,		100,	0,	90],
[-2,	0.5,	1.5,		100,	0,	180],
[-2,	0.5,	1.5,		100,	0,	270],						
[-0.819414,	5.49894,	2.64762,		96.1512,	0,	179.863],
[1.54008,	41.5938,	2.99863,		124.134,	-2.11271,	-182.319],
[1.54008,	41.5938,	2.99863,		51.734,	-2.11271,	-141.019],
[1.54008,	41.5938,	2.99863,		55.234,	-2.11271,	-222.019],
[2.25008,	0.213751,	3.15863,		24.1387,	0.08231,	-1.22041],
[-0.59992,	0.213751,	3.15863,		35.8387,	0.08231,	-1.22041],
[-0.06992,	-2.97625,	-0.00137,		48.3387,	0.08231,	-0.120412],
[-3.55992,	1.23375,	2.99863,		8.9387,	-9.81769,	-3.02041],
]


'''
# r tamu
cam_state=[
[-3,	0.50,	1.5,		85,	0,	0],
[-3,	0.50,	1.5,		85,	0,	90],
[-3,	0.50,	1.5,		85,	0,	180],
[-3,	0.50,	1.5,		85,	0,	270],
						
						
[3.5,	0.50,	1.5,		85,	0,	0],
[3.5,	0.50,	1.5,		85,	0,	90],
[3.5,	0.50,	1.5,		85,	0,	180],
[3.5,	0.50,	1.5,		85,	0,	270],
						
						
[-4.41605,	2.6691,	1.52029,		90,	0,	130],
[4,	-2.5,	1,		90,	0,	50],

[25.567,	48.5936,	1.03577,		89.9544,	0,	148.237],
[-1.79995,	56.6059,	1.41061,		89.5533,	0,	179.119],
[20.0555,	15.4053,	0.471337,		91.1577,	0,	118.557],
[4.22481,	5.30463,	0.8475,		91.1577,	0,	108.129],
[4.02076,	6.04079,	0.896966,		90.7566,	0,	114.145],
[0.694581,	-2.6128,	1.30498,		82.633,	-0.100114,	61.3641],
[0.272262,	2.45263,	0.894514,		90,	0,	-177.828],
[-4.59098,	1.83276,	2.02743,		9.28715,	2.50011,	-91.4387],
[-4.60098,	-1.98724,	0.40743,		95.6871,	-0.499895,	-14.5387],
]




#marbled bath
cam_state=[[1.69079,	-1.32525,	0.959639,		85,	0,	330],
[-2.33277,	-0.830102,	0.84766,		85,	0,	230],
[-0.0801774,	-0.101783,	1.5,		85,	0,	0],
[-0.0801774,	-0.101783,	1.5,		85,	0,	90],
[-0.0801774,	-0.101783,	1.5,		85,	0,	180],
[-0.0801774,	-0.101783,	1.5,		85,	0,	270],
[-9.4325,	12.6745,	   1.05006,		90,	0,	-150],
[-16.1311,	4.11822,	1.05006,		90,	0,	-105],
[-7.42233,	-2.49432,	1.05006,		90,	0,	-60.5571],
[1.09509,	-1.41303,	0.748941,		100,	0,	60],
[-2.13491,	-1.31303,	0.0489411,		115.5,	0,	-30],
[2.30509,	-1.53303,	0.748941,		50.1,	0,	22],
[2.30509,	-1.53303,	2.00894,		48.2,	0,	44.8],
[2.30509,	1.57697,	0.85894,		92,	0,	139.7],
[2.30509,	1.57697,	0.85894,		153,	0,	139.7],
[0.0946019,	-0.338462,	0.66184,		44.692,	0,	245],
[-2.8554,	0.391538,	0.09184,		67.192,	0,	245],
[-2.3754,	1.26154,	0.40184,		74.292,	0,	-29.3],
[-1.5654,	1.44154,	0.26184,		74.292,	0,	-29.3],
]

'''

blend_file_path = bpy.data.filepath
directory = os.path.dirname(blend_file_path) 
path=os.path.join(directory,"cam_info")
try:
    os.mkdir(path)
except:
    print ("Creation of the directory %s failed" % path)
    if os.path.isdir(path):
        
        for root, dirs, files in os.walk(path):
            for file in files:
                os.remove(os.path.join(root, file))
                
path_frame=os.path.join(directory,"cam_info/frame")
try:
    os.mkdir(path_frame)
except:
    print ("Creation of the directory %s failed" % path_frame)
    if os.path.isdir(path_frame):
        
        for root, dirs, files in os.walk(path_frame):
            for file in files:
                os.remove(os.path.join(root, file))

path_camera=os.path.join(directory,"cam_info/camera")
try:
    os.mkdir(path_camera)
except:
    print ("Creation of the directory %s failed" % path_camera)
    if os.path.isdir(path_camera):
        
        for root, dirs, files in os.walk(path_camera):
            for file in files:
                os.remove(os.path.join(root, file))
                

for count,state in enumerate(cam_state):
	bpy.context.scene.frame_set(count)
    obj_camera.location.x = state[0]
    obj_camera.location.y = state[1]
    obj_camera.location.z = state[2]

    obj_camera.rotation_euler.x = state[3]*3.14/180
    obj_camera.rotation_euler.y = state[4]*3.14/180
    obj_camera.rotation_euler.z = state[5]*3.14/180
    
    bpy.context.scene.update()
    
    # Insert your camera name here
    #cam = bpy.data.objects['Camera.001']
    P, K, RT = get_3x4_P_matrix_from_blender(obj_camera)
    #print("K")
    #print(K)
    #print("RT")
    #print(RT)
    #print("P")
    #print(P)
    K=np.array(K)
    RT=np.array(RT)
    
    R=RT[:3,:3]
    T=RT[:,3]
    R=R.transpose() 
    T=(-1*R).dot(T)
    #print(T.shape)
    #print(R.shape)
    RT=np.c_[R, T]
    #RT=np.append(R,T, axis=1)
    #np.savetxt(("frame-"+".pose.txt"),RT,fmt="%5.5f")
    
    new_column = [[0], [0], [0]];
    new_row = [[0, 0, 0, 1]];
    K = np.append(K, new_column, axis=1)
    K = np.append(K, new_row, axis=0)
    RT = np.append(RT, new_row, axis=0)
    file_name=str(count).zfill(6)
    np.savetxt((path+"/scene_1_intrinsics.txt"), K,fmt="%5.5f")
    np.savetxt((path_camera+"/frame-"+file_name+".pose.txt"), RT,fmt="%5.5f")
    bpy.context.scene.render.filepath = path_frame+'/'+'frame-'+file_name+'.color.jpg'
    bpy.ops.render.render(write_still = True)
    
        
    