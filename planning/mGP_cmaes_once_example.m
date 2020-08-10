% a planning example
close all
clear all
clear 
clc 

%% Environment
% map environments
data_mesh = load('simple_cylinder_solid.mat');
TR = data_mesh.TR;
num_faces = size(TR.ConnectivityList, 1);
num_vertices = size(TR.Points, 1);
F_normal = faceNormal(TR);
F_center = incenter(TR);
F_points = zeros(num_faces, 3, 3);
for iFace = 1 : num_faces
    F_points(iFace, :, 1) = TR.Points(TR.ConnectivityList(iFace, 1), :);    % 1x3
    F_points(iFace, :, 2) = TR.Points(TR.ConnectivityList(iFace, 2), :);
    F_points(iFace, :, 3) = TR.Points(TR.ConnectivityList(iFace, 3), :);
end


%% Parameters
[sensor_parameters, map_parameters, planning_parameters, ...
    matlab_parameters] = load_parameteres(num_faces, F_center, F_normal, F_points);


%% Ground truth and initial map
% ground truth
dim_x_env = map_parameters.dim_x_env;
dim_y_env = map_parameters.dim_y_env;
dim_z_env = map_parameters.dim_z_env;
data_map = load('map_3D.mat');
map_3D = data_map.ground_truth_map;
resolution = 0.5;
F_value = zeros(num_faces, 1);
for iF = 1 : num_faces
    center_iF = F_center(iF, :);
    idx_iF(1:2) = round(center_iF(1:2) / resolution) + 40;
    idx_iF(3) = round(center_iF(3) / resolution) + 20;
    F_value(iF) = map_3D(idx_iF(1), idx_iF(2), idx_iF(3));
end
ground_truth_faces_map = F_value;
% prediction map
faces_map.m = zeros(num_faces, 1);
faces_map.P = zeros(num_faces, num_faces);
% prior map
faces_map.m = 0.5.*ones(size(faces_map.m));
for i = 1 : num_faces
    for j = i : num_faces
        d_ij = norm(F_center(i,:)-F_center(j,:));
        k_ij = cov_materniso_3(d_ij/10, map_parameters.sigma_f, map_parameters.l);
        faces_map.P(i, j) = k_ij;
        faces_map.P(j, i) = k_ij;
    end
end
% faces_map.P = eye(num_faces);       % for debugging
P_prior = diag(faces_map.P);

if (matlab_parameters.visualize_map)
    
    figure;
    
    subplot(2, 4, 1)
    hold on;
    axis([-3 15 -3 15 0 25]);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Ground truth map')
    daspect([1 1 1]);
    view(3);
    trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
        TR.Points(:,3), F_value, 'EdgeAlpha', 0);
    caxis([0, 1]);
    
    subplot(2, 4, 2)
    hold on;
    axis([-3 15 -3 15 0 25]);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Mean - prior')
    daspect([1 1 1]);
    view(3);
    trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
        TR.Points(:,3), faces_map.m, 'EdgeAlpha', 0);
    caxis([0, 1]);
    
    subplot(2, 4, 6)
    hold on;
    axis([-3 15 -3 15 0 25]);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title(['Var. - prior. Trace = ', num2str(trace(faces_map.P), 5)])
    daspect([1 1 1]);
    view(3);
    trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
        TR.Points(:,3), P_prior, 'EdgeAlpha', 0);
    var_max = max(P_prior);
    caxis([0 var_max]);
 
end


%% Take first measurement
viewpoint_init = [0, 0, 4, deg2rad(45)];
faces_map = take_measurement_at_viewpoint(viewpoint_init, faces_map, ...
        ground_truth_faces_map, map_parameters, sensor_parameters);
P_post = diag(faces_map.P);
P_trace_init = trace(faces_map.P);
P_prior = P_post;

