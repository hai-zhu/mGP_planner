function occupancy = mesh_to_occupancy(FV, dim_x_env, dim_y_env, dim_z_env, ...
    resolution)

    dim_x = diff(dim_x_env)/resolution;
    dim_y = diff(dim_y_env)/resolution;
    dim_z = diff(dim_z_env)/resolution;

    occupancy = false(dim_x, dim_y, dim_z);
    
    parfor i = 1 : dim_x
        x = dim_x_env(1) + (i-0.5)*resolution;
        for j = 1 : dim_y
            y = dim_y_env(1) + (j-0.5)*resolution;
            for k = 1 : dim_z
                z = dim_z_env(1) + (k-0.5)*resolution;
                pos = [x, y, z];
                dis = point2trimesh(FV, 'QueryPoints', pos);
                if dis <=0 
                    occupancy(i,j,k) = true;
                end
            end
        end
    end
end