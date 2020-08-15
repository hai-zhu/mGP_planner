%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%      This is an example call of MIDACO 3.0
%      -------------------------------------
% 
%      MIDACO solves the general Mixed Integer Non-Linear Program (MINLP):
% 
% 
%            Minimize     F(X)      where X(1, ..., N-NINT) is *CONTINUOUS*
%                                   and   X(N-NINT+1,...,N) is *DISCRETE* 
% 
%            Subject to:  G_j(X)  =  0    ( j = 1,...,ME )
%                         G_j(X) >=  0    ( j = ME + 1,...,M )
% 
%            And bounds:  XL <= X <= XU 
%            
%      You can use this example as a template to run MIDACO on your own 
%      problem. In order to do so: Please replace the objective function  
%     'f' (and constraints 'g') given below as '[f,g]=problem_function(x)' 
%      with your own problem functions. Then simply follow the instruction 
%      steps 1 to 3 given in this file. 
% 
%      Type 'help midaco' in the command window to get more information! 
% 
%      Author: Martin Schlueter           
%              Theoretical and Computational Optimization Group,
%              School of Mathematics, University of Birmingham (UK)
%
%      Email:  info@midaco-solver.com
%      URL:    www.midaco-solver.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function example
clear all; clear mex; clc       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 0: Declare License-Key    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
license_key='Shen_Hongxin_(NatUniDefTech_China)__[ACADEMIC-SINGLE-MATLAB]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Problem definition     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 1.A : Define name of problem function (by function handle symbol '@')
problem.func = @problem_function; % Call must be [f,g] = problem_function(x) 

% Step 1.B : Define problem dimensions
problem.n    = 4; % Number of variables (in total)
problem.nint = 2; % Number of integer variables (0 <= nint <= n)
problem.m    = 3; % Number of constraints (in total)
problem.me   = 1; % Number of equality constraints (0 <= me <= m)
     
% Step 1.C : Define lower and upper bounds 'xl' and 'xu' for 'x'
problem.xl   = 1 * ones(1,problem.n);
problem.xu   = 4 * ones(1,problem.n);

% Step 1.D : Define starting point 'x'
problem.x    = problem.xl; % Here for example: 'x' = lower bounds 'xl'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Choose stopping criteria and printing options    %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 2.A : Decide maximal runtime by evalution and time budget
option.maxeval  = 123456;   % Maximal number of function evaluations (e.g. 1000000)
option.maxtime  = 60*60*24; % Maximal time limit in seconds (e.g. 1 day = 60*60*24 sec)

% Step 2.B : Choose printing options
option.printeval  = 10000;   % Print best solution after every *printeval* evaluation (e.g. 1000)
option.savescreen = 1;      % [0=No/1=Yes] Save screen to file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Choose constraint violation accuracy and advanced options    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 3.A : Tolerance for constraint violation
option.acc = 0.001; % RES(X) = L-infinity Norm (maximal violation) over g(x)

% Step 3.B : Choose MIDACO parameters (*ONLY FOR ADVANCED USERS*)  
option.param(1) = 0; % SEED
option.param(2) = 0; % QSTART
option.param(3) = 0; % AUTOSTOP
option.param(4) = 0; % ORACLE
option.param(5) = 0; % ANTS
option.param(6) = 0; % KERNEL
option.param(7) = 0; % CHARACTER

% Step 3.C : Set parallelization factor 'L' (= option.parallel)
option.parallel = 1; % L=1 ---> No parallelization (regular case)
                     % L>1 ---> MIDACO uses L threads in parallel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Call MIDACO solver   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
[ solution ] = midaco( problem, option, license_key);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   End of example    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Very small example test problem (replace f and g() with your own problem)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ f, g ] = problem_function( x )

% Objective function value f(x)
f =   (x(1)-1)^2 ...
    + (x(2)-2)^2 ...
    + (x(3)-3)^2 ...
    + (x(4)-4)^2 ...
    + 1.23456789;

% Equality constraints g(i) = 0 MUST COME FIRST in g(1:me)
g(1) = x(1) - 1;
% Inequality constraints g(i) >= 0 MUST COME SECOND in g(me+1:m)
g(2) = x(2) - 1.333333333;
g(3) = x(3) - 2.666666666;

return
%%%%%%%%%%%%%%%%%%
%  End of file   %
%%%%%%%%%%%%%%%%%%


