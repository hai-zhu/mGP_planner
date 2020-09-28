% an example of simulating a single particle in two-dimensional

clear all
clear 
clc 

%% a simple example
N = 1000;

particle = struct();
particle.x = cumsum( randn(N, 1) );
particle.y = cumsum( randn(N, 1) );
plot(particle.x, particle.y);
hold on;
plot(particle.x(1), particle.y(1), 'or');
plot(particle.x(end,1), particle.y(end,1), 'sk');
ylabel('Y Position');
xlabel('X Position');
title('position versus time in 2D');

figure;
dsquared = particle.x .^ 2 + particle.y .^ 2;
plot(dsquared);


% a realistic example
d    = 1.0e-6;              % diameter in meters
eta  = 1.0e-3;              % viscosity of water in SI units (Pascal-seconds) at 293 K
kB   = 1.38e-23;            % Boltzmann constant
T    = 293;                 % Temperature in degrees Kelvin

D    = kB * T / (3 * pi * eta * d)

dimensions = 2;         % two dimensional simulation
tau = .1;               % time interval in seconds
time = tau * 1:N;       % create a time vector for plotting

k = sqrt(D * dimensions * tau);
dx = k * randn(N,1);
dy = k * randn(N,1);

x = cumsum(dx);
y = cumsum(dy);

dSquaredDisplacement = (dx .^ 2) + (dy .^ 2);
 squaredDisplacement = ( x .^ 2) + ( y .^ 2);

figure;
plot(x,y);
title('Particle Track of a Single Simulated Particle');

figure;
hold on;
plot(time, (0:1:(N-1)) * 2*k^2 , 'k', 'LineWidth', 3);      % plot theoretical line

plot(time, squaredDisplacement);
hold off;
xlabel('Time');
ylabel('Displacement Squared');
title('Displacement Squared versus Time for 1 Particle in 2 Dimensions');

simulatedD = mean( dSquaredDisplacement ) / ( 2 * dimensions * tau )
standardError = std( dSquaredDisplacement ) / ( 2 * dimensions * tau * sqrt(N) )
actualError = D - simulatedD
