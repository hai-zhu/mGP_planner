close all
clear all
clear 
clc

global geodesic_library;                
geodesic_library = 'geodesic_debug';                %"release" is faster and "debug" does additional checks

%% Load a mesh
data = load('simple_cylinder_solid.mat');
TR = data.TR;

%% Compute the shortest path
vertices = TR.Points;
faces = TR.ConnectivityList;
mesh = geodesic_new_mesh(vertices,faces);           %initilize new mesh
algorithm = geodesic_new_algorithm(mesh, 'exact'); 	%initialize new geodesic algorithm
vertex_id = 1;                                      %create a single source at vertex #1
source_points = {geodesic_create_surface_point('vertex',vertex_id,vertices(vertex_id,:))};
geodesic_propagate(algorithm, source_points);       %propagation stage of the algorithm (the most time-consuming)
vertex_id = 800;                                    %create a single destination at vertex #N
destination = geodesic_create_surface_point('vertex',vertex_id,vertices(vertex_id,:));
path = geodesic_trace_back(algorithm, destination);	%find a shortest path from source to destination
[x,y,z] = extract_coordinates_from_path(path);
path_length = sum(sqrt(diff(x).^2 + diff(y).^2 + diff(z).^2));            %length of the path

%% Visualization
hold off;
colormap('default');
trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3), 'FaceColor', 'interp', 'EdgeColor', 'k');       %plot the mesh
daspect([1 1 1]);

hold on;
plot3(source_points{1}.x, source_points{1}.y, source_points{1}.z, 'or', 'MarkerSize',3);    %plot sources

plot3(destination.x, destination.y, destination.z, 'ok', 'MarkerSize',3);       %plot destination 
h = plot3(x*1.001,y*1.001,z*1.001,'k-','LineWidth',2);    %plot path
legend(h,'geodesic curve');

geodesic_delete;

