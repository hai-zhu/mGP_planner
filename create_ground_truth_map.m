function ground_truth_faces_map = create_ground_truth_map(map_parameters)

    filename = 'simple_cylinder_excluded_thermal-Thermal 1-Results-Thermal1-2.csv';
    data_table = readtable(filename);
    data_array = table2array(data_table);
    % temprature data, [n x 4]
    % original data
    temperature_array = data_array(:, 2:5);     % temp, x, y, z
    temperature_array(:, 2:4) = temperature_array(:, 2:4)/100;   % convert to m

    % coordinate translation
    obj_center = map_parameters.center_pos;
    obj_center(3) = 0;
    temperature_array(:, 2:4) = temperature_array(:, 2:4) + obj_center';
    % get temperature of each face
    F_value = zeros(map_parameters.num_faces, 1);
    for i = 1 : map_parameters.num_faces
        pos_val = map_parameters.F_center(i, :);
        % find the cloest from raw data
        [~, idx_closest] = find_closest_point(pos_val, temperature_array(:, 2:4));
        F_value(i) = temperature_array(idx_closest, 1);
    end
    % scale F_values to be between 0 and 1
    min_value = min(F_value);
    max_value = max(F_value);
    F_value = (F_value - min_value) / (max_value - min_value);
    
    ground_truth_faces_map = F_value;

%     % ground truth
%     data_map = load('map_3D.mat');
%     map_3D = data_map.ground_truth_map;
%     resolution = 0.5;
%     F_value = zeros(map_parameters.num_faces, 1);
%     for iF = 1 : map_parameters.num_faces
%         center_iF = map_parameters.F_center(iF, :);
%         idx_iF(1:2) = round(center_iF(1:2) / resolution) + 40;
%         idx_iF(3) = round(center_iF(3) / resolution) + 20;
%         F_value(iF) = map_3D(idx_iF(1), idx_iF(2), idx_iF(3));
%     end
%     ground_truth_faces_map = F_value;

end