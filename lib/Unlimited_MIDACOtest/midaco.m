%%%%%%%%%%%%%%%%%%%%%%%%% MIDAC FORTRAN HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               
%                         
%      _|      _|  _|_|_|  _|_|_|      _|_|      _|_|_|    _|_|    
%      _|_|  _|_|    _|    _|    _|  _|    _|  _|        _|    _|  
%      _|  _|  _|    _|    _|    _|  _|_|_|_|  _|        _|    _|  
%      _|      _|    _|    _|    _|  _|    _|  _|        _|    _|  
%      _|      _|  _|_|_|  _|_|_|    _|    _|    _|_|_|    _|_|  
%
%                                                    Version 3.0 
%
%                                                           
%     MIDACO - Mixed Integer Distributed Ant Colony Optimization
%     ----------------------------------------------------------
%
%     This subroutine solves the general Mixed Integer Non-Linear Program (MINLP):
%
%             Minimize     F(X)            where X(1, ..., N-NINT) is *CONTINUOUS*
%                                          and   X(N-NINT+1,...,N) is *DISCRETE* 
%
%             Subject to:  G_j(X)  =  0    ( j = 1,...,ME )
%                          G_j(X) >=  0    ( j = ME + 1,...,M )
%
%             And bounds:  XL <= X <= XU  
%
%     MIDACO is a global optimization solver that stochastically approximates a solution to 
%     the above MINLP. It is based on an extended Ant Colony Optimization framework (see [1]) 
%     and the Oracle Penalty Method (see [2]) for constraint handling. MIDACO is called via
%     reverse communication, see below for a pseudo code of the reverse communication loop:
%
%     ~~~ while( STOP = 0 ) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%              call objective function F(X) and constaints G(X)
%
%              call midaco( X, F(X), G(X) )
%
%     ~~~ end ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%     In case of mixed integer problems, the continuous variables are stored first in 'X', while 
%     the discrete (also called integer/categorical) variables are stored behind the continuous 
%     ones. As an example consider:
%
%     X = (0.153, 1.786, 1.0, 2.0, 3.0)   where 'N' = 5 and 'NINT' = 3 (number of integer variables)
%
%     Note that all 'X' is of type double precision. Equality and inequality constraints are handled  
%     in a similar way. The vector 'G' stores at first the 'ME' equality constraints and behind 
%     those, the remaining 'M-ME' inequality constraints are stored. 
%
%     MIDACO is a derivate free black box solver and does not require the relaxation of integer variables 
%     (this menas, integer variables are treated as categorical variables). MIDACO does not require any user 
%     specified parameter tuning as it can be run completely on 'Autopilot'. However, the user can optionally 
%     adjust MIDACO to his/her specific needs by some parameters explained below. 
%
%     MIDACO can process a user defined amount of iterates at once within one single reverse communication
%     step. Hence the call of the objective function and constraint functions can be parallelized outside 
%     and independently from MIDACO. Using this option is only recommended for cpu-time consuming problems
%     (that require for example more than 0.1 second to be calculated). However, for those problems a 
%     significant speedup can be gained by parallelization. The amount of parallel processed iterates is 
%     determined by the value 'L' in the MIDACO call. If 'L' > 1 the 'L' different iterates must be stored 
%     one after another in the array 'X' which is of length 'L*N'. Respectively the objective function values 
%     and constraint vectors must be stored one after another in 'F(L)' and 'G(L*M)'. The parallelization 
%     option can be used on various platforms and cpu architectures. Some templates for parallel-usage of 
%     MIDACO are available at: http://www.midaco-solver.com/parallel.html
%
% 
%     Usage:
%     ------
%
%             CALL MIDACO(L,N,NINT,M,ME,X,F,G,XL,XU,ACC,
%                         IFAIL,ISTOP,PARAM,RW,LRW,IW,LIW,
%                         LICENSE_KEY)
%
%
%     List of arguments:
%     ------------------
%
%     L :      (Parallelization Factor)
%               Number of parallel submitted iterates 'X' (with corresponding 
%               objective function values 'F' and constraint values 'G') to MIDACO
%               within one reverse communication step. If no parallelization is desired,
%               set L = 1.
%
%     N :       Number of optimization variables in total (continuous and integer ones). 
%               'N' is the dimension of the iterate 'X' with X = (X_1,...,X_N).
%
%     NINT :    Number of integer optimization variables. 'NINT' <= 'N'.
%               Integer (discrete) variables must be stored at the end of 'X'.
%     
%     M :       Number of constraints in total (equality and inequality ones).
%               'L*M' is the dimension of a constraint vector 'G' with G = (G_1,...,G_M).
%
%     ME :      Number of equality constraints. 'ME' <= 'M'.
%               Equality constraints are stored in the beginning of 'G'. 
%              Inequality constraints are stored in the end of 'G'.
%
%     X(L*N) :  Array containing the iterates 'X'. For L=1 only one iterate is
%               stored in 'X'. For L>1 the iterates must be stored one after
%               another. For example, let L=2 and A=(A_1,...,A_N) and B=(B_1,...,B_N)
%               be the current two iterates submitted to MIDACO, then 'A' and 'B'
%               are stored in 'X' like this: X = (A_1,...,A_N, B_1,...,B_N).
%
%     F(L) :    Array containing the objective function values 'F' corresponding
%               to the iterates 'X'. For L=1 only one objective function value is
%               stored in F(1). For L>1 the values must be stored one after
%               another like the iterates in 'X'. For example, let L=2 and 'FA' and
%               'FB' be the objective function valules corresponding to the iterates
%               A=(A_1,...,A_N) and B=(B_1,...,B_N) from above, then 'FA' and 'FB'
%               are stored in 'F' like this: F = (FA, FB).
%
%     G(L*M) :  Array containing the constraint values 'G'. For L=1 only one vector
%               of constraint values G = (G_1,...,G_M) is stored in 'G'. For L>1 the
%               vectors must stored one after another. For example, let L=2 and
%               'GA' and 'GB' be the two constraint value vectors corresponding to 
%               the iterates A=(A_1,...,A_N) and B=(B_1,...,B_N) from above, then 'GA' 
%               and 'GB' are stored in 'G' like this: G = (GA_1,...,G_AM, GB_1,...,GB_M).
%
%     XL(N) :   Array containing the lower bounds for the iterates 'X'.
%               Note that for integer dimesions the bound should also be discrete,
%               but submitted as double precision type, e.g. XL(N-NINT+1) = 1.0.
%               Note that the entries of XL are *changed*, when MIDACO finishes (ISTOP=1).
%
%     XU(N) :   Array containing the upper bounds for the iterates 'X'. 
%               Note that for integer dimesions the bound should also be discrete,
%               but submitted as double precision type, e.g. XU(N-NINT+1) = 1.0.
%               Note that the entries of XU are *changed*, when MIDACO finishes (ISTOP=1).
%               
%     ACC :     Accuracy for the constraint violation (=Residual). An iterate is assumed feasible,
%               if the L-infinity norm (maximum violation) over 'G' is lower or equal to 'ACC'. 
%               Hint: For a first optimization run the 'ACC' accuracy should be selected not too small.
%               A value of 0.01 to 0.001 is recommended. If a higher accuracy is demanded,
%               a refinement of the solution regarding the constraint violations is recommended
%               by applying another MIDACO run using the 'QSTART' option given by 'PARAM(2)'. 
%
%    IFAIL :    Communication flag used by MIDACO. Initially MIDACO must be called with IFAIL=0.
%               If MIDACO works correctly, IFAIL flags lower than 0 are used for internal communication.
%               If MIDACO stops (either by submitting ISTOP=1 or automatically using AUTOSTOP), an IFAIL
%               FLAG between 1 and 9 is returned as final message. If MIDACO detects some critical
%               problem setup, a *WARNING* message is returned by an IFAIL flag between 10 and 99. If
%               MIDACO detects an *ERROR* in the problem setup, an IFAIL flag between 100 and 999 is
%               returned and MIDACO stops. The individual IFAIL flags are as follows:
%
%               STOP - Flags:
%               -------------
%               IFAIL = 1 : Feasible solution,   MIDACO was stopped by the user submitting ISTOP=1
%               IFAIL = 2 : Infeasible solution, MIDACO was stopped by the user submitting ISTOP=1
%               IFAIL = 3 : Feasible solution,   MIDACO stopped automatically using 'AUTOSTOP' = PARAM(3)
%               IFAIL = 4 : Infeasible solution, MIDACO stopped automatically using 'AUTOSTOP' = PARAM(3)
%       
%               WARNING - Flags:
%               ----------------
%               IFAIL = 51 : Some X(i)  is greater/lower than +/- 1.0D+12 (try to avoid huge values!)
%               IFAIL = 52 : Some XL(i) is greater/lower than +/- 1.0D+12 (try to avoid huge values!)
%               IFAIL = 53 : Some XU(i) is greater/lower than +/- 1.0D+12 (try to avoid huge values!)
%
%               IFAIL = 61 : Some X(i)  should be discrete (e.g. 1.000) , but is continuous (e.g. 1.234)
%               IFAIL = 62 : Some XL(i) should be discrete (e.g. 1.000) , but is continuous (e.g. 1.234)
%               IFAIL = 63 : Some XU(i) should be discrete (e.g. 1.000) , but is continuous (e.g. 1.234)
%
%               IFAIL = 71 : Some XL(i) = XU(I) (fixed variable)
%
%               IFAIL = 81 : F(X) has value NaN for starting point X (sure your problem is correct?)
%               IFAIL = 82 : Some G(X) has value NaN for starting point X (sure your problem is correct?)
%
%               ERROR - Flags:
%               --------------
%               IFAIL = 101 :   L    <= 0
%               IFAIL = 102 :   N    <= 0
%               IFAIL = 103 :   NINT <  0
%               IFAIL = 104 :   NINT >  N
%               IFAIL = 105 :   M    <  0
%               IFAIL = 106 :   ME   <  0
%               IFAIL = 107 :   ME   >  M
%
%               IFAIL = 201 :   some X(i)  has type NaN
%               IFAIL = 202 :   some XL(i) has type NaN
%               IFAIL = 203 :   some XU(i) has type NaN
%               IFAIL = 204 :   some X(i) < XL(i)
%               IFAIL = 205 :   some X(i) > XU(i)
%               IFAIL = 206 :   some XL(i) > XU(i)
%           
%               IFAIL = 301 :   ACC < 0 or ACC has type NaN
%               IFAIL = 302 :   PARAM(1) < 0
%               IFAIL = 303 :   PARAM(2) < 0 or ( 0 < PARAM(2) < 1 )
%               IFAIL = 304 :   PARAM(3) < 0
%               IFAIL = 305 :   PARAM(5) < 0
%               IFAIL = 306 :   PARAM(6) < 0 or ( 0 < PARAM(6) < 2 )
%               IFAIL = 307 :   PARAM(6) >= PARAM(5)
%               IFAIL = 308 :   PARAM(5) > 0 and PARAM(6) = 0
%               IFAIL = 309 :   PARAM(6) > 2*N+10
%               IFAIL = 310 :   PARAM(7) < 0 or PARAM(7) > 3
%               IFAIL = 311 :   some PARAM(i) has type NaN
%
%               IFAIL = 401 :   ISTOP < 0 or ISTOP > 1
%               IFAIL = 501 :   Double precision work space size LRW is too small (see below LRW)
%                               ---> RW must be at least of size LRW = 2*N^2+23*N+2*M+70
%               IFAIL = 601 :   Integer work space size LIW is too small (see below LIW)
%                               ---> IW must be at least of size LIW = 2*N+L+100
%               IFAIL = 701 :   Input check failed! MIDACO must be called initially with IFAIL = 0
%               IFAIL = 801 :   L > LMAX (user must specifiy LMAX below in the MIDACO source code) 
%               IFAIL = 802 :   L*M+1 > LXM (user must specifiy LXM below in the MIDACO source code)
%
%               IFAIL = 900 :   Invalid or corrupted LICENSE_KEY
%
%               IFAIL = 999 :   N > 4. The free test version is limited up to 4 variables. 
%                               To get an unlimited version, please contact info@midaco-solver.com.
%
%    ISTOP :    Communication flag to stop MIDACO by the user. If MIDACO is called with ISTOP = 1, MIDACO 
%               returns the best found solution in 'X' with corresponding 'F' and 'G'. As long as MIDACO 
%               should continue its search, ISTOP must be equal to 0.
%
%    PARAM() :  Array containing 7 parameters that can be selected by the user to adjust MIDACO. However, 
%               setting those parameters is *ONLY RECOMMENDED FOR ADVANCED USERS*. Unexperienced users 
%               should set all PARAM(i) = 0. The parameters are as follows:
%
%               PARAM(1) :   [RANDOM-SEED] This value indicates the random seed used within MIDACO's
%                            internal pseudo-random number generator. For each seed, a different sequence
%                            of pseudo-random numbers in generated, influencing the MIDACO results. The seed
%                            must be a (discrete) value >= 0 given in double precision. For example 
%                            PARAM(1) = 0.0, 1.0, 2.0,... (Note that MIDACO runs are 100% reproducable 
%                            for the same random seed used).
%
%               PARAM(2) :   [QSTART] This value indicates the quality of the starting point 'X' submitted by
%                            the user at the first call of MIDACO. It must be a (discrete) value >= 0
%                            given in double precision, where PARAM(2) = 0.0 is the default setting assuming 
%                            that the starting point is just some random point without specific quality. A higher 
%                            value indicates a higher quality of the solution. If PARAM(2) >= 1.0 is selected, 
%                            MIDACO will concentrate its search around the startingpoint by sampling its initial 
%                            population in the area (XU(i)-XL(i))/PARAM(2) in all continuous dimensions 'i' respectively.
%                            For discrete dimensions 'i', the initial sampling is performed with MAX((XU(i)-XL(i))/PARAM(2),
%                            1/SQRT(PARAM(2))) around the starting point.
%                            Note that activating PARAM(2) will *NOT* shrink the search space defined by 'XL' and 
%                            'XU', but only concentrates the population around the startingpoint and later the
%                            current best solution found. The QSTART option is very useful to refine a previously 
%                            calculated solution and/or to increase the accuracy of the constraint violation. For 
%                            continuous large scale problems (N > 100), the QSTART option is also very helpful to 
%                            refine the solution precision.
%                            
%               PARAM(3) :   [AUTOSTOP] This value enables an automatic stopping criteria within MIDACO. It must
%                            be a (discrete) value >= 0 given in double precision. For example PARAM(3) = 1.0, 
%                            2.0, 3.0,... If PARAM(3) is >= 1.0 MIDACO will stop and return its current
%                            best solution after PARAM(3) internal restarts without significant improvement of the 
%                            current solution. Hence, a small value for PARAM(3) will lead to a shorter runtime of
%                            MIDACO with a lower chance of reaching the global optimal solution. A large value of
%                            PARAM(3) will lead to a longer runtime of MIDACO but increases the chances of reaching
%                            the global optimum. Note that running MIDACO with PARAM(3) = 0.0 with a maximal 
%                            available time budget (e.g. 1 Day = 60*60*24 sec) will always provide the highest 
%                            chance of global optimality.
%
%               PARAM(4) :   [ORACLE] This parameter affects only constrained problems. If PARAM(4)=0.0 is submitted 
%                            MIDACO will use its inbuild oracle strategy. If PARAM(4) is not equal to 0.0, MIDACO 
%                            will use PARAM(4) as initial oracle for its oracle penalty function and only update the
%                            oracle, if a feasible solution with 'F(X)' < 'PARAM(4)' has been found. In case the user 
%                            wants to submit the specific ORACLE = 0.0, a close value like 1.0D-12 can be used as 
%                            dummy. Please review [2] to receive more information on the oracle penalty method. 
%
%               PARAM(5) :   [ANTS] This value fixes the number of iterates (ants) used within a generation. If
%                            PARAM(5)=0.0 is submitted, MIDACO will handle the number of iterates dynamically
%                            by itself. The use of PARAM(5) and PARAM(6) is usefull for either very cpu-time 
%                            expensive problems or large scale problems ('N' > 100). Please contact the author 
%                            directly to receive support in using this option.
%          
%               PARAM(6) :   [KERNEL] This value fixes the kernel size for each generation. If PARAM(6)=0.0 is 
%                            submitted, MIDACO will handle the kernel sizes dynamically by itself. IF PARAM(6) is
%                            not equal 0.0, it must be at least 2.0. 
%
%               PARAM(7) :   [CHARACTER] MIDACO includes three different parameter settings especially tuned for
%                            IP/NLP/MINLP problems. If PARAM(7) = 0.0 MIDACO will select its parameter set 
%                            according to the balance of 'N' and 'NINT'. If the user wishes to enable a specific
%                            set (for example the NLP set if 'N'=98 and 'NINT'=2) he can do so by PARAM(7):
%
%                            PARAM(7) = 1.0 enables the internal parameter set tuned for IP problems ('N'='NINT')
%                            PARAM(7) = 2.0 enables the internal parameter set tuned for NLP problems ('NINT'=0)
%                            PARAM(7) = 3.0 enables the internal parameter set tuned for MINLP problems
%
%    RW(LRW) :  Real workarray (double precision) of length 'LRW'
%    LRW :      Length of 'RW'. 'LRW' must be greater or equal to  2*N^2+23*N+2*M+70
%
%    IW(LIW) :  Integer workarray (long integer) of length 'LIW'
%    LIW :      Length of 'IW'. 'LIW' must be greater or equal to  2*N+L+100
%
%    LICENSE_KEY :  Character string consisting of 60 ASCII letters. Please note that any licensed copy  
%                   of MIDACO comes with an individual 'LICENSE_KEY' determining the license owner and
%                   additional license conditions.
%
%
%   References:
%    -----------
%
%    [1] Schlueter, M., Egea, J. A., Banga, J. R.: 
%       "Extended ant colony optimization for non-convex mixed integer nonlinear programming", 
%        Computers & Operations Research, Vol. 36 , Issue 7, Page 2217-2229, 2009.
%
%    [2] Schlueter M., Gerdts M.: "The oracle penalty method",
%        Journal of Global Optimization, Vol. 47(2),pp 293-325, 2010.
%
%
%    Author (C) :   Martin Schlueter
%                   Theoretical & Computational Optimization Group,
%                   School of Mathematics, University of Birmingham,
%                   Watson Building, Birmingham B15 2TT (UK)
%
%    URL :          http://www.midaco-solver.com
%
%    Email :        info@midaco-solver.com
%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ solution ] = midaco( problem, option, license )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = option.parallel;
if(L <= 1)
    if( L < 1)
        L = 1;
    end
