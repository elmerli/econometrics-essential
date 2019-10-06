function [lambda, sfine, apfine, glob] = GetLambda(glob,fspace,c,nf)

afine = nodeunif(nf(1),(glob.smin(1)-glob.amin+.01).^glob.scale,(glob.smax(1)-glob.amin+.01).^glob.scale).^(1/glob.scale)+glob.amin-.01;
yfine = glob.ygrid;
sfine = gridmake(afine,yfine);

nfs=length(sfine);

xfine=real((funeval(c(:,1),fspace,sfine)).^(-1/glob.gamma));
apfine=glob.mpl*exp(sfine(:,2)) + (1+glob.r)*sfine(:,1) - xfine;
apfine(apfine<0)=0;

fspace_qmat = fundef({'spli',afine,0,1});
Q_ap = funbas(fspace_qmat,apfine);
Q_yp = kron(glob.yPP,ones(nf(1),1));
Qmat = dprod(Q_yp,Q_ap);

nlambda = ones(size(Qmat,1),1);
nlambda = nlambda/sum(nlambda);

for ii=1:100000
  nlambda0 = (Qmat'*nlambda)/norm(Qmat'*nlambda);
  dL      = norm(nlambda0-nlambda)/norm(nlambda);  
  nlambda = nlambda0;
  if (dL<1D-8), break, end;
end

lambda = nlambda./sum(nlambda);
%glob.HtM = sum(lambda.*(aploc==1));
glob.Ks  = sum(apfine.*lambda);

%disp('net change in asset positions')
glob.DeltaAssetPosition= sum(lambda.*(sfine(:,1)-apfine));

end

%old % preallocate
%old aploc  = zeros(length(apfine),1);
%old ap_row = zeros(length(apfine)*2,1);
%old ap_col = zeros(length(apfine)*2,1);
%old ap_val = zeros(length(apfine)*2,1);
%old 
%old jj = 0;
%old for ii=1:length(apfine)
%old 
%old   jj = jj+1; % what is jj?
%old   
%old   aploc(ii) = find(afine>=apfine(ii),1); % will go into column
%old   % find first entry where afine>=apfine
%old 
%old   if (aploc(ii)~=1), aploc(ii)=aploc(ii)-1;, ap_row(jj)=ii;, ap_col(jj)=aploc(ii);, end;
%old 
%old   if (abs(apfine(ii)-afine(aploc(ii)))>1D-8)
%old     ap_row(jj) = ii;
%old     ap_col(jj) = aploc(ii);
%old     ap_val(jj) = (afine(aploc(ii)+1)-apfine(ii))./...
%old       (afine(aploc(ii)+1)-afine(aploc(ii)));
%old     %
%old     jj=jj+1; % why this?
%old     %
%old     ap_row(jj) = ii;
%old     ap_col(jj) = aploc(ii)+1;
%old     ap_val(jj) = (apfine(ii)-afine(aploc(ii)))./...
%old       (afine(aploc(ii)+1)-afine(aploc(ii)));
%old   else %if
%old     ap_row(jj) = ii;
%old     ap_col(jj) = aploc(ii);
%old     ap_val(jj) = 1.0;
%old   end %if
%old end
%old 
%old ap_row = ap_row(1:jj); % truncate vector 
%old ap_col = ap_col(1:jj);
%old ap_val = ap_val(1:jj);
%old 
%old Q_ap = sparse(ap_row,ap_col,ap_val,nfs,nf(1));
%old 
%old % creates nfs-by-nf(1) sparse matrix Q,
%old % where Q(ap_row(k),ap_col(k))=ap_val(k)
%old % rows, `ii' above, denote where you are coming from.
%old % cols, `jj' above, denote whre you are going.
%old 
%old for ii=1:nf(2)
%old   ypfine((ii-1)*nf(1)+1:ii*nf(1),:) = repmat(glob.yPP(ii,:),nf(1),1);
%old end
%old 
%old ypfine(abs(ypfine)<1d-8) = 0;
%old [i_tmp,j_tmp,s_tmp] = find(ypfine);
%old [m_tmp,n_tmp] = size(ypfine);
%old Q_yp = sparse(i_tmp,j_tmp,s_tmp,m_tmp,n_tmp);
