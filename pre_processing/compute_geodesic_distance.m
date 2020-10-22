% compute geodesic distance between triangles of the surface
close all
clear all
clear 
clc 

root_folder = pwd;

%% load file
model_name = 'cylinder';            % cylinder, boeing747, u_cylinder
data_mesh = load([model_name, '_mesh.mat']);  
TR = data_mesh.TR;


%% initialize computation
global geodesic_library;                
geodesic_library = 'geodesic_debug';                %"release" is faster and "debug" does additional checks
vertices = TR.Points;
faces = TR.ConnectivityList;
num_faces = size(TR.ConnectivityList, 1);
mesh = geodesic_new_mesh(vertices,faces);           %initilize new mesh
algorithm = geodesic_new_algorithm(mesh, 'exact'); 	%initialize new geodesic algorithm


%% computation for each loop
geo_dis_mtx = zeros(num_faces, num_faces);
for i = 1 : 1
    for j = i+1 : num_faces
        vertex_i = faces(i, 1);
        vertex_j = faces(j, 1);         % both choose the first vertex of the face
        source_points = {geodesic_create_surface_point('vertex',vertex_i,vertices(vertex_i,:))};
        geodesic_propagate(algorithm, source_points);
        destination = geodesic_create_surface_point('vertex',vertex_j,vertices(vertex_j,:));
        path = geodesic_trace_back(algorithm, destination);	
        [x,y,z] = extract_coordinates_from_path(path);
        path_length = sum(sqrt(diff(x).^2 + diff(y).^2 + diff(z).^2));	% length of the path
        geo_dis_mtx(i, j) = path_length;
        geo_dis_mtx(j, i) = path_length;
    end
end
save([root_folder, '/surface_resources/cylinder/model/', ...
    model_name, '_geo_distance.mat'], 'geo_dis_mtx');

