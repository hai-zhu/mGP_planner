% an example to show lattice viewpoints samples
close all
clear all
clear 
clc 

root_folder = pwd;

%% Environment
model_name = 'boeing747';
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
dim_x_env = map_parameters.dim_x_env;
dim_y_env = map_parameters.dim_y_env;
dim_z_env = map_parameters.dim_z_env;


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


%% lattice viewpoints
% main body
y_center_body = 0;
x_body = 0 : 4 : 72;
yz_body = [-6 0; -6 3; -6 6; ...
           -2 6; ...
           2 6; ...
           6 0; 6 3; 6 6];
% lattice_body = zeros(length(x_body)*length(yz_body), 4);
lattice_body = [];
for i = 1 : length(x_body)
    for j = 1 : length(yz_body)
        xyz_temp = [x_body(i), yz_body(j,:)];
        yaw_temp = atan2(y_center_body-yz_body(j,1), 0);
        if ~isequal(xyz_temp, [24, -6, 0]) && ...
           ~isequal(xyz_temp, [30, -6, 0]) && ...
           ~isequal(xyz_temp, [36, -6, 0]) && ...
           ~isequal(xyz_temp, [24, 6, 0]) && ...
           ~isequal(xyz_temp, [30, 6, 0]) && ...
           ~isequal(xyz_temp, [36, 6, 0])
                lattice_body = [lattice_body; xyz_temp, yaw_temp];
        end
%         lattice_body(length(yz_body)*(i-1) + j, 1:4) = ...
%             [xyz_temp, yaw_temp];
    end
end
% wing
lattice_wing_left = [24     -10      2      0; ...
                     28     -16      2      0; ...
                     32     -22      2      0; ...
                     38     -28      2      0; ...
                     46     -34     2      0; ...
                     44     -10     2      -pi; ...
                     46     -16     2      -pi; ...
                     50     -22     2      -pi; ...
                     52     -28     2      -pi; ...
                     52     -34      2      -pi];
lattice_wing_right =[24     10     2      0; ...
                     28     16      2      0; ...
                     32     22      2      0; ...
                     38     28      2      0; ...
                     46     34      2      0; ...
                     44     10      2      -pi; ...
                     46     16      2      -pi; ...
                     50     22      2      -pi; ...
                     52     28      2      -pi; ...
                     52     34      2      -pi];
% in total
lattice_viewpoints = [lattice_body; lattice_wing_left; lattice_wing_right];
num_lattice_viewpoints = size(lattice_viewpoints, 1);


%% Lattice viewpoints visualization
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
    if mod(i, 3) == 0
        plot_camera_fov(ax_main, cam_pos', 0, sensor_parameters.cam_pitch, cam_yaw, ...
            sensor_parameters.fov_x, sensor_parameters.fov_y, ...
            sensor_parameters.fov_range_max, 'r');
    end
end


%% Find LoS neighbors of each lattic
lattice_los_neighbors = cell(num_lattice_viewpoints, 1);
dis_max = 12;
for i = 1 : num_lattice_viewpoints
    lattice_los_neighbors{i} = i;
    lattice_i = lattice_viewpoints(i, :)';
    for j = 1 : num_lattice_viewpoints
        if j == i
            continue;
        else
            lattice_j = lattice_viewpoints(j, :)';
            % i and j dis
            dis_ij = norm(lattice_i(1:3) - lattice_j(1:3));
            % test of i and j are in los
            ij_in_los = if_in_los(lattice_i(1:3), lattice_j(1:3), map_parameters);
            if (ij_in_los && dis_ij <= dis_max)
                lattice_los_neighbors{i} = [lattice_los_neighbors{i}; j];
            end
        end
    end
end

save([root_folder, '/surface_resources/',model_name,'/model/', ...
    model_name, '_lattice_viewpoints.mat'], 'lattice_viewpoints', 'lattice_los_neighbors');
