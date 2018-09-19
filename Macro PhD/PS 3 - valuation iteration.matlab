% Macro PS 3
% Content: 
	% getting data from fred
	% Value function iteration


c = fred('https://fred.stlouisfed.org/');
series = 'DEXUSEU';
d = fetch(c,series)
close(c)



