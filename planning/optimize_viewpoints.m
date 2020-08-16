function obj = optimize_viewpoints(waypoints, starting_point, faces_map, ...
     map_parameters, sensor_parameters, planning_parameters)
% Fitness function for optimizing all points on a horizon for an informative 
% objective

waypoints = reshape(waypoints, 4, [])';
waypoints = [starting_point; waypoints];

obj = compute_objective_inspect(waypoints, faces_map, map_parameters,...
    sensor_parameters, planning_parameters);

end