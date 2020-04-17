%SETPATH: program to set path for SeismicLab and Demos 
 
% --------------------------------------------------------
% You need to modify Dir and DirD according to your system  
% --------------------------------------------------------
 

 Dir='D:/Toolbox/SeismicLab/codes/';
 DirD='D:/Toolbox/SeismicLab/';

 path(path, strcat(Dir,'bp_filter'));
 path(path, strcat(Dir,'decon'));
 path(path, strcat(Dir,'dephasing'));
 path(path, strcat(Dir,'fx'));
 path(path, strcat(Dir,'interpolation'));
 path(path, strcat(Dir,'kl_transform'));
 path(path, strcat(Dir,'radon_transforms'));
 path(path, strcat(Dir,'scaling_tapering'));
 path(path, strcat(Dir,'segy'));
 path(path, strcat(Dir,'seismic_plots'));
 path(path, strcat(Dir,'synthetics'));
 path(path, strcat(Dir,'velan_nmo'));
 path(path, strcat(Dir,'spectra'));

 path(path, DirD);
 path(path, strcat(DirD,'SeismicLab_demos'));
 path(path, strcat(DirD,'SeismicLab_data'));
