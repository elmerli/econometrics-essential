function fval = euler_error(x,c,fspace,glob,flag,sfine)

switch flag

  case 'solve'

  f1 = feval('menufunc','f1',x,glob,[]);
  g1 = feval('menufunc','g1',x,glob,[]);

  if glob.slower ==1
    fval = f1 - funeval(c(:,2),fspace,g1);
  else
    PhiApY = dprod(fspace.PhiY,funbas(fspace.Aspace,g1));
    % note, above dprod is in reverse order!

    fval = f1 - PhiApY*c(:,2);
  end

  case 'sfine'

  f1 = feval('menufunc','f1',x,glob,[]);
  g1fine = feval('menufunc','g1fine',x,glob,sfine);
  
  fval = f1 - funeval(c(:,2),fspace,g1fine);

end
