% Macro PS 3
% Content: 
	% getting data from fred
	% Value function iteration

    
url = 'https://fred.stlouisfed.org/';
c = fred(url);
% c = fred('https://research.stlouisfed.org/fred2/');
% c = fred(url);
series = 'DEXUSEU';
d = fetch(c,series); 
% close(c)

% URL = 'https://www.mathworks.com/matlabcentral/fileexchange';
% str = urlread(URL,'Get',{'term','urlread'});