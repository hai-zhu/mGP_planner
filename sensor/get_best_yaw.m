function yaw_best = get_best_yaw(pos, map_parameters)
% Determine the best yaw for taking measurement

    center_pos = map_parameters.center_pos;
    dx = center_pos(1) - pos(1);
    dy = center_pos(2) - pos(2);
    yaw_best = atan2(dy, dx);

end
