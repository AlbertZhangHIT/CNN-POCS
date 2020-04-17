function D = mx2patches(data, varargin)
if length(size(data))~=2
    error('Input data required to be 2D matrix');
    return;
end
[hei, wid] = size(data);
% Parse the optional inputs.
patchsize = 16;
stride = patchsize;
step = 0;
mode = 'matrix';
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
        case 'mode'
            mode = parameterValue;
            if ~(strcmp(mode, 'matrix') || strcmp(mode, 'cell'))
                error(['Parameter mode only accept "matrix" or "ceil", invalid " ', mode, ' "']);
            end
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

count = 0;
%%% count dimension of D
for x = 1+step(1) : stride(1) : (hei-patchsize(1)+1)
    for y = 1+step(2) : stride(2) : (wid-patchsize(2)+1)
        count = count + 1;
    end
end
if strcmp(mode, 'matrix')
    D = zeros(patchsize(1)*patchsize(2), count);
    mode = 1;
else
    D = cell(count, 1);
    mode = 0;
end

count = 0;
for x = 1+step(1) : stride(1) : (hei-patchsize(1)+1)
    for y = 1+step(2) : stride(2) : (wid-patchsize(2)+1)
        count = count + 1;
        d = data(x : x+patchsize(1)-1, y : y+patchsize(2)-1,:);
        if mode
            D(:, count) = d(:);
        else
            D{count} = d;
        end
    end
end

end