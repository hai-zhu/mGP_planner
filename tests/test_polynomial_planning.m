clear all
clear 
clc 

%% Parameters
dim_x_env = [-8, 20];
dim_y_env = [-8, 20];
dim_z_env = [0, 30];
max_vel = 4;
max_acc = 3;

%% Environment
% map environments
data_mesh = load('simple_cylinder_solid.mat');
TR = data_mesh.TR;
num_faces = size(TR.ConnectivityList, 1);
num_vertices = size(TR.Points, 1);
F_normal = faceNormal(TR);
F_center = incenter(TR);
F_points = zeros(num_faces, 3, 3);
for iFace = 1 : num_faces
    F_points(iFace, :, 1) = TR.Points(TR.ConnectivityList(iFace, 1), :);    % 1x3
    F_points(iFace, :, 2) = TR.Points(TR.ConnectivityList(iFace, 2), :);
    F_points(iFace, :, 3) = TR.Points(TR.ConnectivityList(iFace, 3), :);
end
% visualize
fig_map = figure;
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
ax_map = fig_map.CurrentAxes;
% mesh object
h_mesh = trimesh(TR);
h_mesh.FaceColor = 'w';
h_mesh.FaceAlpha = 1;
h_mesh.EdgeColor = 'c';
h_mesh.LineWidth = 0.5;
h_mesh.LineStyle = '-';
axis([dim_x_env dim_y_env dim_z_env]);
daspect(ax_map, [1 1 1]);
view(ax_map, 3);

%% 3D trajectory in obstacle-free env.
% waypoints, the first one is the starting point
waypoints = [0,     0,      4;
             2.46,  0.62,   24.54;
             10.93, 5.54,   22; %19.58;
             16.82, 4.60,   15.02];
% plan trajectory and sample
trajectory = plan_path_waypoints(waypoints, max_vel, max_acc);
[t, p] = sample_trajectory(trajectory, 0.1);
% visualize trajectory
% figure;
hold on;
grid on;
axis([dim_x_env dim_y_env dim_z_env]);
scatter3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 200, 'xk');
h = plot_trajectory_cline(t, p);
daspect([1 1 1]);
view(3);


