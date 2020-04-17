function out = initInterp(subsampledData, mask, method)

if ~exist('method', 'var')
    method = 'nearest';
end

subsampledData = double(subsampledData);
[N, M] = size(subsampledData);
[X, Y] = meshgrid([1:M], [1:N]);
x = X(mask==1);
y = Y(mask==1);
z = subsampledData(mask==1);

xi = X(mask==0);
yi = Y(mask==0);

method = lower(method);
out = subsampledData;

zi = griddata(x,y,z,xi,yi,method);
zi(isnan(zi)) = 0;

out(mask==0) = zi;

end