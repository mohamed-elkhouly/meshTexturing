clear all
mesh.scene_name='scene1';
mesh.frame_height=1024;
mesh.frame_width=1280;
mesh=loadSceneData(mesh);
[faces_colors]=getFacesColors_and_TexturingMesh2(mesh);
d=[];
