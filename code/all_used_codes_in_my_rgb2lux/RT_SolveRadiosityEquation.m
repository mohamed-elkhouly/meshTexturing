function [R,H,Q] = RT_SolveRadiosityEquation(F,rho,E,imethod,K,rho_t,g_vec,itermax)
%
% Fonction pour resoudre un probleme de radiosite dont on donne :
%
%   F         la matrice des facteurs de vue entre les faces du modele
%   rho       vecteur contenant les reflectivites des faces
%   E         vecteur contenant les flux auto-emis par les faces
%   imethod   1=inversion,2=iterative,3=constrained
%
% On calcule les radiosites Ri des faces en resolvant le systeme
%
%   K.R = E
%
% avec
%
%   K     la matrice I - rho.F
%
%  Luc Masset (2011)
%  Theodore Tsesmelis (2017)

%arguments
if nargin < 7,
 itermax=30;
end

%tailles

%% dahy hashed this section 
% nbf=size(F,1);


% %matrice K
% if length(rho) == 1,
%  F=rho*F;
% else
% %  for i=1:nbf,
% %   F(i,:)=F(i,:)*rho(i);
% %  end
%  F = diag(rho)*F;
% end
% if issparse(F),
%  K=sparse(eye(nbf))-F;
% else
%  K=eye(nbf)-F;
% end

%%
%methode directe
% R = inv(eye(length(f4)) - diag(rho)*Fji)*E; % my method, theodore

if imethod == 1,
 R=K\E;
end

%methode iterative (much faster than method 1)
if imethod == 2,
 R=E;
 norme=0.001*norm(E);
 for i=1:itermax,
  res=E-K*R;
  nres=norm(res);
  fprintf('Iteration %i : residual: %f \n',i,nres);
  R=R+res;
  if nres < norme,
   break;
  end
 end
 
 
 
 
 
end

% method constrained direct

if imethod == 3,
 R = lsqlin(diag(rho_t), g_vec, [], [], K, E);
end

%flux radiatif incident
% H=(R-E)./rho; % original equation
% H = ((R-E)*pi)./rho; % add Lambertian assumption

H=((R-E)*pi);
for ii=1:length(H)
H(ii)=H(ii)/rho(ii);
end

%flux sortant
Q = R-H;

return