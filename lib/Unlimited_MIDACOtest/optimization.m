function optimization

clear all; clear mex; clc 

L = 1;
license = 'Shen_Hongxin_(NatUniDefTech_China)__[ACADEMIC-SINGLE-MATLAB]';

n    = 50;
nint = 50;
m    = 1;
me   = 0;

xl   = -n * ones(1,n);
xu   = n * ones(1,n);

printeval   = 1;
acc         = 0.001;

x           = zeros(1,n);

param(1) = 0; % SEED
param(2) = 0; % QSTART
param(3) = 0; % AUTOSTOP
param(4) = 0; % ORACLE
param(5) = 0; % ANTS
param(6) = 0; % KERNEL
param(7) = 0; % CHARACTER

ifail  = 0;
istop  = 0;
eval   = 0;

maxeval  = 10e6;

fff = zeros(1,L);
ggg = zeros(1,L*m);
xxx = zeros(1,L*n);

for i = 1:n
        xxx(i) = int32(xl(i) + rand * (xu(i) - xl(i)));
end

gen = 0;
for gen = 1 : 20000
    
        x = xxx(1:n);     % Get X out of XXX
        
        [f,g] = problem_function(x);          % Evaluate objective function
        eval = eval + 1;                  % Count evaluation
        
        fff(1)   = f;     % Store F in FFF
        ggg(1:m) = g;     % Store G in GGG

       [xxx,ifail,pf,px,pc] = LinkMIDACO(n,nint,m,me,xxx,fff,ggg,xl,xu,acc,ifail,istop,param,printeval);
       
        if(pc > 0)
            fprintf('eval = %d\t\t  pf = %d\t\t  fff = %d\t\t  ggg = %f\n',eval,pf,fff(1),ggg(1));
        end
        
end
       
        fprintf('\nEach Variable: \n');
        for i = 1 : n
            fprintf('X[%d] = %f\n', i, px(i));
        end
        
end


function [f,g] = problem_function(x)

f = 0;
for i = 1 : 50
    f = f + (x(i)-i)^2;
end

g = x(1) - 2;

end








