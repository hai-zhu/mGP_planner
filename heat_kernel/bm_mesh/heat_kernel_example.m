% a heat kernel approximation example
clear all 
close all
clear 
clc 


%% Load mesh file
model_name = 'cylinder';       % cylinder, boeing747, ucylinder
data_mesh = load([model_name, '_mesh.mat']);
model.TR = data_mesh.TR;
TR = data_mesh.TR;
figure;
hold on;
trimesh(TR, 'FaceColor', [0.8,0.8,0.8], 'FaceAlpha', 1.0, 'EdgeColor', 'k', 'EdgeAlpha', 0.2, ...
    'LineWidth', 1.0, 'LineStyle', '-');
daspect([1 1 1]);
view(3);


%% Mesh pre-processing
mesh = mesh_preporcessing(TR);


%% Choose starting point
s0_faceId = 340;
% plot3(mesh.F_center(1, s0_faceId), mesh.F_center(2, s0_faceId), ...
%     mesh.F_center(3, s0_faceId), 'or')


%% Monte Carlo sampling
dt = 1;
speed = 0.25;
T = 100;
N = 100000;
path_all = zeros(3, ceil(T/dt)+1, N);          % record paths of all samples
faceID_path_all = zeros(1, ceil(T/dt)+1, N);
% initialize particles
particle.local_r = [1/3; 1/3];                      % 2x1
particle.meshFaceIdx = s0_faceId;
particle.r = mesh.coord_l2g(particle.meshFaceIdx).Jacobian*particle.local_r + ...
    mesh.coord_l2g(particle.meshFaceIdx).base;      % 3x1
plot3(particle.r(1),particle.r(2),particle.r(3),'or');
particle.vel = zeros(3, 1);
particle_all = repmat(particle, [N, 1]);
particle_end_all = particle_all;
% sampling
tic;
parfor i = 1 : N
    [particle_i, path_i, faceID_path_i] = particle_move_multiple_steps(particle_all(i), mesh, dt, speed, T);
    particle_end_all(i) = particle_i;
    path_all(:, :, i) = path_i;
    faceID_path_all(:, :, i) = faceID_path_i;
end
toc;
TF = T;
posF_all = reshape(path_all(:, TF, :), [3, N]);
plot3(posF_all(1, :), posF_all(2, :), posF_all(3, :), '*b');


%% Construct heat kernel with respect to s0
heat_kernel_s0 = zeros(mesh.numF, T);
for t = 1 : T
    faceId_t_all = reshape(faceID_path_all(:, t, :), [1, N]);   % 1xN
    for i = 1 : mesh.numF
        % by accumulating those pos_t in the i face
        heat_kernel_s0(i, t) = (1/mesh.F_area(1,i)) * length(find(faceId_t_all == i))/N ;
    end
end



