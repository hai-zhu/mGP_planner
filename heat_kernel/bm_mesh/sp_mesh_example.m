% an example of simulating a single particle on a mesh surface
clear all
close all
clear 
clc 


%% Load mesh file
% read file
% sphere_center, testbox_center, cylinder_center, planenew_simplification
% hoa_hakanaia, plane_simple_1, simple_cylinder_solid
% [TR, fileformat, attributes, solidID] = ...
%     stlread('simple_cylinder_solid.stl'); 
model_name = 'cylinder';       % cylinder, boeing747
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


%% Simulating a particle
% parameter settings
T = 100;
dt = 1;
speed = 0.2;
time_elapsed = 0;
% particle initial state
particle.local_r = [0.3; 0.3];                      % 2x1
particle.meshFaceIdx = 350;
particle.r = mesh.coord_l2g(particle.meshFaceIdx).Jacobian*particle.local_r + ...
    mesh.coord_l2g(particle.meshFaceIdx).base;      % 3x1
plot3(particle.r(1),particle.r(2),particle.r(3),'or');
particle.vel = zeros(3, 1);
% simulatio multiple steps
tic;
[particle, path, faceID_path] = particle_move_multiple_steps(particle, mesh, dt, speed, T);
toc;
plot3(particle.r(1),particle.r(2),particle.r(3),'db');
plot3(path(1, :), path(2, :), path(3, :), '-b');
% plot3(mesh.F_center(1, faceID_path'), mesh.F_center(2, faceID_path'), ...
%     mesh.F_center(3, faceID_path'), 'oc');



