% an example to show the simulated temperature field
clear all
clear 
clc 

%% temperature data
filename = 'u_cylinder_shell-Thermal 1-Results-Thermal1-1.csv';
data_table = readtable(filename);
data_array = table2array(data_table);
num_data = size(data_array, 1);
% temprature data, [n x 4]
% original data
temperature_array = data_array(:, 2:5);     % temp, x, y, z

%% mesh data
data_mesh = load('ucylinder_mesh.mat');
TR = data_mesh.TR;
dim_x_env = [-8 26];
dim_y_env = [-8 16];
dim_z_env = [2 28];

%% data processing
obj_center = [4; 4; 0];
temperature_array(:, 2:4) = temperature_array(:, 2:4) + obj_center';
x_interval = [min(temperature_array(:,2)), max(temperature_array(:,2))];
y_interval = [min(temperature_array(:,3)), max(temperature_array(:,3))];
z_interval = [min(temperature_array(:,4)), max(temperature_array(:,4))];
t_interval = [min(temperature_array(:,1)), max(temperature_array(:,1))];
num_faces = size(TR.ConnectivityList, 1);
F_normal = faceNormal(TR);
F_center = incenter(TR);
% get temperature of each face
F_value = zeros(num_faces, 1);
for i = 1 : num_faces
    pos_val = F_center(i, :);
    % find the cloest from raw data
    [pos_closest, idx_closest] = find_closest_point(pos_val, temperature_array(:, 2:4));
    F_value(i) = temperature_array(idx_closest, 1);
end
% scale F_values to be between 0 and 1
min_value = min(F_value);
max_value = max(F_value);
F_value = (F_value - min_value) / (max_value - min_value);

save('ucylinder_temperature_field.mat', 'F_value');

%% visulization
% orginal temp field
figure;
grid on;
hold on;
axis([dim_x_env, dim_y_env, 0, dim_z_env(2)]);
view(3);
daspect([1 1 1])
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
scatter3(temperature_array(:, 2), temperature_array(:, 3), temperature_array(:, 4), ...
    128, temperature_array(:, 1), 'filled');
colormap jet
colorbar;
% mesh temp field
figure;
grid on;
hold on;
axis([dim_x_env, dim_y_env, 0, dim_z_env(2)]);
view(3);
daspect([1 1 1])
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
    TR.Points(:,3), F_value, 'EdgeAlpha', 0);
colormap jet
colorbar;
