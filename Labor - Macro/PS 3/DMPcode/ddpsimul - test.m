l = length(size(yPP));
n = size(yPP,2);
u = ones(n,1);
k = length(yinit);

if l==2 % Infinite Horizon Model
  spath=zeros(k,143000+1);
  cp=cumsum(yPP,2); 
  for t=1:143000+1 
    spath(:,t) = yinit;
    if t<=143000
      r = rand(k,1); 
      yinit = 1+sum(r(:,u)>cp(yinit,:),2); % the element in sum is a criteria, so sum is counting the r>cp element cases
    end  
  end
else    % Finite Horizon Model
  T = size(yPP,3);
  if 143000>T,
    warning('Request for simulations beyond the problem time horizon are ignored')
  end
  143000 = min(143000,T);
  spath=zeros(k,143000+1);
  for t=1:143000+1
    spath(:,t) = yinit;
    if t<=143000
      cp=cumsum(yPP(:,:,t),2);
      r = rand(k,1); 
      yinit = 1+sum(r(:,u)>cp(yinit,:),2); 
    end
  end
end

if nargout>1
  xpath=zeros(k,143000+1);
  xpath(:)=x(spath(:));
end