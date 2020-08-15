function [xxx,ifail,pf,px,pc] = LinkMIDACO(n,nint,m,me,xxx,fff,ggg,xl,xu,acc,ifail,istop,param,printeval)

L = 1;
license = 'Shen_Hongxin_(NatUniDefTech_China)__[ACADEMIC-SINGLE-MATLAB]';

[L,n,nint,m,me,xxx,fff,ggg,xl,xu,acc,ifail,istop,param,pf,pr,px,pc] = midacox(L,n,nint,m,me,xxx,fff,ggg,xl,xu,acc,ifail,istop,param,printeval,license);
    
end