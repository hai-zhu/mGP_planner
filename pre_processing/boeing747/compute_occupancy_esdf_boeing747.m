% compute occupancy map and esdf based on the mesh file
% clear all
% clear 
% clc 

root_folder = pwd;

%% compute map
model_name = 'boeing747';
switch model_name
    case 'boeing747'
        dim_x_env = [-8 80];
        dim_y_env = [-40 40];
        dim_z_env = [-4 16];
    otherwise
        error('Model cannot be found!');
end
data_mesh = load([model_name, '_mesh.mat']);  
TR = data_mesh.TR;
FV.faces = TR.ConnectivityList;
FV.vertices = TR.Points;
resolution = 0.5;
% [occupancy, esdf] = mesh_to_occupancy_esdf(FV, dim_x_env, dim_y_env, dim_z_env, ...
%     resolution);

% dim_x = diff(dim_x_env)/resolution;
% dim_y = diff(dim_y_env)/resolution;
% dim_z = diff(dim_z_env)/resolution;
% parfor i = 1 : dim_x
%     x = dim_x_env(1) + (i-0.5)*resolution;
%     for j = 1 : dim_y
%         y = dim_y_env(1) + (j-0.5)*resolution;
%         for k = 1 : dim_z
%             z = dim_z_env(1) + (k-0.5)*resolution;
%             if (x <= 37 && y >= 21) || ...
%                     (x >= 55 && y >= 4) || ...
%                     (x <= 60 && z >= 4) || ...
%                     (x >= 72)
%                 occupancy(i,j,k) = false;
%                 esdf(i,j,k) = 4;
%             end
%             if (x > 60 && x < 70 && y > -12 && y < 12 && z >= 1 && z <= 3)
%                 occupancy(i,j,k) = true;
%                 esdf(i,j,k) = -4;
%             end
%         end
%     end
% end

% save([root_folder, '/surface_resources/',model_name,'/model/', ...
%     model_name, '_map_occupancy.mat'], 'occupancy');
% save([root_folder, '/surface_resources/',model_name,'/model/', ...
%     model_name, '_map_esdf.mat'], 'esdf');

%% visualization for test
% mesh
fig_mesh = figure;
hold on;
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
axis([dim_x_env, dim_y_env, dim_z_env]);
ax_mesh = fig_mesh.CurrentAxes;
trimesh(TR, 'FaceColor', [0.8,0.8,0.8], 'FaceAlpha', 1.0, ...
    'EdgeColor', 'k', 'EdgeAlpha', 0.2, ...
    'LineWidth', 1.0, 'LineStyle', '-');
daspect([1 1 1]);
view(3);
% test esdf
fig_esdf = figure;
hold on;
grid on;
axis([dim_x_env, dim_y_env, dim_z_env]);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
ax_main = fig_esdf.CurrentAxes;
daspect(ax_main, [1 1 1]);
view(ax_main, 3);
dim_env_lower = [dim_x_env(1); dim_y_env(1); dim_z_env(1)];
for x_i = dim_x_env(1) : 2*resolution : dim_x_env(2)-0.1
    for y_j = dim_y_env(1) : 2*resolution : dim_y_env(2)-0.1
        for z_k = dim_z_env(1) : 2*resolution : dim_z_env(2)-0.1
            pos_val = [x_i, y_j, z_k];
            idx = floor((resolution+pos_val'-dim_env_lower)/resolution);
            dis = esdf(idx(1),idx(2),idx(3));
            if dis < 0
%                 pause;
%                 scatter3(x_i, y_j, z_k);
                plot3(x_i, y_j, z_k, 'o');
            end
        end
    end
end
