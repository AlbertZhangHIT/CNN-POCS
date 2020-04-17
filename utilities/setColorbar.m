function setColorbar(fig, cb, varargin)
if (mod(length(varargin), 2) ~= 0 )
    error(['Extra Parameters passed to the function ''' mfilename ''' lambdast be passed in pairs.']);
end
pos = fig.Position;
position = [0 0 0.1 0.1];
for parameterIndex = 1:parameterCount
    parameterName = varargin{parameterIndex*2 - 1};
    parameterValue = varargin{parameterIndex*2};
    switch lower(parameterName)
        case 'position'
            position = parameterValue;
    end
end


set(cb, 'position', [pos(1)+xoff pos(2)+yoff width height])
end