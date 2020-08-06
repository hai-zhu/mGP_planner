close all
clear all
clear 
clc 

%% Load data
% surface mesh
data_mesh = load('simple_cylinder_solid.mat');
TR = data_mesh.TR;
% triangulation properties
num_faces = size(TR.ConnectivityList, 1);
num_vertices = size(TR.Points, 1);
F_normal = faceNormal(TR);
F_center = incenter(TR);
F_points = zeros(num_faces, 3, 3);
for iFace = 1 : num_faces
    F_points(iFace, :, 1) = TR.Points(TR.ConnectivityList(iFace, 1), :);
    F_points(iFace, :, 2) = TR.Points(TR.ConnectivityList(iFace, 2), :);
    F_points(iFace, :, 3) = TR.Points(TR.ConnectivityList(iFace, 3), :);
end
% sensor model
sensor_parameters.fov_x = deg2rad(60);
sensor_parameters.fov_y = deg2rad(60);
sensor_parameters.fov_range_min = 1;
sensor_parameters.fov_range_max = 8;
sensor_parameters.incidence_range_min = cos(deg2rad(70));
% camera state
% cam_pos = [5; -5; 15];
% cam_yaw = deg2rad(90);
cam_pos = [10; -3; 12];
cam_yaw = deg2rad(120);
cam_roll = deg2rad(0);
cam_pitch = deg2rad(15);
% determine which parts are feasible for taking measurements
F_visible = zeros(num_faces, 1);
faces_visible = [];
for iFace = 1 : num_faces
    in = if_in_cam_fov(F_points(iFace, :, :), F_center(iFace,:)', F_normal(iFace,:)', ...
        cam_pos, cam_roll, cam_pitch, cam_yaw, sensor_parameters);
    F_visible(iFace) = in;
    if in
        faces_visible = [faces_visible; iFace];
    end
end
    

%% Visualization
% surface mesh
fig_main = figure;
hold on;
axis([-8 20 -8 20 0 30]);
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

% camera fov
h_cam = plot_camera_fov(ax_main, cam_pos, cam_roll, cam_pitch, cam_yaw, ...
    sensor_parameters.fov_x, sensor_parameters.fov_y, ...
    sensor_parameters.fov_range_max, 'r');

% visible faces
for iFace = 1 : num_faces
    if F_visible(iFace) == 1
        patch(ax_main, 'XData', F_points(iFace, 1, :), ...
              'YData', F_points(iFace, 2, :), ...
              'ZData', F_points(iFace, 3, :), ...
              'FaceColor', 'b', ... 
              'FaceAlpha', 0.5, ...
              'EdgeColor', 'b');
    end
end


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
    idx_iF(3) = round(center_iF(3) / resolution) + 20;
    F_value(iF) = map_3D(idx_iF(1), idx_iF(2), idx_iF(3));
end
fig_map = figure;
hold on;
axis([-8 20 -8 20 0 30]);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
ax_map = fig_map.CurrentAxes;
daspect(ax_map, [1 1 1]);
view(ax_map, 3);
trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
    TR.Points(:,3), F_value, 'EdgeAlpha', 0);
