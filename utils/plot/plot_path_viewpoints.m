function [] = plot_path_viewpoints(ax, num_seg, path, trajectory, viewpoints_meas)
% Visualizes a trajectory from a list of control points.
    
t = [];
p = [];
p_meas = viewpoints_meas(:, 1:3);

    % Many segments
    if num_seg > 1
        % Loop for each seg
        for i = 1 : num_seg
            [t_poly, p_poly] = sample_trajectory(trajectory(i), 0.1);
            if (i == 1)
                t = [t; t_poly'];
            else
                t = [t; t(end) + t_poly'];
            end
            p = [p; p_poly];
        end

    % Single segments
    else
        [t, p] = sample_trajectory(trajectory, 0.1);
    end

    % Plot
    hold on
    % Visualize trajectory.
    h_line = cline(p(:,1), p(:,2), p(:,3), t);
    set(h_line, 'LineWidth', 2.5);
    % Visualize control points.
    scatter3(ax, path(:,1), path(:,2), path(:,3), 200, 'xk', 'MarkerFaceColor',[0 .75 .75]);
    % Visualize measurements.
    colors_meas = linspace(0, t(end), size(p_meas,1));

    % Silly bug with 3 points.
    % https://ch.mathworks.com/matlabcentral/newsreader/view_thread/136731
    if isequal(size(colors_meas),[1 3])
        colors_meas = colors_meas';
    end

    scatter3(ax, p_meas(:,1), p_meas(:,2), p_meas(:,3), 60, colors_meas, 'filled');

    xlabel('x (m)')
    ylabel('y (m)')
    zlabel('z (m)')
    % axis([-20 20 -20 20 0 35])
    grid minor
    colormap jet
    c = colorbar;
    ylabel(c, 'Time (s)')
    view(3)
%     legend('Path', 'Control pts.', 'Meas. pts.', ...
%         'Location', 'northeast')

end

