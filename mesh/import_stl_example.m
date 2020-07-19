clear all
clear 
clc

%% import an STL file and plot the geometry, strange errors!
% sphere
model_sphere = createpde;
importGeometry(model_sphere, 'sphere_center.stl');
pdegplot(model_sphere, 'FaceLabels', 'on')
% cylinder
model_cylinder = createpde;
importGeometry(model_cylinder, 'cylinder_center.stl');
pdegplot(model_cylinder, 'FaceLabels', 'on')
% box
% model_box = createpde;
% importGeometry(model_box, 'testbox_center.stl');
% pdegplot(model_box, 'FaceLabels', 'on')
% air plane
% model_airplane = createpde;
% importGeometry(model_airplane, 'planenew_simplification.stl');
% pdegplot(model_airplane, 'FaceLabels', 'on')