else
    fprintf('\n %s%i%s\n\n','*** MIDACO Parallelization Factor L = ',L,' ***');
    matlabpool close force local
    matlabpool
    fprintf('\n\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n    = problem.n;
nint = problem.nint;
m    = problem.m;
me   = problem.me;
xl   = problem.xl;
xu   = problem.xu;
x0   = problem.x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxeval     = option.maxeval;
maxtime     = option.maxtime;
acc         = option.acc;
param       = option.param;
printeval   = option.printeval;
savescreen  = option.savescreen;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ifail  = 0;
istop  = 0;
eval   = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fff = zeros(1,L);
ggg = zeros(1,L*m);
xxx = zeros(1,L*n);
for c = 1:L
    for i = 1:n
        xxx((c-1)*n+i) = x0(i);
    end
end
x = zeros(1,n);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(printeval > 0)
    fprintf('\n%s\n',' MIDACO 3.0   (www.midaco-solver.com)');
    fprintf('%s\n\n',' ------------------------------------');
    fprintf('%s%s\n\n',' LICENSE-KEY:  ',license);
    fprintf('%s\n',' ------------------------------------');
    fprintf('%s%8i%s%17.9f%s\n',' | N',n,' | ACC',acc,' |');
    fprintf('%s%5i%s%13i%s\n',' | NINT',nint,' | MAXEVAL',maxeval,' |');
    fprintf('%s%8i%s%13.1f%s\n',' | M',m,' | MAXTIME',maxtime,' |');
    fprintf('%s%7i%s%11i%s\n',' | ME',me,' | PRINTEVAL',printeval,' |');
    fprintf('%s\n',' |----------------------------------|');
    dummy = 0;
    for i=1:7
        dummy = dummy + param(i);
    end
    if(dummy==0)
        fprintf('%s\n',' | PARAMETER:  All by default (0)   |');
    else
        fprintf('%s%10.1f%s\n',' | PARAM(1)',param(1),' (RANDOM-SEED) |');
        fprintf('%s%10.1f%s\n',' | PARAM(2)',param(2),' (QSTART)      |');
        fprintf('%s%10.1f%s\n',' | PARAM(3)',param(3),' (AUTOSTOP)    |');
        fprintf('%s%10.1f%s\n',' | PARAM(4)',param(4),' (ORACLE)      |');
        fprintf('%s%10.1f%s\n',' | PARAM(5)',param(5),' (ANTS)        |');
        fprintf('%s%10.1f%s\n',' | PARAM(6)',param(6),' (KERNEL)      |');
        fprintf('%s%10.1f%s\n',' | PARAM(7)',param(7),' (CHARACTER)   |');
    end
    fprintf('%s\n\n',' ------------------------------------');
    fprintf('%s%s%s \n',' LOWER BOUNDS:  XL = [ ',num2str(xl,' %16.10f'),'];');
    fprintf('%s%s%s \n',' UPPER BOUNDS:  XU = [ ',num2str(xu,' %16.10f'),'];');
    fprintf('%s%s%s \n\n\n',' STARTING POINT: X = [ ',num2str(x0,' %16.10f'),'];');
    fprintf('%s\n',' [    EVAL,   TIME]     OBJECTIVE FUNCTION VALUE     RESIDUAL VALUE    |   SOLUTION VECTOR');
    fprintf('%s\n',' ----------------------------------------------------------------------|------------------');
end
if((printeval > 0)&&(savescreen > 0))
    iout = fopen('MIDACO_SCREEN.RTF','w+');
    fprintf(iout,'\n%s\n',' MIDACO 3.0   (www.midaco-solver.com)');
    fprintf(iout,'%s\n\n',' ------------------------------------');
    fprintf(iout,'%s%s\n\n',' LICENSE-KEY:  ',license);
    fprintf(iout,'%s\n',' ------------------------------------');
    fprintf(iout,'%s%8i%s%17.9f%s\n',' | N',n,' | ACC',acc,' |');
    fprintf(iout,'%s%5i%s%13i%s\n',' | NINT',nint,' | MAXEVAL',maxeval,' |');
    fprintf(iout,'%s%8i%s%13.1f%s\n',' | M',m,' | MAXTIME',maxtime,' |');
    fprintf(iout,'%s%7i%s%11i%s\n',' | ME',me,' | PRINTEVAL',printeval,' |');
    fprintf(iout,'%s\n',' |----------------------------------|');
    dummy = 0;
    for i=1:7
        dummy = dummy + param(i);
    end
    if(dummy==0)
        fprintf(iout,'%s\n',' | PARAMETER:  All by default (0)   |');
    else
        fprintf(iout,'%s%10.1f%s\n',' | PARAM(1)',param(1),' (RANDOM-SEED) |');
        fprintf(iout,'%s%10.1f%s\n',' | PARAM(2)',param(2),' (QSTART)      |');
        fprintf(iout,'%s%10.1f%s\n',' | PARAM(3)',param(3),' (AUTOSTOP)    |');
        fprintf(iout,'%s%10.1f%s\n',' | PARAM(4)',param(4),' (ORACLE)      |');
        fprintf(iout,'%s%10.1f%s\n',' | PARAM(5)',param(5),' (ANTS)        |');
        fprintf(iout,'%s%10.1f%s\n',' | PARAM(6)',param(6),' (KERNEL)      |');
        fprintf(iout,'%s%10.1f%s\n',' | PARAM(7)',param(7),' (CHARACTER)   |');
    end
    fprintf(iout,'%s\n\n',' ------------------------------------');
    fprintf(iout,'%s%s%s \n',' LOWER BOUNDS:  XL = [ ',num2str(xl,' %16.10f'),'];');
    fprintf(iout,'%s%s%s \n',' UPPER BOUNDS:  XU = [ ',num2str(xu,' %16.10f'),'];');
    fprintf(iout,'%s%s%s \n\n\n',' STARTING POINT: X = [ ',num2str(x0,' %16.10f'),'];');
    fprintf(iout,'%s\n',' [    EVAL,   TIME]     OBJECTIVE FUNCTION VALUE     RESIDUAL VALUE    |   SOLUTION VECTOR');
    fprintf(iout,'%s\n',' ----------------------------------------------------------------------|------------------');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic; % Start the clock
%~~~~~~~~~~~~~~~~~~~~~start~of~reverse~communication~loop~~~~~~~~~~~~~~~~~~
while(istop == 0)
    
    if( L == 1)
        %................................................................
        x = xxx(1:n);     % Get X out of XXX
        
        [f,g] = problem.func(x);          % Evaluate objective function
        eval = eval + 1;                  % Count evaluation
        
        fff(1)   = f;     % Store F in FFF
        ggg(1:m) = g;     % Store G in GGG
        %..................................................................
    else
        %..................................................................
        % Execute 'L' problem function evaluation in parallel
        [fff,ggg] = execute_objective_in_parallel_(L,xxx,n,m,problem);
        eval = eval + L; % count evaluation
        %..................................................................
    end
    
    % Check stopping criteria
    if(eval >= maxeval)
        istop = 1;
    end
    if(toc >= maxtime)
        istop = 1;
    end
    
    %
    %   CALL MIDACO VIA MEX GATEWAY
    %
    [L,n,nint,m,me,xxx,fff,ggg,xl,xu,acc,ifail,istop,param,pf,pr,px,pc] = ...
        midacox(L,n,nint,m,me,xxx,fff,ggg,xl,xu,acc,ifail,istop,param,printeval,license);
    
    if(ifail >= 10)
        if(ifail < 100)
            fprintf('\n  **** MIDACO-WARNING: IFAIL =%5i ****\n\n',ifail);
        else
            fprintf('\n  **** MIDACO-ERROR: IFAIL =%5i ****\n\n',ifail);
            istop=2;
            pc = 0;
        end
    end
    
    % Print current best solution after every *PRINTEVAL* evaluation
    if(pc > 0)
        fprintf(' %s%8i%s%7.1f%s%18.8f%s%5.3E%s%s%s \n',...
            '[',eval,',',toc,']     F(X): ',pf,'     RES: ',pr,'   |   X = [ ',num2str(px(1:n),' %16.10f'),'];');
        if(savescreen > 0)
            fprintf(iout,' %s%8i%s%7.1f%s%18.8f%s%5.3E%s%s%s \n',...
                '[',eval,',',toc,']     F(X): ',pf,'     RES: ',pr,'   |   X = [ ',num2str(px(1:n),' %16.10f'),'];');
        end
    end    
end
%~~~~~~~~~~~~~~~~~~~~~end~of~reverse~communication~loop~~~~~~~~~~~~~~~~~~~~

% Return solution
solution.x     = xxx(1:n);
solution.f     = fff(1);
solution.g     = ggg(1:m);
solution.eval  = eval;
solution.time  = toc;
solution.ifail = ifail;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Independent test of solution given by MIDACO     %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ f, g] = problem.func( solution.x );

