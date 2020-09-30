% an example to show the simulated temperature field

%% temperature data
filename = 'simple_cylinder_excluded_thermal-Thermal 1-Results-Thermal1-2.csv';
data_table = readtable(filename);
data_array = table2array(data_table);
num_data = size(data_array, 1);
% temprature data, [n x 4]
% original data
temperature_array = data_array(:, 2:5);     % temp, x, y, z
temperature_array(:, 2:4) = temperature_array(:, 2:4)/100;   % convert to m

%% mesh data
data_mesh = load('simple_cylinder_solid.mat');
TR = data_mesh.TR;
[map_parameters, sensor_parameters, planning_parameters, optimization_parameters, ...
    matlab_parameters] = load_parameteres(TR);
dim_x_env = map_parameters.dim_x_env;
dim_y_env = map_parameters.dim_y_env;
dim_z_env = map_parameters.dim_z_env;

%% data processing
% coordinate translation
obj_center = map_parameters.center_pos;
obj_center(3) = 0;
temperature_array(:, 2:4) = temperature_array(:, 2:4) + obj_center';
x_interval = [min(temperature_array(:,2)), max(temperature_array(:,2))];
y_interval = [min(temperature_array(:,3)), max(temperature_array(:,3))];
z_interval = [min(temperature_array(:,4)), max(temperature_array(:,4))];
t_interval = [min(temperature_array(:,1)), max(temperature_array(:,1))];
% get temperature of each face
F_value = zeros(map_parameters.num_faces, 1);
for i = 1 : map_parameters.num_faces
    pos_val = map_parameters.F_center(i, :);
    % find the cloest from raw data
    [pos_closest, idx_closest] = find_closest_point(pos_val, temperature_array(:, 2:4));
    F_value(i) = temperature_array(idx_closest, 1);
end
% scale F_values to be between 0 and 1
min_value = min(F_value);
max_value = max(F_value);
F_value = (F_value - min_value) / (max_value - min_value);


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

