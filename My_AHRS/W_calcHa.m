function H_a = W_calcHa(q0,q1,q2,q3)
%W_CALCHA
%    H_A = W_CALCHA(Q0,Q1,Q2,Q3)

%    This function was generated by the Symbolic Math Toolbox version 7.1.
%    04-Jan-2019 16:54:59

t2 = -q1.*2.0;
t3 = -q3.*2.0;
t4 = -q0.*2.0;
t5 = -q2.*2.0;
H_a = reshape([q2.*2.0,t2,t4,t3,t4,-t2,q0.*2.0,t3,-t5,t2,t5,t3,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],[3,7]);