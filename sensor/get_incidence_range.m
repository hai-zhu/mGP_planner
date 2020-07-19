function [range, incidence_cos] = get_incidence_range(...
    facet_points, facet_center, facet_normal, cam_pos)
% Compute the incidence and range from a camera to a facet when it is 
% in the field-of-view (FOV)
%
% Input:
%   facet_points: points of the facet triangle, [3x3], m
%   facet_center: center of the facet triangle, [3x1], m
%   facet_normal: normal of the facet triangle, [3x1], m
%   cam_pos: camera position, [3x1], m
% ---
% Output:
%   incidence_cos: cosine of the incidence angle
%   range: range from the camera to the facet, m


    % range computation
    range = (cam_pos - facet_center)' * facet_normal;
    
    % incidence computation, using facet center approximation
    % assuming the triangle is very small
    incidence_cos = range / (norm(cam_pos - facet_center));
    
end
