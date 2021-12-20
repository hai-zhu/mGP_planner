%% move a particle for one step on the mesh
function particle_new = particle_move_one_step(particle, mesh, dt)

    positionPrecision = 1e-4;
    timePrecision = 1e-6;
    % calculate tangent velocity
    velocity = particle.vel;                            % 3x1
    meshIdx = particle.meshFaceIdx;
    normal = mesh.F_normals(:, meshIdx);                % 3x1
    tangentV = velocity - normal*(dot(normal, velocity));   % 3x1
    % local velocity representation
    localV = mesh.Jacobian_g2l(:,:,meshIdx)*tangentV;
    %% one step movement
    t_residual = dt;
    while (t_residual > timePrecision)
        % move with local tangent speed
        localQ_new = particle.local_r + localV * t_residual;
        if (inTriangle(localQ_new))         % if still in current face
            t_residual = 0;
            % to avoid tiny negative number
            localQ_new(1) = abs(localQ_new(1));
            localQ_new(2) = abs(localQ_new(2));
            particle.local_r = localQ_new;
    %         break;
        else                                % not in this face anymore
            if (abs(particle.local_r(1)) < positionPrecision ...
                    && abs(1 - sum(particle.local_r)) >= positionPrecision)     % q:[0, <1]
                particle.local_r(1) = 2*positionPrecision;
                particle.local_r(2) = particle.local_r(2)-positionPrecision;
            elseif (abs(particle.local_r(2)) < positionPrecision ...
                    && abs(1 - sum(particle.local_r)) >= positionPrecision)     % q:[<1, 0]
                particle.local_r(2) = 2*positionPrecision;
                particle.local_r(1) = particle.local_r(1)-positionPrecision;
            elseif (abs(particle.local_r(1)) > positionPrecision && ...
                    abs(particle.local_r(2)) > positionPrecision && ...
                    abs(1 - sum(particle.local_r)) < positionPrecision)         % q:[<1, <1]
                particle.local_r(1) = particle.local_r(1) - positionPrecision;
                particle.local_r(2) = particle.local_r(2) - positionPrecision;
            elseif (abs(1-particle.local_r(1)) < positionPrecision)             % q:[1, 0]
                particle.local_r(1) = 1 - 3*positionPrecision;
                particle.local_r(2) = positionPrecision;
            elseif (abs(1-particle.local_r(2)) < positionPrecision)             % q:[0, 1]
                particle.local_r(2) = 1 - 3*positionPrecision;
                particle.local_r(1) = positionPrecision;
            elseif (abs(particle.local_r(1)) < positionPrecision ...
                    && abs(particle.local_r(2)) < positionPrecision)            % q:[0, 0]
                particle.local_r(1) = 2*positionPrecision;
                particle.local_r(2) = 2*positionPrecision;
            end
            % as long as the velocity vector is not parallel to the three edges, there will be a collision
            % t_hit will be negative if it move away from the edge
            t_hit(3) = -particle.local_r(1) / localV(1); % this third edge
            t_hit(1) = -particle.local_r(2) / localV(2); % the first edge
            t_hit(2) = (1 - sum(particle.local_r)) / sum(localV); % the second edge
            t_min = t_residual;
            min_idx = 0;
            % the minimum positive t_hit will hit
            for j = 1 : 3
                if (t_hit(j) > 1e-8 && t_hit(j) <= t_min)
                    t_min = t_hit(j);
                    min_idx = j;
                end
            end
            % in case there is no hit
            if (min_idx <= 0)
                warning('t_hit is not determined!');
                break;
            end
            % update local coordinate
            particle.local_r = particle.local_r + localV * t_min;
            % the correction step
            if (min_idx == 1)       % hit the first edge
                particle.local_r(2) = 0;
            elseif (min_idx == 2)   % hit the second edge
                particle.local_r(1) = 1 - particle.local_r(2);
            else                    % hit the third edge
                particle.local_r(1) = 0;
            end
            % update face triangle information
            meshIdx = particle.meshFaceIdx;
            newMeshIdx = mesh.TT(min_idx, meshIdx);
            particle.meshFaceIdx = newMeshIdx;
            % update t_residual
            t_residual = t_residual - t_min;
            % update localV on the new face 
            localV = mesh.localtransform_v2v(min_idx, meshIdx).rot_m * localV;
            % update local coordinate on the new face
            JacobianInv2 = mesh.localtransform_p2p(min_idx, meshIdx).JacobianInv2;
            Jacobian1 = mesh.localtransform_p2p(min_idx, meshIdx).Jacobian1;
            base1 = mesh.localtransform_p2p(min_idx, meshIdx).base1;
            base2 = mesh.localtransform_p2p(min_idx, meshIdx).base2;
            particle.local_r = JacobianInv2 * (Jacobian1*particle.local_r + base1 - base2);
        end
        % update global coordinate
        r_new = mesh.coord_l2g(particle.meshFaceIdx).base + ...
            mesh.coord_l2g(particle.meshFaceIdx).Jacobian*particle.local_r;
%         plot3([particle.r(1), r_new(1)], [particle.r(2), r_new(2)], ...
%             [particle.r(3), r_new(3)], '-b');
%         plot3(r_new(1),r_new(2),r_new(3),'*r');
        particle.r = r_new;
    end

    particle_new = particle;

end 



