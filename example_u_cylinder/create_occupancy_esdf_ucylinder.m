% close all 
clear all
clear 

% map environments
model_name = 'ucylinder';
data_mesh = load([model_name, '_mesh.mat']);  
TR = data_mesh.TR;

FV.faces = TR.ConnectivityList;
FV.vertices = TR.Points;
resolution = 0.5;
dim_x_env = [-8 26];
dim_y_env = [-8 16];
dim_z_env = [2 28];
[occupancy, esdf] = mesh_to_occupancy_esdf(FV, dim_x_env, dim_y_env, dim_z_env, ...
    resolution);

% visualization for test
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


save([model_name, '_map_occupancy.mat'], 'occupancy');
save([model_name, '_map_esdf.mat'], 'esdf');
