function fig = seishow3D(D, varargin)
%cmin, cmax, dmin, dmax, dt, dx, dy, figSize, colorbarOn)

%        cmin:       lower clip in % (90% means clip at the 90% negative amplitude)
%        cmax:       lower clip in % (90% means clip at the 90% positive amplitude)

cmin=100;
cmax=100;
dt = 1;    
dx = 1;    
dy = 1;    
figSize = [100, 100, 600, 600];    
colorbarOn = 0;    

% Parse the optional inputs
if (mod(length(varargin), 2) ~= 0)
    error(['Extra paramters passed to the function ''' mfilename ''' lambda must be passed in pairs']);
end
parameterCount = length(varargin) / 2;
for parameterIndex = 1:parameterCount
    parameterName = varargin{parameterIndex*2 - 1};
    parameterValue = varargin{parameterIndex*2};
    switch lower(parameterName)
        case 'cmin'
            cmin = parameterValue;
        case 'cmax'
            cmax = parameterValue;
        case 'dmin'
            dmin = parameterValue;
        case 'dmax'
            dmax = parameterValue;            
        case 'dt'
            dt = parameterValue;            
        case 'dx'
            dx = parameterValue;             
        case 'dy'
            dy = parameterValue;             
        case 'figsize'
            figSize = parameterValue;             
        case 'colorbar'
            colorbarOn = parameterValue;    
        case 'caxis'
            caxisValue = parameterValue;
        case 'colormap'
            colormapValue = parameterValue;
    end                    
end

cm = min(D(:));
[n1, n2, n3] = size(D);

yt  = [1:100:n3, n3+1:100:(n1+n3+1)];
ytl = [[0:100:n3]*dy, [0:100:n1]*dt];
xt = [1:100:n2, n2+1:100:(n2+n3+1)];
xtl = [[0:100:n2]*dx, [0:100:n3]*dy];


I                    = zeros(n1+n3+1, n2+n3+1);
I(1:n3, 1:n2)        = squeeze( D(round(n1/2),:,:) )';
I(:,n2+1)  = cm;
I(1:n3, n2+2:n2+n3+1)  = mean(D(:))*ones(n3, n3);
I(n3+2:n3+n1+1, 1:n2)  = squeeze(D(:,:, round(n3/2)));
I(n3+1,:)  = cm;
I(n3+2:n3+n1+1, n2+2:n2+n3+1) = squeeze( D(:,round(n2/2),:));

I = clip(I, cmin, cmax);

if (~isfield('dmin' ,'varargin')) 
    dmin = min(I(:)) ;
end
if (~isfield('dmax' ,'varargin')) 
    dmax = max(I(:)) ;
end

fig = figure('Position', figSize); set(gcf, 'color', 'white'); 
imagesc(I, [dmin,dmax]);
if strcmp(colormapValue, 'seismic')
    colormap(seismic(2));
else
    colormap(gray);
end

axis image;
hold on;
if colorbarOn
    colorbar;  
    hold on;
end
ax = gca;
ax.FontSize = 12;
ax.XTick = xt;
ax.YTick = yt;
ax.XTickLabel = xtl;
ax.YTickLabel = ytl;
if isfield('caxis', 'varargin')
    caxis(ax, caxisValue);
end
hold off;
xlabel('Shot (km)                         Receiver (km)');
ylabel('Time (s)                          Receiver (km)');

end