fprintf('\n INDEPENDENT TEST OF SOLUTION GIVEN BY MIDACO');
fprintf('\n --------------------------------------------');
fprintf('\n [EVAL:%10i, TIME:%8.2f, IFAIL:%4i]',solution.eval,solution.time,solution.ifail);
fprintf('\n --------------------------------------------');
fprintf('\n f(x)    = %34.18f',f);
if(problem.m > 0)
    fprintf('\n --------------------------------------------');
    if(problem.me > 0)
        for i = 1:problem.me;
            if(abs(g(i)) <= acc)
                fprintf('\n g(%4i) = %15.9f  (equality constr)',i,g(i));
            else
                fprintf('\n g(%4i) = %15.9f  (equality constr) <- infeasible',i,g(i));
            end
        end
    end
    for i = problem.me+1:problem.m;
        if(g(i) >= -acc)
            fprintf('\n g(%4i) = %15.9f  (in-equal constr)',i,g(i));
        else
            fprintf('\n g(%4i) = %15.9f  (in-equal constr) <- infeasible',i,g(i));
        end
    end
end
fprintf('\n --------------------------------------------     ---BOUNDS-PROFILER---');
for i = 1:problem.n;
    if(xl(i) ==  0); fprintf('\n x(%4i) = %33.18f;   %% XL___________________',i,solution.x(i)); end
    if(xl(i) ==  1); fprintf('\n x(%4i) = %33.18f;   %% x____________________',i,solution.x(i)); end
    if(xl(i) ==  2); fprintf('\n x(%4i) = %33.18f;   %% _x___________________',i,solution.x(i)); end
    if(xl(i) ==  3); fprintf('\n x(%4i) = %33.18f;   %% __x__________________',i,solution.x(i)); end
    if(xl(i) ==  4); fprintf('\n x(%4i) = %33.18f;   %% ___x_________________',i,solution.x(i)); end
    if(xl(i) ==  5); fprintf('\n x(%4i) = %33.18f;   %% ____x________________',i,solution.x(i)); end
    if(xl(i) ==  6); fprintf('\n x(%4i) = %33.18f;   %% _____x_______________',i,solution.x(i)); end
    if(xl(i) ==  7); fprintf('\n x(%4i) = %33.18f;   %% ______x______________',i,solution.x(i)); end
    if(xl(i) ==  8); fprintf('\n x(%4i) = %33.18f;   %% _______x_____________',i,solution.x(i)); end
    if(xl(i) ==  9); fprintf('\n x(%4i) = %33.18f;   %% ________x____________',i,solution.x(i)); end
    if(xl(i) == 10); fprintf('\n x(%4i) = %33.18f;   %% _________x___________',i,solution.x(i)); end
    if(xl(i) == 11); fprintf('\n x(%4i) = %33.18f;   %% __________x__________',i,solution.x(i)); end
    if(xl(i) == 12); fprintf('\n x(%4i) = %33.18f;   %% ___________x_________',i,solution.x(i)); end
    if(xl(i) == 13); fprintf('\n x(%4i) = %33.18f;   %% ____________x________',i,solution.x(i)); end
    if(xl(i) == 14); fprintf('\n x(%4i) = %33.18f;   %% _____________x_______',i,solution.x(i)); end
    if(xl(i) == 15); fprintf('\n x(%4i) = %33.18f;   %% ______________x______',i,solution.x(i)); end
    if(xl(i) == 16); fprintf('\n x(%4i) = %33.18f;   %% _______________x_____',i,solution.x(i)); end
    if(xl(i) == 17); fprintf('\n x(%4i) = %33.18f;   %% ________________x____',i,solution.x(i)); end
    if(xl(i) == 18); fprintf('\n x(%4i) = %33.18f;   %% _________________x___',i,solution.x(i)); end
    if(xl(i) == 19); fprintf('\n x(%4i) = %33.18f;   %% __________________x__',i,solution.x(i)); end
    if(xl(i) == 20); fprintf('\n x(%4i) = %33.18f;   %% ___________________x_',i,solution.x(i)); end
    if(xl(i) == 21); fprintf('\n x(%4i) = %33.18f;   %% ____________________x',i,solution.x(i)); end
    if(xl(i) == 22); fprintf('\n x(%4i) = %33.18f;   %% ___________________XU',i,solution.x(i)); end
    if(xl(i) == 90); fprintf('\n x(%4i) = %33.18f;   %% WARNING: XL = XU     ',i,solution.x(i)); end
    if(xl(i) == 91); fprintf('\n x(%4i) = %33.18f; ***ERROR*** (X > XU)    ',i,solution.x(i)); end
    if(xl(i) == 92); fprintf('\n x(%4i) = %33.18f; ***ERROR*** (X < XL)    ',i,solution.x(i)); end
    if(xl(i) == 93); fprintf('\n x(%4i) = %33.18f; ***ERROR*** (XL > XU)   ',i,solution.x(i)); end
