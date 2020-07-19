close all
clear all
clear 
clc 

%% Load 3D map and cylinder mesh
data_mesh = load('cylinder_center.mat');
TR = data_mesh.TR_1;
% triangulation properties
num_faces = size(TR.ConnectivityList, 1);
num_vertices = size(TR.Points, 1);
F_normal = faceNormal(TR);
F_center = incenter(TR);

data_map = load('map_3D.mat');
map_3D = data_map.ground_truth_map;
% dimensions [m]
dim_x_env = 40;
dim_y_env = 40;
dim_z_env = 40;
resolution = 0.5;
dim_x = dim_x_env / resolution;
dim_y = dim_y_env / resolution;
dim_z = dim_z_env / resolution;

%% Loop for each face
F_value = zeros(num_faces, 1);
for iF = 1 : num_faces
    center_iF = F_center(iF, :);
    idx_iF(1:2) = round(center_iF(1:2) / resolution) + 40;
    idx_iF(3) = round(center_iF(3) / resolution);
    F_value(iF) = map_3D(idx_iF(1), idx_iF(2), idx_iF(3));
end

%% Visualization
trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
    TR.Points(:,3), F_value);


