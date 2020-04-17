function psnr = Cal_BatchPSNR(inputs, labels, valrange, row, col)
if ~exist('col', 'var')
    col = 0;
end
if ~exist('row', 'var')
    row = 0;
end
if ~exist('valrange', 'var')
    valrange = 1;
end
[n, m , ~, batchSize] = size(labels);
inputs = inputs(row+1:n-row, col+1:m-col, :, :);
labels = labels(row+1:n-row, col+1:m-col, :, :);

psnr = 0;
for i = 1 : batchSize
    A = inputs(:, :, :, i);
    B = labels(:, :, :, i);
    e = A(:) - B(:);
    mse = mean(e.^2);
    psnr = psnr + 10*log10(valrange^2/mse);
end
psnr = psnr / batchSize;