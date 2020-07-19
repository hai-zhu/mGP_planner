clear all; close all; clc;

%% Parameters %%

% Environment
cluster_radius = 3;
% Dimensions [m]
dim_x_env = 30;
dim_y_env = 30;

planning_parameters.sensor_coeff_A = 0.05;
planning_parameters.sensor_coeff_B = 0.2;

% Camera fields of view (FoV)
planning_parameters.sensor_fov_angle_x = 60;
planning_parameters.sensor_fov_angle_y = 60;

% Map resolution [m/cell]
map_parameters.resolution = 0.75;
% Map dimensions [cells]
map_parameters.dim_x = dim_x_env/map_parameters.resolution;
map_parameters.dim_y = dim_y_env/map_parameters.resolution;
% Position of map in the environment [m]
map_parameters.position_x = -dim_x_env / 2;
map_parameters.position_y = -dim_y_env / 2;
dim_x = map_parameters.dim_x;
dim_y = map_parameters.dim_y;
% Prediction map dimensions [cells]
predict_dim_x = dim_x*1;
predict_dim_y = dim_y*1;

matlab_parameters.visualize = 1;

% Gaussian Process
cov_func = {'covMaterniso', 3};
lik_func = @likGauss;
inf_func = @infExact;
mean_func = @meanConst;

% Hyperparameters
hyp.mean = 0.5;
hyp.cov =  [1.3 0.3];
hyp.lik =  0.35;

% List of places in the environment to take measurements at
pos_env_list = [0, 0, 13; ...
                4, 5, 6];
pos_env_list = repmat(pos_env_list, 1, 1);


%% Data %%

% Generate (continuous) ground truth map.
ground_truth_map = create_continuous_map(dim_x, dim_y, cluster_radius);
[mesh_x,mesh_y] = meshgrid(linspace(1,dim_x,dim_x), linspace(1,dim_y,dim_y));
X_ref = [reshape(mesh_x, numel(mesh_x), 1), reshape(mesh_y, numel(mesh_y), 1)];

% Generate prediction map.
[mesh_x,mesh_y] = meshgrid(linspace(1,predict_dim_x,predict_dim_x), ...
    linspace(1,predict_dim_y,predict_dim_y));
Z =  [reshape(mesh_x, numel(mesh_x), 1), reshape(mesh_y, numel(mesh_y), 1)];

% Generate grid map.
grid_map.m = 0.5*ones(size(ground_truth_map));


%% Measurement and Inference %%
% Generate prior map. 
Y = reshape(grid_map.m,[],1);

% ymu, ys: mean and covariance for output
% fmu, fs: mean and covariance for latent variables
% post: struct representation of the (approximate) posterior
[ymu, ys, fmu, fs, ~ , post] = gp(hyp, inf_func, mean_func, cov_func, lik_func, ...
    X_ref, Y, Z);
ymu = reshape(ymu, predict_dim_y, predict_dim_x);

alpha = post.alpha;
L = post.L; 
sW = post.sW;
Kss = real(feval(cov_func{:}, hyp.cov, Z));
Ks = feval(cov_func{:}, hyp.cov, X_ref, Z);
Lchol = isnumeric(L) && all(all(tril(L,-1)==0)&diag(L)'>0&isreal(diag(L))');
if Lchol    % L contains chol decomp => use Cholesky parameters (alpha,sW,L)
  V = L'\(sW.*Ks);
  grid_map.P = Kss - V'*V;                       % predictive variances
 else                % L is not triangular => use alternative parametrisation
  if isnumeric(L), LKs = L*(Ks); else LKs = L(Ks); end    % matrix or callback
  grid_map.P = Kss + Ks'*LKs;                    % predictive variances
end

%% This is just to test in case of no-inference using only the kernel
% sn2=exp(2*hyp.lik);
% K = feval(cov_func{:},hyp.cov,X_ref);
% KplusR = K+ sn2*eye(length(K));
% grid_map.P = KplusR;
%%

% Extract variance map (diagonal elements).
Y_sigma = sqrt(diag(grid_map.P)');
P_prior = reshape(2*Y_sigma,predict_dim_y,predict_dim_x);

% Go through the positions to take measurements at, updating the map.
num_of_measurements = size(pos_env_list,1);
if (matlab_parameters.visualize)
    
    figure;
    subplot(2, num_of_measurements + 2, 1)
    imagesc(ground_truth_map)
    caxis([0, 1])
    title('Ground truth map')
    set(gca,'Ydir', 'Normal');
    
    subplot(2, num_of_measurements + 2, 2)
    imagesc(ymu)
    caxis([0, 1])
    title('Mean - prior')
    set(gca,'Ydir', 'Normal');
    
    subplot(2, num_of_measurements + 2, num_of_measurements + 4)
    contourf(P_prior)
    c1 = colorbar;
    P_climit = get(c1, 'Limits');
    colorbar off
    title(['Var. - prior. Trace = ', num2str(trace(grid_map.P), 5)])
    set(gca,'Ydir','Normal');
    
end

P_trace_prev = trace(grid_map.P);

for i = 1:num_of_measurements
    
%     pause;
    
    pos_env = pos_env_list(i, :);
    grid_map = take_measurement_at_point(pos_env, grid_map, ...
        ground_truth_map, map_parameters, planning_parameters);
    
    Y_sigma = sqrt(diag(grid_map.P)');
    P_post = reshape(2*Y_sigma,predict_dim_y,predict_dim_x);
    
    if (matlab_parameters.visualize)
        
        subplot(2, num_of_measurements + 2, i + 2)
        imagesc(grid_map.m)
        caxis([0, 1])
        title(['Mean - after ', num2str(i), ' meas.'])
        set(gca,'Ydir','Normal');
        if (i == num_of_measurements)
            c1 = colorbar;
        end
        
        subplot(2, num_of_measurements + 2, num_of_measurements + 4 + i)
        contourf(P_post)
        c = colorbar;
        set(c, 'Limits', P_climit);
        colorbar off
        title(['Var. Trace = ', num2str(trace(grid_map.P), 5)])
        set(gca,'Ydir','Normal');
        if (i == num_of_measurements)
            c2 = colorbar;
            set(gcf, 'Position', [113, 279, 2402, 800]);
        end
        
    end
    
    disp(['Measurement No. ', num2str(i), ': ', num2str(pos_env)]);
    disp(['Trace of P: ', num2str(trace(grid_map.P))]);
    disp(['Diff. in trace of P: ', num2str(trace(P_trace_prev - trace(grid_map.P)))]);
    
    P_trace_prev = trace(grid_map.P);
    
end