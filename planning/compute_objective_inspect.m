function obj = compute_objective_inspect(control_points, faces_map, map_parameters,...
    sensor_parameters, planning_parameters)
% Calculates the expected informative objective for a polynomial path.
% ---
% Inputs:
% control_points: list of waypoints defining the polynomial
% faces_map: current map
% ---
% Output:
% obj: informative objective value (to be minimized)
% ---
% H Zhu 2020
%

    dim_x_env = map_parameters.dim_x_env;
    dim_y_env = map_parameters.dim_y_env;
    dim_z_env = map_parameters.dim_z_env;
    dim_env_lower = [dim_x_env(1); dim_y_env(1); dim_z_env(1)];

    % Create polynomial path through the control points.
    trajectory = plan_path_waypoints(control_points(:,1:3), ...
        planning_parameters.max_vel, planning_parameters.max_acc);

    % Sample trajectory to find locations to take measurements at.
    [~, points_meas, ~, ~] = sample_trajectory(trajectory, ...
        1/planning_parameters.measurement_frequency);
    
    % Sample trajecoty to check collisions
%     coll_check_frequency = map_parameters.resolution / planning_parameters.max_vel;
    coll_check_frequency = 1.0;
    [~, points_coll_check, ~, ~] = sample_trajectory(trajectory, coll_check_frequency);
    obj_coll = 0;
    for i = 1 : size(points_coll_check, 1)
        pos_val = points_coll_check(i, 1:3)';
        idx = floor((map_parameters.resolution + pos_val - dim_env_lower) / ...
            map_parameters.resolution);
        % pos_val may be out of env, making idx invalid, but actually collision-free
        try 
            dis_val = map_parameters.esdf(idx(1),idx(2),idx(3));
        catch
            continue;
        end
        if dis_val <= planning_parameters.safe_radius   % in collision
            obj_coll = obj_coll + 10;
        end
    end
    
    % Find the corresponding yaw
    num_points_meas = size(points_meas,1);
    viewpoints_meas = zeros(num_points_meas, 4);
    center_pos = [6; 6; 11];
    for i = 1 : num_points_meas
        viewpoints_meas(i, 1:3) = points_meas(i, 1:3);
        dx = center_pos(1) - viewpoints_meas(i, 1);
        dy = center_pos(2) - viewpoints_meas(i, 2);
        viewpoints_meas(i, 4) = atan2(dy, dx);
    end
    
    if (planning_parameters.use_threshold)
        above_thres_ind = find(faces_map.m >= planning_parameters.lower_threshold);
        P = reshape(diag(faces_map.P)', size(faces_map.m));
        P_i = sum(P(above_thres_ind));
    else
        P_i = trace(faces_map.P);
    end
    
    % Discard path if it is too long. Why?
    if (num_points_meas > 10)
        obj = Inf;
        return;
    end
    
    % Discard path if out side environment
    if (any(viewpoints_meas(:,1) > dim_x_env(2)) || ...
            any(viewpoints_meas(:,2) > dim_y_env(2)) || ...
            any(viewpoints_meas(:,3) > dim_z_env(2)) || ...
            any(viewpoints_meas(:,1) < dim_x_env(1)) || ...
            any(viewpoints_meas(:,2) < dim_y_env(1)) || ...
            any(viewpoints_meas(:,3) < dim_z_env(1)))
        obj = 100;
        return;
    end
    
    % Predict measurements along the path.
    for i = 1 : num_points_meas
        try
            faces_map = predict_map_var_update(viewpoints_meas(i,:), faces_map, ...
                map_parameters, sensor_parameters);
        catch
            obj = Inf;
            return;
        end
    end

    if (planning_parameters.use_threshold)
        P = reshape(diag(faces_map.P)', size(faces_map.m));
        P_f = sum(P(above_thres_ind));
    else
        P_f = trace(faces_map.P);
    end

    % Formulate objective.
    gain = P_i - P_f;
    if (strcmp(planning_parameters.obj, 'exponential'))
        cost = get_trajectory_total_time(trajectory);
        obj_info = -gain*exp(-planning_parameters.lambda*cost);
    elseif (strcmp(planning_parameters.obj, 'rate'))
        cost = max(get_trajectory_total_time(trajectory), 1/planning_parameters.measurement_frequency);
        obj_info = -gain/cost;
    end
    
    obj = obj_coll + obj_info;

    %disp(['Measurements = ', num2str(i)])
    %disp(['Gain = ', num2str(gain)])
    %disp(['Cost = ', num2str(cost)])
    %disp(['Objective = ', num2str(obj)])

end
