%% move a particle for multiple steps on the mesh
function [particle_new, path, faceID_path] = particle_move_multiple_steps(particle, mesh, dt, speed, T)
   
    time_elapsed = 0;
    path = particle.r;
    faceID_path = particle.meshFaceIdx;
    while (time_elapsed < T)
        % generate a random velocity
        particle.vel = speed*randn(3, 1);
        % move the particle for one step on the mesh
        particle = particle_move_one_step(particle, mesh, dt);
        % update time
        time_elapsed = time_elapsed + dt;
        path = [path, particle.r];
        faceID_path = [faceID_path, particle.meshFaceIdx];
    end
    
    particle_new = particle;

end 



