% an example of simulating a single particle on a mesh surface
clear all
close all
clear 
clc 


%% Load mesh file
% read file
% sphere_center, testbox_center, cylinder_center, planenew_simplification
% hoa_hakanaia, plane_simple_1, simple_cylinder_solid
[TR, fileformat, attributes, solidID] = ...
    stlread('sphere_center.stl'); 
figure;
hold on;
trimesh(TR, 'FaceColor', 'w', 'FaceAlpha', 1.0, 'EdgeColor', 'c', 'EdgeAlpha', 0.8, ...
    'LineWidth', 1.0, 'LineStyle', '-');
daspect([1 1 1]);
view(3);


%% Mesh pre-processing
mesh = mesh_preporcessing(TR);


%% An example for validation
% parameter settings
dt = 2*pi*1.181;
% create initial state 
particle.local_r = [0.3; 0.3];                      % 2x1
particle.meshFaceIdx = 300;
particle.r = mesh.coord_l2g(particle.meshFaceIdx).Jacobian*particle.local_r + ...
    mesh.coord_l2g(particle.meshFaceIdx).base;      % 3x1
plot3(particle.r(1),particle.r(2),particle.r(3),'or');
normal1 = mesh.F_normals(:, particle.meshFaceIdx);  % 3x1
director = cross(normal1, [0, 0, 1]);
director = director / norm(director);
particle.vel = director';                           % 3x1
% one-step movement
tic
particle = particle_move_one_step(particle, mesh, dt);
toc
plot3(particle.r(1),particle.r(2),particle.r(3),'db');



