function [fspace, glob] = GetFspace(glob,anum,ynum,amult,sol_flag,flag)

switch flag
case 'all'

% Ygrid
glob.ynum = ynum;
[glob.ygrid,glob.w] = rouwenhorst(glob.ro,glob.se,glob.ynum);        % Rouwenhorst method
glob.yPP        = glob.w;
glob.ygrid      = glob.ygrid' - .5 *((glob.se)^2)/(1-glob.ro.^2);
glob.ymin       = min(glob.ygrid);                                
glob.ymax       = max(glob.ygrid);                                
[V,D]           = eig(glob.yPP');
glob.dist       = V(:,1)./sum(V(:,1));
glob.expymean   = glob.dist'*exp(glob.ygrid);

            

glob.n=[anum,ynum]; % note, anum WILL change. when declared as 
                    % spline, anum'=anum+2

glob.mpl = GetTech(glob,'mpl');
glob.scale=0.5;

end 

% Agrid params
glob.amult = amult;
glob.amin =  0;                % no borrowing
glob.amax = glob.amult*glob.mpl*max(exp(glob.ygrid)); % guess an upper bound on a, check later that do not exceed it

% Declare grid bounds
glob.smin=[glob.amin,glob.ymin];
glob.smax=[glob.amax,glob.ymax];
fspace=fundef({'spli', nodeunif(glob.n(1),(glob.smin(1)-glob.amin+.01).^glob.scale,(glob.smax(1)-glob.amin+.01).^glob.scale).^(1/glob.scale)+glob.amin-.01,0,3},...
                            {'spli',glob.ygrid,0,1});

fspace.grid=funnode(fspace);
glob.s=gridmake(fspace.grid); % collection of  states
glob.ns=length(glob.s);
glob.agrid = fspace.grid{1}; % of size anum_in+2
glob.anum = length(glob.agrid);

fspace.sol = sol_flag;

% -----------------
% below: only necessary for "glob.slower = 1"
% -----------------

fspace.PhiAY=funbas(fspace,glob.s);

for ki=1:glob.ynum
  ypp = zeros(glob.ns,1);
  for j=1:glob.ynum
    ypp(1+(j-1)*glob.anum:j*glob.anum,1)=glob.yPP(j,ki);
  end
  kk = ki+zeros(glob.ns,1);
  fspace.PhiAYp(ki).phi= repmat(ypp,1,glob.ns) ...
    .* funbas(fspace,[glob.s(:,1), glob.ygrid(ki)*ones(glob.ns,1)]);
end

Yspace = fundef({'spli',glob.ygrid,0,1}); % don't need to store.
fspace.PhiY = funbas(Yspace,glob.s(:,2));

fspace.Aspace = fundef({'spli', ...
  nodeunif(glob.n(1),(glob.smin(1)-glob.amin+.01).^glob.scale, ...
  (glob.smax(1)-glob.amin+.01).^glob.scale).^(1/glob.scale)+glob.amin-.01,0,3});

% necessary for endogenous grid method
fspace.yPPbig = kron(glob.yPP,ones(glob.anum,1));
