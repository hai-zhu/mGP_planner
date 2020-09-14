function yaw_best = get_best_yaw(pos, map_parameters)
% Determine the best yaw for taking measurement
    
    % for cylinder case
    center_pos = map_parameters.center_pos;
    dx = center_pos(1) - pos(1);
    dy = center_pos(2) - pos(2);
    yaw_best = atan2(dy, dx);

    % boeing 747 case
%     x = pos(1);
%     y = pos(2);    
%     if (abs(y-32) <= 8)
%         center_pos = [x, 32, 28];
%         dx = center_pos(1) - pos(1);
%         dy = center_pos(2) - pos(2);
%         yaw_best = atan2(dy, dx);
%     elseif (2*x-y-30.96 >= 0)
%         yaw_best = -pi;
%     elseif (2*x+y-100 >= 0 )
%         yaw_best = -pi;
%     else
%         yaw_best = 0;
%     end
        
    
    

end
