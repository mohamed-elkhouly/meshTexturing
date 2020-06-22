%% Script to extract the albedo map from the RGB images of the recorded data
%% Initialize variables.
clear all;
path = '/home/elkhouly/rgbd2lux_linux/dataset/room4a/data/'; % specify path to the data which should be in .mat format otherwise you will need to read the images manually
addpath('/home/elkhouly/rgbd2lux_linux/libs+tools/photometricStereo')
% create list of existing files in the folder with .mat extenssion
fileList = dir(strcat(path,'*.mat'));
files = {fileList.name}';
files = natsortfiles(files);

% initialize matrices to be used
imagesGamma2Gray = [];
rgbImages = [];

% loop through files
for i = 1:length(fileList)
    filename = strcat(path,files{i});

    %% Open the text file.
    load(filename,'colorImages');

    rgbImages = cat(4, rgbImages, colorImages(:,:,:,end));
    imagesGamma2Gray = cat(3, imagesGamma2Gray, rgb2gray(colorImages(:,:,:,end)));
    %% Clear temporary variables
    clearvars filename ans colorImages;
end
test_photometric_stereo_IIT
idcs   = strfind(path,filesep);
path = path(1:idcs(end-1)); 
save(strcat(path,'albedo.mat'), 'A', 'imagesGamma2Gray', 'rgbImages');
clearvars fileList files i path ss img_height img_width nframes X XX f idcs