% an example of simulating multiple particles in two-dimensional

clear all
clear 
clc 

dimensions = 2;         % two dimensional simulation
particleCount = 10;
N = 50;
tau = .1;

d    = 1.0e-6;              % diameter in meters
eta  = 1.0e-3;              % viscosity of water in SI units (Pascal-seconds) at 293 K
kB   = 1.38e-23;            % Boltzmann constant
T    = 293;                 % Temperature in degrees Kelvin

D    = kB * T / (3 * pi * eta * d);
k = sqrt(D * dimensions * tau);

time = 0:tau:(N-1) * tau;
particle = { };             % create an empty cell array to hold the results

for i = 1:particleCount
    particle{i} = struct();
    particle{i}.dx = k * randn(1,N);
    particle{i}.x = cumsum(particle{i}.dx);
    particle{i}.dy = k * randn(1,N);
    particle{i}.y = cumsum(particle{i}.dy);
    particle{i}.drsquared = particle{i}.dx .^2 + particle{i}.dy .^ 2;
    particle{i}.rsquared = particle{i}.x .^ 2 + particle{i}.y .^ 2;
    particle{i}.D = mean( particle{i}.drsquared ) / ( 2 * dimensions * tau );
    particle{i}.standardError = std( particle{i}.drsquared ) / ( 2 * dimensions * tau * sqrt(N) );
end

figure;
hold on;
for i = 1:particleCount
    plot(particle{i}.x, particle{i}.y, 'color', rand(1,3));
end

xlabel('X position (m)');
ylabel('Y position (m)');
title('Combined Particle Tracks');
hold off;


