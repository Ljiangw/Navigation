function F = W_calcF(dax,dax_b,day,day_b,daz,daz_b,q0,q1,q2,q3)
%W_CALCF
%    F = W_CALCF(DAX,DAX_B,DAY,DAY_B,DAZ,DAZ_B,Q0,Q1,Q2,Q3)

%    This function was generated by the Symbolic Math Toolbox version 7.1.
%    04-Jan-2019 16:54:00

t2 = dax_b.*(1.0./2.0);
t3 = daz_b.*(1.0./2.0);
t4 = day_b.*(1.0./2.0);
t8 = day.*(1.0./2.0);
t5 = t4-t8;
t6 = q3.*(1.0./2.0);
t7 = q2.*(1.0./2.0);
t9 = daz.*(1.0./2.0);
t10 = dax.*(1.0./2.0);
t11 = -t2+t10;
t12 = q1.*(1.0./2.0);
t13 = -t3+t9;
t14 = -t4+t8;
F = reshape([1.0,t11,t14,t13,0.0,0.0,0.0,dax.*(-1.0./2.0)+t2,1.0,t3-t9,t14,0.0,0.0,0.0,t5,t13,1.0,t2-t10,0.0,0.0,0.0,daz.*(-1.0./2.0)+t3,t5,t11,1.0,0.0,0.0,0.0,t12,q0.*(-1.0./2.0),-t6,t7,1.0,0.0,0.0,t7,t6,q0.*(-1.0./2.0),-t12,0.0,1.0,0.0,t6,-t7,t12,q0.*(-1.0./2.0),0.0,0.0,1.0],[7,7]);