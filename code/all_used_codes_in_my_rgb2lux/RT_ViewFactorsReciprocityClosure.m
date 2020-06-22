function [F,Fit] = RT_ViewFactorsReciprocityClosure(F,Fsp,A,imeth,tol,nbr)
%%
% Fonction pour assurer la reciprocite des facteurs de vue
%
%     Ai.Fij = Aj.Fij
%
% et la fermeture
%
%     somme_j Fij = 1 - Fspi
%
% Fsp contient le facteur de vue de chaque face vers l'espace. Dans un modele ferme
% et tourne vers l'interieur, Fsp doit etre nul sauf si on perd des rayons.
%
% On peut utiliser plusieurs methodes :
%
%     1- Van Leersum modifiee par bibi (on donne la precision tol souhaitee sur la
%        non-reciprocite des facteurs de vue),
%
%     2- LSOE (Least-Squares Optimal Enforcement) [cf. article Taylor & Luck].
%
%     3- LS (Zeeb) resolution systeme lineaire avec des multiplicateurs de Lagrange
%
%   Luc Masset (2009)

%% Function to ensure reciprocity of view factors
%
% Ai.Fij = Aj.Fij
%
% and closing
%
% sum_j Fij = 1 - Fspi
%
% Fsp contains the view factor of each face to the space. In a firm model
% and turns inward, Fsp must be zero unless you lose rays.
%
% You can use several methods:
%
% 1- Van Leersum modified by bibi (we give the desired precision tol on the
% non-reciprocity of view factors),
%
% 2- LSOE (Least-Squares Optimal Enforcement) [cf. article Taylor & Luck].
%
% 3- LS (Zeeb) linear system resolution with Lagrange multipliers
%
% Luc Masset (2009)

%taille
n=size(F,1);

%initialisation
Fit=cell(1,0);

%facteur de vue espace
if isempty(Fsp),
 Fsp=zeros(n,1);
end

%methode LSOE
if imeth == 2,
%facteurs de vue sous forme de vecteur
 f=reshape(F',n^2,1);
%matrice des contraintes
 R=zeros(n*(n+1)/2,n^2);
 for i=1:n,
  R(i,(i-1)*n+1:i*n)=1;
 end
 icount=n;
 for i=1:n,
  for j=i+1:n
   icount=icount+1;
   ii=(i-1)*n+j;
   jj=(j-1)*n+i;
   R(icount,ii)=A(i);
   R(icount,jj)=-A(j);
  end
 end
%second membre
 c=zeros(n*(n+1)/2,1);
 c(1:n)=1-Fsp;
% solution de norme minimum
 frow=R'*pinv(R*R')*c;    
%espace nul de la matrice R
 Nb=null(R);
%solution dans l'espace nul
 fnull=Nb*pinv(Nb'*Nb)*Nb'*(f-frow);
%solution moindres carres
 fopt=frow+fnull;
%remise sous forme de matrice
 F=reshape(fopt,n,n)';
 return
end

%methode LS
if imeth == 3,
 N=round(F*nbr);      % nombre de rayons tires de la face i et captes par face j
 AA=(A*ones(1,n));    % aire des faces
%estimateurs de reciprocite
 a=2*nbr;
 b=AA.*(N+nbr)+AA'.*(N'+nbr);
 c=AA.*AA'.*(N+N');
 delta=b.^2-4*a*c;
 eta=(b-sqrt(delta))/2/a;
%matrice des poids
 W=eta.^2.*(AA-eta).^2.*(AA'-eta).^2;
 den=eps + (N+N').*(AA-eta).^2.*(AA'-eta).^2 + (nbr-N).*eta.^2.*(AA'-eta).^2 + (nbr-N').*eta.^2.*(AA-eta).^2;
 W=W./den;
%systeme lineaire
 K=W;
 beta=zeros(n,1);
 for i=1:n,
  K(i,i)=sum(W(i,:));
  beta(i)=A(i)-sum(eta(i,:))-A(i)*Fsp(i);
 end
%multiplicateurs de Lagrange
 lambda=pinv(K)*beta;
%estimateurs de reciprocite modifies
 L=(lambda*ones(1,n));
 L=L+L';
 etap=eta+W.*L;
%facteurs de vue modifies
 F=etap./AA;
 return
end

%methode iterative de Van Leersum modifiee
a=2*nbr;
sF=1-Fsp;
nbiter=100;
Fit=cell(1,nbiter);

AF=(A*ones(1,n)).*F;
zut=abs(AF-AF')./(eps+AF+AF')*100;
err=max(zut(:));
fprintf(' Erreur (iteration 0) : %f %%\n',err);

evo=err;

for iter=1:nbiter,
 for i=1:n,
  Ai=A(i);
  for j=i+1:n,
   Aj=A(j);
   fij=F(i,j);
   fji=F(j,i);
   b=Ai*(fij*nbr+nbr)+Aj*(fji*nbr+nbr);
   c=Ai*Aj*nbr*(fij+fji);
   eta=(b-sqrt(b^2-4*a*c))/2/a;
   F(i,j)=eta/Ai;
   F(j,i)=eta/Aj;
%methode ponderee (aire,Nij)
%    fij=F(i,j);
%    fji=F(j,i);
%    asa=A(i)/A(j);
%    w1=fij/asa;
%    w2=asa*fji;
%    sw=eps+w1+w2;
%    w1=w1/sw;
%    w2=w2/sw;
%    fij=w1*fij+w2*fji/asa;
%    F(i,j)=fij;
%    F(j,i)=asa*fij;

%methode centree
%    delta=(A(i)*F(i,j)-A(j)*F(j,i))/2;
%    F(i,j)=(A(i)*F(i,j)-delta)/A(i);
%    F(j,i)=(A(j)*F(j,i)+delta)/A(j);
  end
 end
 for i=1:n,
  som=sum(F(i,:));
  fac=sF(i)/(eps+som);
  F(i,:)=fac*F(i,:);
 end
%  Fit{1,iter}=F;
 AF=(A*ones(1,n)).*F;
 zut=abs(AF-AF')./(eps+AF+AF')*100;
 err=max(zut(:));
 evo(end+1)=err;
 fprintf(' Erreur (iteration %i) : %f %%\n',iter,err);
 if err < tol,
  break;
 end
end
% Fit=Fit(1:iter);

return
