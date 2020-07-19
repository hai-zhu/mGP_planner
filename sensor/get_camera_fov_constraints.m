function [A, b] = get_camera_fov_constraints(cam_pos, cam_roll, cam_pitch, cam_yaw, ...
    fov_x, fov_y, fov_range_min, fov_fange_max)
% Determine the camera's FOV constraints represented by a set of linear
% inequality constraints
%
% Input:
%   ax: axis handle for plotting
%   cam_pos: camera position, [3x1], m
%   cam_roll: camera roll, rad
%   cam_pitch: camera pitch, rad
%   cam_yaw: camera yaw, rad
%   fov_x: FOV horizontal angle
%   fov_y: FOV vertical angle
%   fov_range_min: FOV depth range min
%   fov_range_max: FOV depth range max
% ---
% Output:
%   A, b: linear ineuqality constraints, A*p <= b
%   A: [6x3], b: [6x1]


    % compute the four max range "bottom" points under zero pitch and yaw
    % and as camera at origin
    bottom_dy_max = fov_range_max * sin(0.5*fov_x);
    bottom_dz_max = fov_range_max * sin(0.5*fov_y);
    upper_left_max = [fov_range_max; bottom_dy_max; bottom_dz_max];
    upper_right_max = [fov_range_max; -bottom_dy_max; bottom_dz_max];
    lower_left_max = [fov_range_max; bottom_dy_max; -bottom_dz_max];
    lower_right_max = [fov_range_max; -bottom_dy_max; -bottom_dz_max];
    
    % the min fov range
    
    
    % rotation and translation
    R = rotx(rad2deg(cam_roll))*roty(rad2deg(cam_pitch))*rotz(rad2deg(cam_yaw));
    upper_left_max = R*upper_left_max + cam_pos;
    upper_right_max = R*upper_right_max + cam_pos;
    lower_left_max = R*lower_left_max + cam_pos;
    lower_right_max = R*lower_right_max + cam_pos;
    
    % linear inequality constraints
    A = zeros(6, 3);
    b = zeros(6, 1);
    
end
