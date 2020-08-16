function faces_map = create_initial_map(map_parameters)

    % prediction map
    faces_map.m = zeros(map_parameters.num_faces, 1);
    faces_map.P = zeros(map_parameters.num_faces, map_parameters.num_faces);
    % prior map
    faces_map.m = 0.5.*ones(size(faces_map.m));
    for i = 1 : map_parameters.num_faces
        for j = i : map_parameters.num_faces
            d_ij = norm(map_parameters.F_center(i,:)-map_parameters.F_center(j,:));
            k_ij = cov_materniso_3(d_ij/10, map_parameters.sigma_f, map_parameters.l);
            faces_map.P(i, j) = k_ij;
            faces_map.P(j, i) = k_ij;
        end
    end

end