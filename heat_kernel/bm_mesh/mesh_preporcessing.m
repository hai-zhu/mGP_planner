%% Mesh pre-processing
function mesh = mesh_preporcessing(TR)

    mesh.numV = size(TR.Points, 1);             % number of vertices
    mesh.numF = size(TR.ConnectivityList, 1);   % number of faces
    mesh.V    = TR.Points';                     % vertices, 3xV
    mesh.F    = TR.ConnectivityList';           % faces information, 3xF
    mesh.F_center = incenter(TR)';              % faces center, 3xF
    mesh.F_normals = faceNormal(TR)';           % faces normals, 3xF
    mesh.bases= zeros(3, mesh.numF);            % first vetice as base point of each face, 3xF
    mesh.Faces_Edges_Id = zeros(2, 3, mesh.numF); % edge vertices id information, 2xJXF
    mesh.Faces_Edges = zeros(3, 3, mesh.numF);  % edge relative position information, 3xJxF
    % faces area information
    mesh.F_area = zeros(1, mesh.numF);
    for i = 1 : mesh.numF
        mesh.F_area(1, i) = triangle_area_3d(mesh.V(:, mesh.F(1, i)), ...
            mesh.V(:, mesh.F(2, i)), mesh.V(:, mesh.F(3, i)));
    end
    % faces edge information
    for i = 1 : mesh.numF
        mat = zeros(3, 3);
        for j = 1 : 3
            idx1 = mesh.F(j, i);
            idx_temp = j+1;
            if idx_temp > 3
                idx_temp = 1;
            end
            idx2 = mesh.F(idx_temp, i);
            mat(:, j) = mesh.V(:, idx2) - mesh.V(:, idx1);
            mesh.Faces_Edges_Id(:, j, i) = [idx1, idx2];
        end
        mesh.bases(:, i) = mesh.V(:, mesh.F(1, i)); % 3x1
        mesh.Faces_Edges(:, :, i) = mat;        % three columns: p12, p23, p31
    end
    % faces coordinate transformation information
    mesh.Jacobian_l2g = zeros(3, 2, mesh.numF); % local to global, Jacobian transformation, 3x2xF
    mesh.Jacobian_g2l = zeros(2, 3, mesh.numF); % global to local, inv Jacobian transformation, 2x3xF
    for i = 1 : mesh.numF
        p21 = mesh.V(:, mesh.F(2, i)) - mesh.V(:, mesh.F(1, i));    % p2 - p1, 3x1
        p31 = mesh.V(:, mesh.F(3, i)) - mesh.V(:, mesh.F(1, i));    % p3 - p1, 3x1
        J = [p21, p31];                                             % 3x2
        mesh.Jacobian_l2g(:, :, i) = J;                             % 3x2
        JInv = pinv(J);
        mesh.Jacobian_g2l(:, :, i) = JInv;                          % 2x3
        % store into one struct
        mesh.coord_l2g(i).base = mesh.V(:, mesh.F(1, i));           % 3x1
        mesh.coord_l2g(i).Jacobian = J;                             % 3x2
        mesh.coord_g2l(i).base = mesh.V(:, mesh.F(1, i));           % 3x1
        mesh.coord_g2l(i).JacobianInv = JInv;                       % 2x3
    end
    % triangle adjacency information
    mesh.TT = zeros(3, mesh.numF);              % for each face, 3xF, three neighbors to p12, p23, p31
    for i = 1 : mesh.numF
        for j = 1 : 3
            idx1 = mesh.Faces_Edges_Id(1, j, i);
            idx2 = mesh.Faces_Edges_Id(2, j, i);
            tri_temp = edgeAttachments(TR, idx1, idx2); % 2 attaches
            mesh.TT(j, i) = tri_temp{1}(1);
        end
    end
    % rotation matrix between faces
    mesh.RotMat = zeros(3, 3, 3, mesh.numF);    % 3x3xJxF
    for i = 1 : mesh.numF           % loop for each face
        for j = 1 : 3               % loop for each neighbor face of the face
            idx_nbor = mesh.TT(j, i);   % the neighbor
            normal_i = mesh.F_normals(:, i);            % 3x1
            normal_j = mesh.F_normals(:, idx_nbor);     % 3x1
            director = mesh.Faces_Edges(:, j, i);       % 3x1
            director = director / norm(director);       % 3x1
            proj = dot(normal_i, normal_j);
            if (proj > 1)
                angle = 0;
            elseif (proj < -1)
                angle = -pi;
            else
                angle = acos(proj);
            end
            rot_m = axang2rotm([director', angle]);
            mesh.RotMat(:, :, j, i) = rot_m;
            % checking
            diff = norm(rot_m*normal_i - normal_j);
            diff3 = norm(rot_m*normal_j - normal_i);
            if (diff > 1e-2)
                rot_m = rot_m';
                mesh.RotMat(:, :, j, i) = rot_m;
                diff2 = norm(rot_m*normal_i - normal_j);
            end
            % position and velocity transformatin
            mesh.localtransform_v2v(j, i).rot_m = mesh.Jacobian_g2l(:, :, idx_nbor) * rot_m * ...
                mesh.Jacobian_l2g(:, :, i);
            mesh.localtransform_p2p(j, i).base1 = mesh.bases(:, i);
            mesh.localtransform_p2p(j, i).base2 = mesh.bases(:, idx_nbor);
            mesh.localtransform_p2p(j, i).Jacobian1 = mesh.Jacobian_l2g(:, :, i);
            mesh.localtransform_p2p(j, i).JacobianInv2 = mesh.Jacobian_g2l(:, :, idx_nbor);
        end
    end



end

