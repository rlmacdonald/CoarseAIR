function [V, dV] = CH_UIUC(R)

% CH Min @ ... (V=...)
  
  PolOrd = 20; %13
  re     = 1.301179737758152; %1.498759159484161;
  Beta   = 1.044155249442320; %1.765060790703594;
  %cPol   = [                    0.0,    -10.967923614494632,      9.171290419774330, ...
  %               84.926926069836611, -5.266424460481485e+02,  2.105861087985694e+03, ...
  %           -5.852638135720086e+03,  1.135989113111362e+04, -1.551695055156492e+04, ...
  %            1.485128912891180e+04, -9.734270376724013e+03,  4.155869579591927e+03, ...
  %           -1.040395709763808e+03, 1.158793751685088e+02];
  cPol   = [0;0.00379971564237380;-0.953712712168401;-3.59328529208477;37.8323517379414;-124.786301375258;226.722421321307;-218.909452090161;48.2886301126978;107.010402227210;-68.7353658518817;-29.4476842865390;-9.83386396216202;79.7356679254129;-3.82511534297961;-132.925148097350;165.220696460728;-100.141985282533;34.5002667646521;-6.50481292023681;0.524699734678209];

  % 0.0 + a1*exp(b1*(x-r1)) + a2*(exp(b1*(x-r1)))^2 + a3*(exp(b1*(x-r1)))^3 + a4*(exp(b1*(x-r1)))^4  + a5*(exp(b1*(x-r1)))^5 + a6*(exp(b1*(x-r1)))^6 + a7*(exp(b1*(x-r1)))^7 + a8*(exp(b1*(x-r1)))^8 + a9*(exp(b1*(x-r1)))^9 + a10*(exp(b1*(x-r1)))^10 + a11*(exp(b1*(x-r1)))^11 + a12*(exp(b1*(x-r1)))^12 + a13*(exp(b1*(x-r1)))^13 + a14*(exp(b1*(x-r1)))^14 + a15*(exp(b1*(x-r1)))^15 + a16*(exp(b1*(x-r1)))^16 + a17*(exp(b1*(x-r1)))^17 + a18*(exp(b1*(x-r1)))^18 + a19*(exp(b1*(x-r1)))^19 + a20*(exp(b1*(x-r1)))^20
  %p = [0.0 Diat_Fit.a1 Diat_Fit.a2 Diat_Fit.a3 Diat_Fit.a4 Diat_Fit.a5 Diat_Fit.a6 Diat_Fit.a7 Diat_Fit.a8 Diat_Fit.a9 Diat_Fit.a10, ...
  %      Diat_Fit.a11 Diat_Fit.a12 Diat_Fit.a13 Diat_Fit.a14 Diat_Fit.a15 Diat_Fit.a16 Diat_Fit.a17 Diat_Fit.a18 Diat_Fit.a19 Diat_Fit.a20]' ./ 27.2113839712790
  
  Xpnt = exp( - Beta .* (R - re) );
  V  = cPol(1);
  dV = cPol(2);
  for i=1:(PolOrd-1)
    V  = V  +         cPol(i+1) .* Xpnt.^i;
    dV = dV + (i+1) .* cPol(i+2) .* Xpnt.^i;
  end
  V  = V  + cPol(PolOrd+1) .* Xpnt.^PolOrd;
  dV = dV .* (- Beta .* Xpnt);
  
  V  = V  .* 27.2113839712790;
  dV = dV .* 27.2113839712790;
 
end

