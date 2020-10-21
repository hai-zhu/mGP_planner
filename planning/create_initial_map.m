function faces_map = create_initial_map(map_parameters)

    faces_map.m = zeros(map_parameters.num_faces, 1);
    faces_map.P = zeros(map_parameters.num_faces, map_parameters.num_faces);

    % prior map mean 
    faces_map.m = 0.5.*ones(size(faces_map.m));
    
    
    % prior map cov
    switch map_parameters.kernel_choice
        case 0      % I
            disp('Covariance initialization: Identity matrix');
            faces_map.P = eye(map_parameters.num_faces);
        case 1      % Random SPD
            disp('Covariance initialization: Random SPD');
            SPDmatrix = generateSPDmatrix(map_parameters.num_faces);
            faces_map.P = 0.1 * SPDmatrix;
        case 2      % Matern
            disp('Covariance initialization: Matern kernel');
            for i = 1 : map_parameters.num_faces
                for j = i : map_parameters.num_faces
                    d_ij = norm(map_parameters.F_center(i,:)-map_parameters.F_center(j,:));
                    k_ij = cov_materniso_3(d_ij, map_parameters.sigma_f, map_parameters.l);
                    faces_map.P(i, j) = k_ij;
                    faces_map.P(j, i) = k_ij;
                end
            end
        case 3      % SE
            disp('Covariance initialization: SE kernel');
            for i = 1 : map_parameters.num_faces
                for j = i : map_parameters.num_faces
                    d_ij = norm(map_parameters.F_center(i,:)-map_parameters.F_center(j,:));
                    k_ij = cov_se(d_ij/10, map_parameters.sigma_f, map_parameters.l);
                    faces_map.P(i, j) = k_ij;
                    faces_map.P(j, i) = k_ij;
                end
            end
        case 4      % Heat
            disp('Covariance initialization: Heat kernel');
            heat_kernel_obj = matfile([map_parameters.model_name, '_heat_kernel.mat'], ...
                'Writable', false);
            heat_kernel = heat_kernel_obj.heat_kernel(:, :, map_parameters.diff_f); % num_faces x num_faces
            % it should be symmetric
%             heat_kernel = 0.5 * (heat_kernel + heat_kernel');
            faces_map.P = map_parameters.sigma_h^2 .* heat_kernel;
        otherwise
            error('Kernel function not determined!');
    end
    
    % P should be semi-positive definite
    if min(eig(faces_map.P)) < 0
        error('Initial covariance matrix not semi-positive definite!');
    end
    
end
