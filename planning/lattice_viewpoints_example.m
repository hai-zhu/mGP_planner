% an example to show lattice viewpoints samples
close all
clear all
clear 
clc 

%% Load data
% surface mesh
data_mesh = load('simple_cylinder_solid.mat');
TR = data_mesh.TR;


%% Parameters
[map_parameters, sensor_parameters, planning_parameters, optimization_parameters, ...
    matlab_parameters] = load_parameteres(TR);

%% lattice viewpoints
cylinder_center = [6; 6; 11];
cylerder_radius = 6;
cylerder_height = 21;
sensor_range = 4;
xy_num= 6;
xy = zeros(2, xy_num);
phi = zeros(1, xy_num);
da = 2*pi/xy_num;
dphi = deg2rad(30);
for i = 1 : xy_num
    xy(1, i) = (cylerder_radius + sensor_range) * cos((i-1)*da) + cylinder_center(1);
    xy(2, i) = (cylerder_radius + sensor_range) * sin((i-1)*da) + cylinder_center(2);
    phi(1, i) = -pi + da*(i-1);
end
h_step = 4;
h_num = 24 / h_step;
lattice_viewpoints = [];
for i = 1 : h_num
    lattice_viewpoints = [lattice_viewpoints; ...
                          xy', h_step*i*ones(xy_num,1), phi'-dphi; ...
                          xy', h_step*i*ones(xy_num,1), phi'; ...
                          xy', h_step*i*ones(xy_num,1), phi'+dphi;];
end
num_lattice_viewpoints = size(lattice_viewpoints, 1);

%% Visualization
% surface mesh
fig_main = figure;
hold on;
grid on;
axis([-6 18 -6 18 0 25]);
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

% lattice viewpoints
for i = 1 : num_lattice_viewpoints
%     pause;
    % pos
    cam_pos = lattice_viewpoints(i, 1:3);
    plot3(ax_main, cam_pos(1), cam_pos(2), cam_pos(3), ...
        'Color', 'k', 'Marker', 'o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    % cam direction
    cam_yaw = lattice_viewpoints(i, 4);
    u = 2*cos(cam_yaw);
    v = 2*sin(cam_yaw);
    w = 0;
    quiver3(ax_main, cam_pos(1), cam_pos(2), cam_pos(3), u, v, w, ...
        'Color', 'b', 'LineWidth', 2.0, 'MaxHeadSize', 0.8);
    % cam fov
    plot_camera_fov(ax_main, cam_pos', 0, sensor_parameters.cam_pitch, cam_yaw, ...
        sensor_parameters.fov_x, sensor_parameters.fov_y, ...
        sensor_parameters.fov_range_max, 'r');
end

%% Find LoS neighbors of each lattic
lattice_los_neighbors = cell(num_lattice_viewpoints, 1);
for i = 1 : num_lattice_viewpoints
    lattice_los_neighbors{i} = i;
    lattice_i = lattice_viewpoints(i, :)';
    for j = 1 : num_lattice_viewpoints
        if j == i
            continue;
        else
            lattice_j = lattice_viewpoints(j, :)';
            % test of i and j are in los
            ij_in_los = if_in_los(lattice_i(1:3), lattice_j(1:3), map_parameters);
            if (ij_in_los)
                lattice_los_neighbors{i} = [lattice_los_neighbors{i}; j];
            end
        end
    end
end

save('cylinder_lattice_viewpoints_1.mat', 'lattice_viewpoints', 'lattice_los_neighbors'); 
