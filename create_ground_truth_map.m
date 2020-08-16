function ground_truth_faces_map = create_ground_truth_map(map_parameters)

    % ground truth
    data_map = load('map_3D.mat');
    map_3D = data_map.ground_truth_map;
    resolution = 0.5;
    F_value = zeros(map_parameters.num_faces, 1);
    for iF = 1 : map_parameters.num_faces
        center_iF = map_parameters.F_center(iF, :);
        idx_iF(1:2) = round(center_iF(1:2) / resolution) + 40;
        idx_iF(3) = round(center_iF(3) / resolution) + 20;
        F_value(iF) = map_3D(idx_iF(1), idx_iF(2), idx_iF(3));
    end
    ground_truth_faces_map = F_value;


end