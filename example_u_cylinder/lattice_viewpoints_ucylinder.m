% an example to show lattice viewpoints samples
close all
clear all
clear 
clc 

%% Environment
model_name = 'ucylinder';
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
dim_x_env = map_parameters.dim_x_env;
dim_y_env = map_parameters.dim_y_env;
dim_z_env = map_parameters.dim_z_env;


%% Visualization
% surface mesh
fig_main = figure;
hold on;
grid on;
axis([dim_x_env, dim_y_env, 0, dim_z_env(2)]);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
ax_main = fig_main.CurrentAxes;
daspect(ax_main, [1 1 1]);
view(ax_main, 3);
trimesh(TR, 'FaceColor', [0.8,0.8,0.8], 'FaceAlpha', 1.0, 'EdgeColor', 'k', 'EdgeAlpha', 0.2, ...
    'LineWidth', 1.0, 'LineStyle', '-');


%% lattice viewpoints
% first
cylinder_center_1 = [4; 4; 11];
cylerder_radius = 4;
cylerder_height = 21;
sensor_range = 4;
xy_num= 12;
h_step = 4;
h_num = 24 / h_step;
xy = [];
phi = [];
da = 2*pi/xy_num;
for i = 2 : xy_num
    xy = [xy; ...
         (cylerder_radius + sensor_range) * cos((i-1)*da) + cylinder_center_1(1), ...
         (cylerder_radius + sensor_range) * sin((i-1)*da) + cylinder_center_1(2)];
    phi = [phi; -pi + da*(i-1)];
end
lattice_viewpoints_1 = [];
for i = 1 : h_num
    lattice_viewpoints_1 = [lattice_viewpoints_1; ...
                            xy, h_step*i*ones(xy_num-1,1), phi];
end
% second
cylinder_center_2 = [14; 4; 11];
xy = [];
phi = [];
for i = 1 : xy_num
    if i == floor(xy_num/2+1)
        continue;
    end
    xy = [xy; ...
         (cylerder_radius + sensor_range) * cos((i-1)*da) + cylinder_center_2(1), ...
         (cylerder_radius + sensor_range) * sin((i-1)*da) + cylinder_center_2(2)];
    phi = [phi; -pi + da*(i-1)];
end
lattice_viewpoints_2 = [];
for i = 1 : h_num
    lattice_viewpoints_2 = [lattice_viewpoints_2; ...
                            xy, h_step*i*ones(xy_num-1,1), phi];
end
% combine
lattice_viewpoints = [lattice_viewpoints_1; lattice_viewpoints_2];
num_lattice_viewpoints = size(lattice_viewpoints, 1);

%% Visualization
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
    if i == 50
        plot_camera_fov(ax_main, cam_pos', 0, sensor_parameters.cam_pitch, cam_yaw, ...
            sensor_parameters.fov_x, sensor_parameters.fov_y, ...
            sensor_parameters.fov_range_max, 'r');
    end
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

% save('ucylinder_lattice_viewpoints.mat', 'lattice_viewpoints', 'lattice_los_neighbors'); 
