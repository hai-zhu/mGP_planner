% create a set of predefined viewpoints
close all
clear all
clear 
clc 

root_folder = pwd;

%% Environment
model_name = 'cylinder';
model.name = model_name;
% mesh
data_mesh = load([model_name, '_mesh.mat']);
model.TR = data_mesh.TR;
model.valid_faces = data_mesh.valid_faces;
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

%% lattice viewpoints
cylinder_center = [0; 0; 11];
cylerder_radius = 6;
cylerder_height = 21;
sensor_range = 4;
xy_num= 8;
xy = zeros(2, xy_num);
phi = zeros(1, xy_num);
da = 2*pi/xy_num;
dphi = deg2rad(30);
for i = 1 : xy_num
    xy(1, i) = (cylerder_radius + sensor_range) * cos((i-1)*da + 5*pi/4) + cylinder_center(1);
    xy(2, i) = (cylerder_radius + sensor_range) * sin((i-1)*da + 5*pi/4) + cylinder_center(2);
    phi(1, i) = -pi + da*(i-1) + 5*pi/4;
end
h_step = 4;
h_num = 24 / h_step;
lattice_viewpoints = [];
for i = 1 : h_num
    lattice_viewpoints = [lattice_viewpoints; ...
                          xy', h_step*i*ones(xy_num,1), phi'];
%     lattice_viewpoints = [lattice_viewpoints; ...
%                           xy', h_step*i*ones(xy_num,1), phi'-dphi; ...
%                           xy', h_step*i*ones(xy_num,1), phi'; ...
%                           xy', h_step*i*ones(xy_num,1), phi'+dphi;];
end
num_lattice_viewpoints = size(lattice_viewpoints, 1);

%% Visualization
% surface mesh
fig_main = figure;
hold on; grid on;
axis([-12 12 -12 12 0 25]);
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
ax_main = fig_main.CurrentAxes;
% trimesh(TR, 'FaceColor', [0.8,0.8,0.8], 'FaceAlpha', 1.0, ...
%     'EdgeColor', 'k', 'EdgeAlpha', 0.2, ...
%     'LineWidth', 1.0, 'LineStyle', '-');
ax_main.Visible = 'off';
trimesh(TR, 'FaceColor', 'w', 'FaceAlpha', 1.0, ...
    'EdgeColor', 'c', 'EdgeAlpha', 0.8, ...
    'LineWidth', 0.5, 'LineStyle', '-');
daspect([1 1 1]);
view(3);

% lattice viewpoints
for i = 1 : num_lattice_viewpoints
%     pause;
    % pos
    cam_pos = lattice_viewpoints(i, 1:3);
    plot3(ax_main, cam_pos(1), cam_pos(2), cam_pos(3), ...
        'Color', 'k', 'Marker', 'o', ...
        'MarkerSize', 4, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    % cam direction
    cam_yaw = lattice_viewpoints(i, 4);
    u = 2*cos(cam_yaw);
    v = 2*sin(cam_yaw);
    w = 0;
    quiver3(ax_main, cam_pos(1), cam_pos(2), cam_pos(3), u, v, w, ...
        'Color', 'b', 'LineWidth', 1.0, 'MaxHeadSize', 0.8);
    % cam fov
%     if i > 16 && i <= 24
%         plot_camera_fov(ax_main, cam_pos', 0, sensor_parameters.cam_pitch, cam_yaw, ...
%             sensor_parameters.fov_x, sensor_parameters.fov_y, ...
%             sensor_parameters.fov_range_max, 'r');
%     end
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

save([root_folder, '/surface_resources/',model_name,'/model/', ...
    model_name, '_lattice_viewpoints.mat'], 'lattice_viewpoints', 'lattice_los_neighbors');
