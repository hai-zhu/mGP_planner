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
dim_x_env = map_parameters.dim_x_env;
dim_y_env = map_parameters.dim_y_env;
dim_z_env = map_parameters.dim_z_env;

%% Mesh
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
% patch each face and view the normal
for iF = 1 : num_faces
    if mod(iF, 10) == 0 
    %     pause(0.05);
%         pause;
%         disp(['Face ', num2str(iF)]);
        % face triangle points
        F_points_idx_iF = TR.ConnectivityList(iF, :);
        F_points_iF = [ TR.Points(F_points_idx_iF(1), :); ...
                        TR.Points(F_points_idx_iF(2), :); ...
                        TR.Points(F_points_idx_iF(3), :)];
        F_center_iF = F_center(iF, :);
        F_normal_iF = 3*F_normal(iF, :);
        % patch the face
        patch(ax_main, 'XData', F_points_iF(:, 1), ...
              'YData', F_points_iF(:, 2), ...
              'ZData', F_points_iF(:, 3), ...
              'FaceColor', rand*ones(1,3), ...
              'FaceAlpha', 1.0, ...
              'EdgeColor', 'c');
        % plot face center
    %     plot3(ax_main, F_center_iF(1), F_center_iF(2), ...
    %         F_center_iF(3), '.r');
        % plot the normal
        quiver3(ax_main, F_center_iF(:,1), F_center_iF(:,2), F_center_iF(:,3), ...
            F_normal_iF(:,1), F_normal_iF(:,2), F_normal_iF(:,3), ...
            0.5, 'color', 'r');
    end
end

%% Map
ground_truth_faces_map = create_ground_truth_map(map_parameters);
fig_map = figure;
hold on;
axis([dim_x_env, dim_y_env, dim_z_env]);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
ax_map = fig_map.CurrentAxes;
daspect(ax_map, [1 1 1]);
view(ax_map, 3);
trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
    TR.Points(:,3), ground_truth_faces_map, 'EdgeAlpha', 0);
colormap jet

