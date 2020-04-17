function y = seismicDownsample(data, mask, sigma)
%%% function y = seismicDownsample(data, mask, sigma)
%%% downsample the seismic data along columns
%%% INPUT:
%%%   data:   seismic data with size [m, n]
%%%   mask:   bool matrix in which 1/True means saving data points
%%%   sigma:  gaussian noise factor
%%% OUTPUT:
%%%   y:      downsampled result

[m, n] = size(data);

savedIndex = (find(mask~=0));

noise = sigma/255*max(abs(data(:)))*randn(m, n);

noisyData = data + noise;

y = noisyData(savedIndex);

y = reshape(y, [m, length(savedIndex)/m]);

end