% an example of simulating a single particle in one-dimensional

clear all
clear 
clc 

N = 1000;
displacement = randn(1,N);
plot(displacement);

histogram(displacement, 25);

x = cumsum(displacement);
plot(x);
ylabel('position');
xlabel('time step');
title('Position of 1D Particle versus Time');

