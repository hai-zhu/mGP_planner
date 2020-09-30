close all
clear all
clear 
clc

%% Create triangulation from STL file
[TR, fileformat, attributes, solidID] = ...
    stlread('u_cylinder_solid.stl'); 
% triangulation properties
num_faces = size(TR.ConnectivityList, 1);
num_vertices = size(TR.Points, 1);
F_normal = faceNormal(TR);
F_center = incenter(TR);

%% Visualization
% mesh
fig_mesh = figure;
hold on;
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
ax_mesh = fig_mesh.CurrentAxes;
daspect([1 1 1]);
view(3);
trimesh(TR, 'FaceColor', [0.8,0.8,0.8], 'FaceAlpha', 1.0, 'EdgeColor', 'k', 'EdgeAlpha', 0.2, ...
    'LineWidth', 1.0, 'LineStyle', '-');

patch each face and view the normal
for iF = 1 : num_faces
%     pause(0.05);
%     pause;
%     disp(['Face ', num2str(iF)]);
    % face triangle points
    F_points_idx_iF = TR.ConnectivityList(iF, :);
    F_points_iF = [ TR.Points(F_points_idx_iF(1), :); ...
                    TR.Points(F_points_idx_iF(2), :); ...
                    TR.Points(F_points_idx_iF(3), :)];
    F_center_iF = F_center(iF, :);
    F_normal_iF = F_normal(iF, :);
    % patch the face
    patch(ax_mesh, 'XData', F_points_iF(:, 1), ...
          'YData', F_points_iF(:, 2), ...
          'ZData', F_points_iF(:, 3), ...
          'FaceColor', rand(1,3), ...
          'FaceAlpha', 1.0, ...
          'EdgeColor', 'c');
    % plot face center
%     plot3(ax_mesh, F_center_iF(1), F_center_iF(2), ...
%         F_center_iF(3), '.r');
    % plot the normal
%     quiver3(ax_mesh, F_center_iF(:,1), F_center_iF(:,2), F_center_iF(:,3), ...
%         F_normal_iF(:,1), F_normal_iF(:,2), F_normal_iF(:,3), ...
%         0.5, 'color', 'r');
end

save('ucylinder_mesh.mat', 'TR');
