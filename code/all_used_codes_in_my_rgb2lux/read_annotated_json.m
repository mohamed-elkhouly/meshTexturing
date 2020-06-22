function val=read_annotated_json(scene_name)
fid = fopen([scene_name,'.json']); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);
d=[];