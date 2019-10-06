function [x_opt] = neldmead_bounds(func,x_init,x_min,x_max)
% [x_opt]=neldmead_bounds(func,x_init,x_min,x_max)
%       minimizes f(x) such that  x_min <= x_opt <= x_max.  
%       modified version of original by  H.P. Gavin , Civil & Env'ntl Eng'g, Duke Univ.   21 January 2006 
%       all i did is to make it readable for myself and exclude g(x) <0
%       constraint
%
% INPUT
% ======
%  func    :   the name of the function to be minimizes in the form y=func(x)
%  x_init  :   the vector of initial parameter values ... a column vector
%  x_min   :   minimum permissible values of the parameters, x
%  x_max   :   maximum permissible values of the parameters, x
%
% OUTPUT
% ======
%  x_opt   :   a set of parameters at or near the optimal value


 tol_x    = 1e-5;         % tolerance for convergence in x
 tol_f    = 1e-5;         % tolerance for convergence in f
 max_iter = 300;         % maximum number of function evaluations
 

n = length(x_init);

onesn = ones(1,n); 
ot = 2:n+1;
on = 1:n;
function_count = 0;		% the number of function evaluations


% Nelder-Mead constants
a_reflect = 2;  a_expand = 1;  a_contract = 0.5; a_shrink = 0.5;

% Evaluate the initial guess and the range of allowable parameter variation

x_init = min(max(x_init,x_min),x_max);

[fv] = feval(func,x_init); 
if any(x_max == x_min)
   error('error: x_max can not equal x_min for any parameter');
end
   
% Place input guess in the simplex! (credit L.Pfeffer at Stanford)
% Set up a simplex near the initial guess.
p1=.4;   %originally .2
p2=.2;  %originally .1

delta_x = min( p1*(1+abs(x_init)) , p2*(x_max-x_init).*(x_max~=x_init) );
idx = find(delta_x == 0);
delta_x(idx) = -p2*(x_init(idx)-x_min(idx));

% --- initialization
simplex = x_init; 
for j = 1:n
    y = x_init;
    y(j) = y(j) + delta_x(j);
    x = min(max(y,x_min),x_max);
    simplex = [simplex x];   %create simplex one by one
    [f] = feval(func,x);     %evaluate function
    fv = [fv  f];            %record function values

end

% order the vertices in increasing order of fv
[fv,idx] = sort(fv); simplex = simplex(:,idx); 
%disp([simplex;fv]);

iter=1;
while iter < max_iter         % --- main loop

    change_x = max(max(abs(simplex(:,ot)-simplex(:,onesn))));
    change_f = max(abs(fv(1)-fv(ot)));

    if change_x < tol_x && change_f < tol_f
            break;
    end

    % One step of the Nelder-Mead simplex algorithm

    happy = 0;

% reflect
    vbar = (sum(simplex(:,on)')/n)';	% centroid of better vertices
    vr = min(max(vbar + a_reflect*(vbar-simplex(:,n+1)),x_min),x_max);
    [fr] = feval(func,vr); 
    
    
    if ( fr >= fv(1)  &&  fr < fv(n+1) )
          happy = 1;  vk = vr;  fk = fr;    how = 'reflect';
    end

% expand
    if ( happy == 0  &&  fr < fv(1) )
       ve = min(max(vbar + a_expand*(vr-vbar),x_min),x_max);
       [fe] = feval(func,ve); 
       
       function_count = function_count + 1;
       if fe < fr
          happy = 1;  vk = ve;  fk = fe;    how = 'expand';
       else
          happy = 1;  vk = vr;  fk = fr;    how = 'reflect';
       end
    end

% contract
    if ( happy == 0  &&  fr >= fv(n)  )
       vc = min(max(vbar + a_contract*(vbar-simplex(:,n+1)),x_min),x_max);
       [fc] = feval(func,vc); 
      
     
       if fc < fv(n+1)
          happy = 1;  vk = vc;  fk = fc;    how = 'contract';
       end
    end

% if you have accepted a new point, replace the worst point (n+1) with it

    if ( happy == 1 )
       simplex(:,n+1) = vk;  fv(n+1) = fk;   
    else

% shrink
       v1 = simplex(:,1);
       for i=2:n+1
           vs = min(max(v1 + a_shrink*(simplex(:,i)-v1),x_min),x_max);
           [fs] = feval(func,vs); 
          
	   simplex(:,i) = vs;
           fv(i) = fs;
       end
  
       how = 'shrink';
    end

% order the vertices in increasing order of fv
    [fv,idx] = sort(fv); simplex = simplex(:,idx); 
    x_opt = simplex(:,1);
 fprintf('%4i   %6.2e %6.2e\n',[iter,change_f,change_x])
 iter=iter+1;
end


