function [sensor_parameters, map_parameters, planning_parameters, ...
    optimization_parameters, matlab_parameters] = ...
        load_parameteres(num_faces, F_center, F_normal, F_points)

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
    map_parameters.dim_x_env = [-8, 20];
    map_parameters.dim_y_env = [-8, 20];
    map_parameters.dim_z_env = [2, 30];
    map_parameters.num_faces = num_faces;
    map_parameters.F_center = F_center;
    map_parameters.F_normal = F_normal;
    map_parameters.F_points = F_points;
    map_parameters.sigma_f = 1.3;
    map_parameters.l = 0.3;
    
    %% trajectory planning parameters
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
    optimization_parameters.cov_x = 5;
    optimization_parameters.cov_y = 5;
    optimization_parameters.cov_z = 5;
    
    %% matlab parameters
    matlab_parameters.visualize_map = 1;
    matlab_parameters.visualize_path = 1;
    matlab_parameters.visualize_cam = 0;

end