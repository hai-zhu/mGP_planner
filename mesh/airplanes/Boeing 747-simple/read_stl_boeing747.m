close all
clear all
clear 
clc

%% Example: Create triangulation from STL file
% read file
[TR_solid, fileformat, attributes, solidID] = ...
    stlread('Boeing 747-simple.stl'); 
% triangulation properties
num_faces = size(TR_solid.ConnectivityList, 1);
num_vertices = size(TR_solid.Points, 1);

%% Visualization
% mesh
figure;
hold on;
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
daspect([1 1 1]);
view(3);
trimesh(TR_solid);

%% Transformation and scaling
T_trans = TR_solid.ConnectivityList;
P_trans = TR_solid.Points;
P_trans(:, 3) = 0.1526*2 - TR_solid.Points(:, 3) + 0.2;
P_trans = P_trans * 70.66/0.885;
TR = triangulation(T_trans, P_trans);
figure;
hold on;
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
daspect([1 1 1]);
view(3);
trimesh(TR);

