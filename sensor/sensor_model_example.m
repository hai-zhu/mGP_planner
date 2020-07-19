close all
clear all
clear 
clc 

%% Load data
% surface mesh
data_mesh = load('cylinder_center.mat');
TR = data_mesh.TR_1;
% triangulation properties
num_faces = size(TR.ConnectivityList, 1);
num_vertices = size(TR.Points, 1);
F_normal = faceNormal(TR);
F_center = incenter(TR);
% sensor model
sensor_parameters.fov_x = deg2rad(60);
sensor_parameters.fov_y = deg2rad(60);
sensor_parameters.fov_range_max = 8;
% camera state
cam_pos = [5; -12; 15];
cam_roll = deg2rad(0);
cam_pitch = deg2rad(15);
cam_yaw = deg2rad(90);
% determine which parts are feasible for taking measurements


%% Visualization
% surface mesh
fig_main = figure;
hold on;
axis([-15 15 -15 15 0 25]);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
ax_main = fig_main.CurrentAxes;
daspect(ax_main, [1 1 1]);
view(ax_main, 3);
h_mesh = trimesh(TR);
h_mesh.FaceColor = 'w';
h_mesh.FaceAlpha = 1;
h_mesh.EdgeColor = 'c';
h_mesh.LineWidth = 0.5;
h_mesh.LineStyle = '-';

% camera
h_cam = plot_camera_fov(ax_main, cam_pos, cam_roll, cam_pitch, cam_yaw, ...
    sensor_parameters.fov_x, sensor_parameters.fov_y, ...
    sensor_parameters.fov_range_max, 'r');


%% Ground truth map
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
F_value = zeros(num_faces, 1);
for iF = 1 : num_faces
    center_iF = F_center(iF, :);
    idx_iF(1:2) = round(center_iF(1:2) / resolution) + 40;
    idx_iF(3) = round(center_iF(3) / resolution);
    F_value(iF) = map_3D(idx_iF(1), idx_iF(2), idx_iF(3));
end
fig_map = figure;
hold on;
axis([-15 15 -15 15 0 25]);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
ax_map = fig_map.CurrentAxes;
daspect(ax_map, [1 1 1]);
view(ax_map, 3);
trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
    TR.Points(:,3), F_value);