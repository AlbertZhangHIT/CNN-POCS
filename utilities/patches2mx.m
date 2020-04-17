function D = patches2mx(data, dims, varargin)
if isa(data, 'cell')
    mode = 0;
else 
    mode = 1;
end
if length(dims) > 2
    error(['Only 2-dimensions supported']);
end
m = dims(1);
n = dims(2);
% Parse the optional inputs.
if mode
    patchsize = sqrt(size(data, 1));
else
    patchsize = size(data{1}, 1);
end
stride = patchsize;
step = 0;
if (mod(length(varargin), 2) ~= 0 )
    error(['Extra Parameters passed to the function ''' mfilename ''' lambdast be passed in pairs.']);
end
parameterCount = length(varargin)/2;

for parameterIndex = 1:parameterCount
    parameterName = varargin{parameterIndex*2 - 1};
    parameterValue = varargin{parameterIndex*2};
    switch lower(parameterName)
        case 'patchsize'
            patchsize = parameterValue;
        case 'stride'
            stride = parameterValue;
        case 'step'
            step = parameterValue;
    end
end

if length(patchsize) == 1
    patchsize = [patchsize, patchsize];
end
if length(stride) == 1
    stride = [stride, stride];
end 
if length(step) == 1
    step = [step, step];
end 

%% reconstruction
mmask = zeros(m, n);
D = zeros(m, n);

count  = 0;
for x = 1+step(1) : stride(1) : (m-patchsize(1)+1)
    for y = 1+step(2) : stride(2) : (n-patchsize(2)+1)
        count  = count + 1;
        if mode
            D(x : x+patchsize(1)-1, y : y+patchsize(2)-1, :) = D(x : x+patchsize(1)-1, y : y+patchsize(2)-1, :) + ...
                    resize(data(count, :), [patchsize(1), patchsize(2)]);
        else
            D(x : x+patchsize(1)-1, y : y+patchsize(2)-1, :) = D(x : x+patchsize(1)-1, y : y+patchsize(2)-1, :) + ...
                    data{count};
        end
        tmp = zeros(m, n);
        tmp(x : x+patchsize(1)-1, y : y+patchsize(2)-1, :) = 1;
        mmask = mmask + tmp;
    end
end

D = D./mmask;

end