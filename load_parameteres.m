function [map_parameters, sensor_parameters, planning_parameters, ...
    optimization_parameters, matlab_parameters] = ...
        load_parameteres(TR)

    disp('Parameters loading...');
    
    %% sensor parameter, fixed
    sensor_parameters.cam_roll = 0;
    sensor_parameters.cam_pitch = deg2rad(15);
    sensor_parameters.cam_yaw = 0;
    sensor_parameters.fov_x = deg2rad(60);
    sensor_parameters.fov_y = deg2rad(60);
    sensor_parameters.fov_range_min = 2;
    sensor_parameters.fov_range_max = 8;
    sensor_parameters.incidence_range_min = cos(deg2rad(70));
    sensor_parameters.sensor_coeff_A = 0.05;
    sensor_parameters.sensor_coeff_B = 0.2;
    
    %% map parameters
    % dimension
    map_parameters.center_pos = [6; 6; 11];     % object center
    map_parameters.dim_x_env = [-8, 20];
    map_parameters.dim_y_env = [-8, 20];
    map_parameters.dim_z_env = [2, 30];
    % mesh triangulation
    map_parameters.TR = TR;
    map_parameters.num_faces = size(TR.ConnectivityList, 1);
    map_parameters.F_normal = faceNormal(TR);
    map_parameters.F_center = incenter(TR);
    map_parameters.F_points = zeros(map_parameters.num_faces, 3, 3);
    for iFace = 1 : map_parameters.num_faces
        map_parameters.F_points(iFace, :, 1) = TR.Points(TR.ConnectivityList(iFace, 1), :);    % 1x3
        map_parameters.F_points(iFace, :, 2) = TR.Points(TR.ConnectivityList(iFace, 2), :);
        map_parameters.F_points(iFace, :, 3) = TR.Points(TR.ConnectivityList(iFace, 3), :);
    end
    % transform mesh to voxel
    map_parameters.resolution = 0.5;
    data_occupancy = load('cylinder_map_occupancy');
    map_parameters.occupancy = data_occupancy.occupancy;    
    % compute the esdf
    data_esdf = load('cylinder_map_esdf');
    map_parameters.esdf = data_esdf.esdf; 
    % kenel function parameters
    map_parameters.sigma_f = 1.3;
    map_parameters.l = 0.3;
    
    %% trajectory planning parameters
    planning_parameters.safe_radius = 0.6;      % safe radius, [m]
    planning_parameters.max_vel = 4;            % [m/s]
    planning_parameters.max_acc = 3;            % [m/s^2]
    planning_parameters.max_yaw_rate = deg2rad(90); % [rad/s]
    planning_parameters.time_budget = 160;
    planning_parameters.lambda = 0.001;         % parameter to control 
                                                % exploration-exploitation 
                                                % trade-off in objective
    planning_parameters.measurement_frequency = 0.2;
    planning_parameters.use_threshold = 1;
    planning_parameters.lower_threshold = 0.4;
    planning_parameters.obj = 'rate';    % 'rate'/'exponential'
    planning_parameters.control_points = 4;
    
    %% global optimization paramters
    optimization_parameters.opt_method = 'cmaes'; % 'aco'
    optimization_parameters.max_iters = 30;
    optimization_parameters.opt_yaw = 0;
    optimization_parameters.cov_x = 5;
    optimization_parameters.cov_y = 5;
    optimization_parameters.cov_z = 5;
    optimization_parameters.cov_yaw = 3;
    
    %% matlab parameters
    matlab_parameters.visualize_map = 1;
    matlab_parameters.visualize_path = 1;
    matlab_parameters.visualize_cam = 1;

    disp('Parameters loaded!');
    
end