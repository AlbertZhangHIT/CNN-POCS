function [sampledResults] = projMaskMultiDim(D, sampleAxis, ratio, type)
% sampling matrix for multiple dimentional seismic data interpolation
% Input:
%   D           - data
%   sampleAxis  - axis index for sampling
%   ratio       - sampling ratio
%   type        - sampling type, valid options: {'reg', 'ireg', 'random'}
% Output:
%   
%
%
sampledResults = D;
dimSize = size(D);
ndim = length(dimSize);
fullAxis = 1:ndim;
notSampledAxis = find(ismember(fullAxis, sampleAxis)==0);

nSampleDim = length(sampleAxis);
sampleDim = dimSize(sampleAxis);

sampleIndex = cell(1, ndim);
for i = 1 : ndim
    sampleIndex{i} = zeros(1, dimSize(i));
end
for i = 1 : length(notSampledAxis)
    sampleIndex{notSampledAxis(i)} = ones(1, dimSize(notSampledAxis(i)));
end

gap = 1/ratio;
gap_ = ceil(gap);

switch type
    case 'reg'
        for i = 1 : nSampleDim
            sampleIndex{sampleAxis(i)}(round(1:gap:sampleDim(i))) = 1;
        end
    case 'ireg'
        for i = 1 : nSampleDim
            K = floor(sampleDim(i)*ratio);
            for j = 1 : K
                t = floor((j-1)*gap) + randperm(gap_, 1);
                sampleIndex{sampleAxis(i)}(t) = 1;
            end
        end
    case 'random'
        for i = 1 : nSampleDim
            permIndex = randperm(sampleDim(i));
            index = permIndex(1:fix(sampleDim(i) * ratio));
            sampleIndex{sampleAxis(i)}(index) = 1;
        end
    otherwise
        error('Not supported sampling type.');
end

inds = cell(1, ndim);
for i = 1 : ndim
    inds{i} = 1:dimSize(i);
end

for i = 1 : nSampleDim
    mask = zeros(dimSize);
    curInds = inds;
    curInds{sampleAxis(i)} = inds{sampleAxis(i)}(logical(sampleIndex{sampleAxis(i)}));
    mask(curInds{:}) = 1;
    sampledResults = sampledResults.*mask;
end

end