end

if(savescreen > 0)
    fprintf(iout,'\n INDEPENDENT TEST OF SOLUTION GIVEN BY MIDACO');
    fprintf(iout,'\n --------------------------------------------');
    fprintf(iout,'\n [EVAL:%10i, TIME:%8.2f, IFAIL:%4i]',solution.eval,solution.time,solution.ifail);
    fprintf(iout,'\n --------------------------------------------');
    fprintf(iout,'\n f(x)    = %34.18f',f);
    if(problem.m > 0)
        fprintf(iout,'\n --------------------------------------------');
        if(problem.me > 0)
            for i = 1:problem.me;
                if(abs(g(i)) <= acc)
                    fprintf(iout,'\n g(%4i) = %15.9f  (equality constr)',i,g(i));
                else
                    fprintf(iout,'\n g(%4i) = %15.9f  (equality constr) <- infeasible',i,g(i));
                end
            end
        end
        for i = problem.me+1:problem.m;
            if(g(i) >= -acc)
                fprintf(iout,'\n g(%4i) = %15.9f  (in-equal constr)',i,g(i));
            else
                fprintf(iout,'\n g(%4i) = %15.9f  (in-equal constr) <- infeasible',i,g(i));
            end
        end
    end
    fprintf(iout,'\n --------------------------------------------     ---BOUNDS-PROFILER---');
    for i = 1:problem.n;
        if(xl(i) ==  0); fprintf(iout,'\n x(%4i) = %33.18f;   %% XL___________________',i,solution.x(i)); end
        if(xl(i) ==  1); fprintf(iout,'\n x(%4i) = %33.18f;   %% x____________________',i,solution.x(i)); end
        if(xl(i) ==  2); fprintf(iout,'\n x(%4i) = %33.18f;   %% _x___________________',i,solution.x(i)); end
        if(xl(i) ==  3); fprintf(iout,'\n x(%4i) = %33.18f;   %% __x__________________',i,solution.x(i)); end
        if(xl(i) ==  4); fprintf(iout,'\n x(%4i) = %33.18f;   %% ___x_________________',i,solution.x(i)); end
        if(xl(i) ==  5); fprintf(iout,'\n x(%4i) = %33.18f;   %% ____x________________',i,solution.x(i)); end
        if(xl(i) ==  6); fprintf(iout,'\n x(%4i) = %33.18f;   %% _____x_______________',i,solution.x(i)); end
        if(xl(i) ==  7); fprintf(iout,'\n x(%4i) = %33.18f;   %% ______x______________',i,solution.x(i)); end
        if(xl(i) ==  8); fprintf(iout,'\n x(%4i) = %33.18f;   %% _______x_____________',i,solution.x(i)); end
        if(xl(i) ==  9); fprintf(iout,'\n x(%4i) = %33.18f;   %% ________x____________',i,solution.x(i)); end
        if(xl(i) == 10); fprintf(iout,'\n x(%4i) = %33.18f;   %% _________x___________',i,solution.x(i)); end
        if(xl(i) == 11); fprintf(iout,'\n x(%4i) = %33.18f;   %% __________x__________',i,solution.x(i)); end
        if(xl(i) == 12); fprintf(iout,'\n x(%4i) = %33.18f;   %% ___________x_________',i,solution.x(i)); end
        if(xl(i) == 13); fprintf(iout,'\n x(%4i) = %33.18f;   %% ____________x________',i,solution.x(i)); end
        if(xl(i) == 14); fprintf(iout,'\n x(%4i) = %33.18f;   %% _____________x_______',i,solution.x(i)); end
        if(xl(i) == 15); fprintf(iout,'\n x(%4i) = %33.18f;   %% ______________x______',i,solution.x(i)); end
        if(xl(i) == 16); fprintf(iout,'\n x(%4i) = %33.18f;   %% _______________x_____',i,solution.x(i)); end
        if(xl(i) == 17); fprintf(iout,'\n x(%4i) = %33.18f;   %% ________________x____',i,solution.x(i)); end
        if(xl(i) == 18); fprintf(iout,'\n x(%4i) = %33.18f;   %% _________________x___',i,solution.x(i)); end
        if(xl(i) == 19); fprintf(iout,'\n x(%4i) = %33.18f;   %% __________________x__',i,solution.x(i)); end
        if(xl(i) == 20); fprintf(iout,'\n x(%4i) = %33.18f;   %% ___________________x_',i,solution.x(i)); end
        if(xl(i) == 21); fprintf(iout,'\n x(%4i) = %33.18f;   %% ____________________x',i,solution.x(i)); end
        if(xl(i) == 22); fprintf(iout,'\n x(%4i) = %33.18f;   %% ___________________XU',i,solution.x(i)); end
        if(xl(i) == 90); fprintf(iout,'\n x(%4i) = %33.18f;   %% WARNING: XL = XU     ',i,solution.x(i)); end
        if(xl(i) == 91); fprintf(iout,'\n x(%4i) = %33.18f; ***ERROR*** (X > XU)    ',i,solution.x(i)); end
        if(xl(i) == 92); fprintf(iout,'\n x(%4i) = %33.18f; ***ERROR*** (X < XL)    ',i,solution.x(i)); end
        if(xl(i) == 93); fprintf(iout,'\n x(%4i) = %33.18f; ***ERROR*** (XL > XU)   ',i,solution.x(i)); end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save MIDACO solution to *.mat file
save  MIDACO_solution.mat  solution;
fprintf('\n\n(MIDACO_solution.mat saved in the current directory) \n\n');
if(savescreen > 0)
    fprintf(iout,'\n\n(MIDACO_solution.mat saved in the current directory) \n\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return
% End of MIDACO - MATLAB Gateway





% This function handles the parallelization of objective function calls
function [fff,ggg] = execute_objective_in_parallel_(L,xxx,n,m,problem)

problemfunc = @problem.func;

fff = zeros(1,L);
ggg = zeros(1,L*m+1);

A = cell(L,1);
B = cell(L,m);
C = cell(L,n);

clear A;
clear B;
clear C;

for c=1:L
    for i=1:n
        C{c}{i} = xxx( (c-1)*n+i );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is all the parallelization !!! %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor c = 1:L                        %
    x = zeros(1,n);                   %
    for i=1:n                         %
        x(i) = C{c}{i};               %
    end                               %
    [ f , g ] = problemfunc( x );     %
    A{c}{1} = f;                      %
    for j=1:m                         %
        B{c}{j} = g(j);               %
    end                               %
end                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for c=1:L
    fff(c) = A{c}{1};
    for j=1:m
        ggg( (c-1)*m+j ) = B{c}{j};
    end
end

return



