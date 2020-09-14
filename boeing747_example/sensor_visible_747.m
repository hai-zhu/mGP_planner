% close all
clear all
clear 
clc 

%% Environment
model_name = 'boeing747';
model.name = model_name;
% mesh
data_mesh = load([model_name, '_mesh.mat']);
model.TR = data_mesh.TR;
TR = data_mesh.TR;
% occupancy
data_occupancy = load([model_name, '_map_occupancy']);
model.occupancy = data_occupancy.occupancy; 
% esdf
data_esdf = load([model_name, '_map_esdf']);
model.esdf = data_esdf.esdf; 
% true temperature field
data_temperature_field = load([model_name, '_temperature_field']);
model.temperature_field = data_temperature_field.F_value;

%% Parameters
[map_parameters, sensor_parameters, planning_parameters, optimization_parameters, ...
    matlab_parameters] = load_parameteres(model);
num_faces = map_parameters.num_faces;
F_normal = map_parameters.F_normal;
F_center = map_parameters.F_center;
F_points = map_parameters.F_points;
dim_x_env = map_parameters.dim_x_env;
dim_y_env = map_parameters.dim_y_env;
dim_z_env = map_parameters.dim_z_env;

%% camera state
viewpoints = [  10      23      30      pi/2];
i = 1;
cam_pos = viewpoints(i, 1:3)';
cam_yaw = sensor_parameters.cam_yaw + viewpoints(i, 4);
cam_roll = sensor_parameters.cam_roll;
cam_pitch = sensor_parameters.cam_pitch;
% determine which parts are feasible for taking measurements
[F_visible, faces_visible] = get_visible_faces(num_faces, F_points, F_center, ...
    F_normal, cam_pos, cam_roll, cam_pitch, cam_yaw, sensor_parameters);
    

%% Visualization
% surface mesh
fig_main = figure;
hold on;
grid on;
axis([dim_x_env, dim_y_env, dim_z_env]);
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