if (matlab_parameters.visualize_map)

    subplot(2, 4, 3)
    hold on;
    axis([-3 15 -3 15 0 25]);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Mean - init ')
    daspect([1 1 1]);
    view(3);
    trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
        TR.Points(:,3), faces_map.m, 'EdgeAlpha', 0);
    caxis([0 1]);
    
    subplot(2, 4, 7)
    hold on;
    axis([-3 15 -3 15 0 25]);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title(['Var. - init Trace = ', num2str(trace(faces_map.P), 5)])
    daspect([1 1 1]);
    view(3);
    trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
        TR.Points(:,3), P_post, 'EdgeAlpha', 0);
    caxis([0 var_max]);
    
end


%% Lattice viewpoints
data_lattice = load('cylinder_lattice_viewpoints_0.mat');
lattice_viewpoints = data_lattice.lattice_viewpoints;
num_lattice_viewpoints = size(lattice_viewpoints, 1);


%% Planning:

%% Step 1: Grid search on the lattice viewpoints
P_trace_prev = P_trace_init;
viewpoint_prev = viewpoint_init;
faces_map_plan = faces_map;
path = viewpoint_init;

while (planning_parameters.control_points > size(path, 1))
    
    % Initialise best solution so far.
    obj_min = Inf;
    viewpoint_best = -Inf;

    for i = 1:size(lattice_viewpoints, 1)

        viewpoint_eval = lattice_viewpoints(i, :);
        
        % if the viewpoint is in LoS
        
        faces_map_eval =  predict_map_var_update(viewpoint_eval, faces_map_plan, ...
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
        
        %disp(['Evaluating Candidate No. ', num2str(i), ': ', num2str(viewpoint_eval)]);
        %disp(['Objective: ', num2str(obj)]);
        
        % Update best solution.
        if (obj < obj_min)
            obj_min = obj;
            viewpoint_best = viewpoint_eval;
        end
        
    end
    
    faces_map_plan = predict_map_var_update(viewpoint_best, faces_map_plan, ...
        map_parameters, sensor_parameters);
    disp(['Point ', num2str(size(path,1)+1), ' at: ', num2str(viewpoint_best)]);
    disp(['Trace of P: ', num2str(trace(faces_map_plan.P))]);
    disp(['Objective: ', num2str(obj_min)]);
    path = [path; viewpoint_best];
    
    P_trace_prev = trace(faces_map_plan.P);
    viewpoint_prev = viewpoint_best;
    
end

obj = compute_objective_inspect(path, faces_map, map_parameters, sensor_parameters, ...
    planning_parameters);
disp(['Objective before optimization: ', num2str(obj)]);


%% STEP 2. CMA-ES optimization, only optimize position now.
% Set optimization parameters
opt = cmaes;
opt.DispFinal = 'off';
opt.LogModulo = 0;
opt.TolFun = 1e-9;
opt.IncPopSize = 1;
opt.SaveVariables = 'off';
opt.MaxIter = planning_parameters.max_iters;
opt.Seed = randi(2^10);

% Set bounds and covariances.
LBounds = [dim_x_env(1); dim_y_env(1); dim_z_env(1)];
UBounds = [dim_x_env(2); dim_y_env(2); dim_z_env(2)];
opt.LBounds = repmat(LBounds, size(path,1)-1, 1);
opt.UBounds = repmat(UBounds, size(path,1)-1, 1);
cov = [5; 5; 5];
cov = repmat(cov, size(path,1)-1, 1);

% Remove starting point (as this is fixed).
path_initial = reshape(path(2:end,1:3)', [], 1);
path_optimized = cmaes('optimize_viewpoints', path_initial, cov, opt, viewpoint_init(1:3), ...
    faces_map, map_parameters, sensor_parameters, planning_parameters);
path_optimized = reshape(path_optimized, 3, [])';
path_optimized = [viewpoint_init(1:3); path_optimized];


%% Plan Execution %%
% Create polynomial path through the control points.
trajectory = plan_path_waypoints(path_optimized(:,1:3), ...
        planning_parameters.max_vel, planning_parameters.max_acc);

% Sample trajectory to find locations to take measurements at.
[t, measurement_points, ~, ~] = ...
    sample_trajectory(trajectory, 1/planning_parameters.measurement_frequency);

% Find the corresponding yaw
num_points_meas = size(measurement_points,1);
viewpoints_meas = zeros(num_points_meas, 4);
center_pos = [6; 6; 11];
for i = 1 : num_points_meas
    viewpoints_meas(i, 1:3) = measurement_points(i, 1:3);
    dx = center_pos(1) - viewpoints_meas(i, 1);
    dy = center_pos(2) - viewpoints_meas(i, 2);
    viewpoints_meas(i, 4) = atan2(dy, dx);
end

% Take measurements along path.
for i = 2:size(measurement_points,1)
    faces_map = take_measurement_at_viewpoint(viewpoints_meas(i,:), faces_map, ...
            ground_truth_faces_map, map_parameters, sensor_parameters);
end

disp(['Trace after execution: ', num2str(trace(faces_map.P))]);
disp(['Time after execution: ', num2str(get_trajectory_total_time(trajectory))]);
gain = P_trace_init - trace(faces_map.P);
if (strcmp(planning_parameters.obj, 'rate'))
    cost = max(get_trajectory_total_time(trajectory), 1/planning_parameters.measurement_frequency);
    disp(['Objective after optimization: ', num2str(-gain/cost)]);
elseif (strcmp(planning_parameters.obj, 'exponential'))
    cost = get_trajectory_total_time(trajectory);
    disp(['Objective after optimization: ', num2str(-gain*exp(-planning_parameters.lambda*cost))]);
end
P_post = diag(faces_map.P);

if (matlab_parameters.visualize_map)
    
    subplot(2, 4, 4)
    hold on;
    axis([-3 15 -3 15 0 25]);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Mean - final ')
    daspect([1 1 1]);
    view(3);
    trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
        TR.Points(:,3), faces_map.m, 'EdgeAlpha', 0);
    caxis([0 1]);
    
    subplot(2, 4, 8)
    hold on;
    axis([-3 15 -3 15 0 25]);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title(['Var. - final Trace = ', num2str(trace(faces_map.P), 5)])
    daspect([1 1 1]);
    view(3);
    trisurf(TR.ConnectivityList, TR.Points(:,1), TR.Points(:,2), ...
        TR.Points(:,3), P_post, 'EdgeAlpha', 0);
    caxis([0 var_max]);
    
end

if (matlab_parameters.visualize_path)
    
    fig_path = figure;
    hold on;
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    ax_path = fig_path.CurrentAxes;
    daspect(ax_path, [1 1 1]);
    view(ax_path, 3);
    
    % path and viewpoints
    axis([dim_x_env dim_y_env dim_z_env]);
    plot_path_viewpoints(ax_path, 1, path_optimized, trajectory, viewpoints_meas);
    
    % mesh object
    h_mesh = trimesh(TR);
    h_mesh.FaceColor = 'w';
    h_mesh.FaceAlpha = 1;
    h_mesh.EdgeColor = 'c';
    h_mesh.LineWidth = 0.5;
    h_mesh.LineStyle = '-';
    
    % camera fov
    for i = 1 : num_points_meas
%         pause;
        cam_pos = viewpoints_meas(i, 1:3)';
        cam_roll = sensor_parameters.cam_roll;
        cam_pitch = sensor_parameters.cam_pitch;
        cam_yaw = sensor_parameters.cam_yaw + viewpoints_meas(i,4);
        plot_camera_fov(ax_path, cam_pos, cam_roll, cam_pitch, cam_yaw, ...
            sensor_parameters.fov_x, sensor_parameters.fov_y, ...
            sensor_parameters.fov_range_max, 'r');
        [F_visible, faces_visible] = get_visible_faces(num_faces, F_points, F_center, ...
            F_normal, cam_pos, cam_roll, cam_pitch, cam_yaw, sensor_parameters);
        for iFace = 1 : num_faces
            if F_visible(iFace) == 1
                patch(ax_path, 'XData', F_points(iFace, 1, :), ...
                      'YData', F_points(iFace, 2, :), ...
                      'ZData', F_points(iFace, 3, :), ...
                      'FaceColor', 'b', ... 
                      'FaceAlpha', 0.5, ...
                      'EdgeColor', 'b');
            end
        end
    end
    
end


