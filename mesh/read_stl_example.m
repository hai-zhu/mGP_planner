close all
clear all
clear 
clc

%% Example: Create triangulation from STL file
% read file
% sphere_center, testbox_center, cylinder_center, planenew_simplification
% hoa_hakanaia, plane_simple_1, simple_cylinder_solid
[TR, fileformat, attributes, solidID] = ...
    stlread('simple_cylinder_solid.stl'); 
% triangulation properties
num_faces = size(TR.ConnectivityList, 1);
num_vertices = size(TR.Points, 1);
F_normal = faceNormal(TR);
F_center = incenter(TR);

%% Visualization
% mesh
fig_mesh = figure;
hold on;
ax_mesh = fig_mesh.CurrentAxes;
daspect(ax_mesh, [1 1 1]);
view(ax_mesh, 3);
h_mesh = trimesh(TR);
h_mesh.FaceColor = 'w';
h_mesh.FaceAlpha = 0;
h_mesh.EdgeColor = 'c';
h_mesh.LineWidth = 0.5;
h_mesh.LineStyle = '-';

% patch each face and view the normal
for iF = 1 : num_faces
%     pause(0.05);
%     pause;
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
          'FaceColor', 'w', ... % rand*ones(1,3)
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


%% TR with higher resolution by subdivision
% fMinResolution_1 = 1;
% [mfRefinedMesh, mnTriangulation] = ...
%    LoopSubdivisionLimited(TR.Points, TR.ConnectivityList, fMinResolution_1);
% TR_1 = triangulation(mnTriangulation, mfRefinedMesh);
% num_faces_1 = size(TR_1.ConnectivityList, 1);
% num_vertices_1 = size(TR_1.Points, 1);
% F_normal_1 = faceNormal(TR_1);
% F_center_1 = incenter(TR_1);
% % figure;
% % trisurf(TR_1);
% % Visualization
% % mesh
% fig_mesh_1 = figure;
% hold on;
% ax_mesh_1 = fig_mesh_1.CurrentAxes;
% daspect(ax_mesh_1, [1 1 1]);
% view(ax_mesh_1, 3);
% h_mesh_1 = trimesh(TR_1);
% h_mesh_1.FaceColor = 'w';
% h_mesh_1.FaceAlpha = 0;
% h_mesh_1.EdgeColor = 'c';
% h_mesh_1.LineWidth = 0.5;
% h_mesh_1.LineStyle = '-';
% 
% % patch each face and view the normal
% for iF = 1 : num_faces_1
% %     pause(0.05);
% %     pause;
%     % face triangle points
%     F_points_idx_iF = TR_1.ConnectivityList(iF, :);
%     F_points_iF = [ TR_1.Points(F_points_idx_iF(1), :); ...
%                     TR_1.Points(F_points_idx_iF(2), :); ...
%                     TR_1.Points(F_points_idx_iF(3), :)];
%     F_center_iF = F_center_1(iF, :);
%     F_normal_iF = F_normal_1(iF, :);
%     % patch the face
%     patch(ax_mesh_1, 'XData', F_points_iF(:, 1), ...
%           'YData', F_points_iF(:, 2), ...
%           'ZData', F_points_iF(:, 3), ...
%           'FaceColor', rand*ones(1,3), ...
%           'FaceAlpha', 1.0, ...
%           'EdgeColor', 'k');
%     % plot face center
% %     plot3(ax_mesh_1, F_center_iF(1), F_center_iF(2), ...
% %         F_center_iF(3), '.r');
%     % plot the normal
% %     quiver3(ax_mesh_1, F_center_iF(:,1), F_center_iF(:,2), F_center_iF(:,3), ...
% %         F_normal_iF(:,1), F_normal_iF(:,2), F_normal_iF(:,3), ...
% %         0.5, 'color', 'r');
% end
