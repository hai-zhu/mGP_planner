function path = search_lattice_viewpoints(viewpoint_init, lattice_viewpoints, ...
    faces_map, map_parameters, sensor_parameters, planning_parameters)
% Performs a greedy grid search over a list of candidates to identify
% most promising points to visit based on an informative objective.
% Starting point is fixed (no measurement taken here)
% ---
% Inputs:
%   - viewpoint_init: starting viewpoint
%   - lattice_viewpoints: list of candidates to evaluate
%   - lattice_los_neighbors: lattice los neighbors information
%   - faces_map: current faces map (mean + covariance)
% ---
% Output:
% path: grid search result
% ---
% H Zhu 2020
%

    P_trace_prev = trace(faces_map.P);
    viewpoint_prev = viewpoint_init;
    path = viewpoint_init;

    % First measurement?
    while (planning_parameters.control_points > size(path, 1))

        % Initialise best solution so far.
        obj_min = Inf;
        viewpoint_best = -Inf;

        for i = 1:size(lattice_viewpoints, 1)

            viewpoint_eval = lattice_viewpoints(i, :);
            
            % if the viewpoint is in LoS
            if (if_in_los(viewpoint_prev(1:3)', viewpoint_eval(1:3)', map_parameters))
                faces_map_eval =  predict_map_var_update(viewpoint_eval, faces_map, ...
                    map_parameters, sensor_parameters);
                P_trace = trace(faces_map_eval.P);

                gain = P_trace_prev - P_trace;

                if (strcmp(planning_parameters.obj, 'exponential'))
                    cost = pdist([viewpoint_prev(1:3); viewpoint_eval(1:3)])/planning_parameters.max_vel;
                    obj = -gain*exp(-planning_parameters.lambda*cost);
                elseif (strcmp(planning_parameters.obj, 'rate'))
                    cost = max(pdist([viewpoint_prev(1:3); viewpoint_eval(1:3)])/planning_parameters.max_vel, ...
                        1/planning_parameters.measurement_frequency);
                    obj = -gain/cost;
                end

                %disp(['Point ', num2str(viewpoint_eval)]);
                %disp(['Gain: ', num2str(gain)])
                %disp(['Cost: ', num2str(cost)])
                %disp(num2str(obj));

                % Update best solution.
                if (obj < obj_min)
                    obj_min = obj;
                    viewpoint_best = viewpoint_eval;
                end
            else
                continue;
            end

        end

        % Update the map with measurement at best point.
        faces_map = predict_map_var_update(viewpoint_best, faces_map, ...
            map_parameters, sensor_parameters);
        disp(['Point ', num2str(size(path,1)+1), ' at: ', num2str(viewpoint_best)]);
        disp(['Trace of P: ', num2str(trace(faces_map.P))]);
        disp(['Objective: ', num2str(obj_min)]);
        path = [path; viewpoint_best];

        P_trace_prev = trace(faces_map.P);
        viewpoint_prev = viewpoint_best;

    end

end
