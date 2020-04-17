function mask = projMask(u, r, type)
% u, image
% r, data KNOWN ratio
% type: data missing type
%   'randr': random missing rows
%   'randc': random missing columns, but the maximum gap is constrained
%   'p': random missing pixels
%   'regc': regularly missing columns
%   'iregc': irregularly missing columns
% For ROW COLUMN missing cases, the max gap between two known
% rows/columns is at most 2(1/r-1) with probability r^2

% default missing case: regularly missing
if ~exist('type', 'var')
    type = 'regc'; 
end
[m,n] = size(u);

mask = zeros(m,n);

switch type
    
    case 'randr'
        
        gap = 1/r;
        gap_ = ceil(gap);
        K = floor(m*r);
        
        for i=1:K
            j = floor((i-1)*gap) + randperm(gap_,1);
            mask(j,:) = 1;
        end
        
    case 'randc'
        
        gap = 1/r;
        gap_ = ceil(gap);
        K = floor(n*r);
        
        for i=1:K
            j = floor((i-1)*gap) + randperm(gap_,1);
            mask(:,j) = 1;
        end
    case 'regc'
        gap = 1/r;
        mask(:, round(1:gap:n)) = 1;
    case 'regr'
        gap = 1/r;
        mask(round(1:gap:m), :) = 1;
        
    case 'p'
        
        pix = randperm(m*n);
        r = fix(r*m*n);
        pix = pix(1:r);
        mask(pix) = 1;
        
    case 'iregc'
        index = randperm(n);
        sample = index(1:fix(n*r));
        mask(:, sample) = 1;
    otherwise % pixel-wise missing
        
        pix = randperm(m*n);
        r = fix(r*m*n);
        pix = pix(1:r);
        mask(pix) = 1;
        
end
