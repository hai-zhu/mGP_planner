function flag = if_in_los(viewpoint, viewpoint_next)

    cylinder_bottom_center = [6, 6, 0];
    cylinder_top_center = [6, 6, 22];
    cylinder_r = 6;
    
    seg_point_1 = viewpoint(1:3);
    seg_point_2 = viewpoint_next(1:3);
    
    d = DistBetween2Segment(seg_point_1, seg_point_2, ...
        cylinder_bottom_center, cylinder_top_center);
    
    if d > cylinder_r
        flag = 1;
    else
        flag = 0;
    end
    

end
