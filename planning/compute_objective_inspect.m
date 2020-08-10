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

    % Create polynomial path through the control points.
    trajectory = plan_path_waypoints(control_points(:,1:3), ...
        planning_parameters.max_vel, planning_parameters.max_acc);

    % Sample trajectory to find locations to take measurements at.
    [~, points_meas, ~, ~] = sample_trajectory(trajectory, ...
        1/planning_parameters.measurement_frequency);
    
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
        obj = -gain*exp(-planning_parameters.lambda*cost);
    elseif (strcmp(planning_parameters.obj, 'rate'))
        cost = max(get_trajectory_total_time(trajectory), 1/planning_parameters.measurement_frequency);
        obj = -gain/cost;
    end

    %disp(['Measurements = ', num2str(i)])
    %disp(['Gain = ', num2str(gain)])
    %disp(['Cost = ', num2str(cost)])
    %disp(['Objective = ', num2str(obj)])

end
