function h = plot_trajectory(time, pos)

    % Visualize a trajectory
    
    % Input:
    %   - ax: axis plot handle
    %   - time: time step, [Nx1]
    %   - pos: position, [NxD]
    % Output:
    %   - h: plot handle
    
    h = cline(pos(:,1), pos(:,2), pos(:,3), time);
    set(h, 'LineWidth', 2.5);
end
