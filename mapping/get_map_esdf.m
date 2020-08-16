clear all
clear 

% map environments
data_mesh = load('simple_cylinder_solid.mat');
TR = data_mesh.TR;

FV.faces = TR.ConnectivityList;
FV.vertices = TR.Points;
resolution = 0.5;
dim_x_env = [-8, 20];
dim_y_env = [-8, 20];
dim_z_env = [2, 30];
esdf = mesh_to_esdf(FV, dim_x_env, dim_y_env, dim_z_env, ...
    resolution);

save('cylinder_map_esdf.mat', 'esdf');
