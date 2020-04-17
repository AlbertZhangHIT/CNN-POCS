function snr = Cal_BatchSNR(inputs, labels, row, col)
if ~exist('col', 'var')
    col = 0;
end
if ~exist('row', 'var')
    row = 0;
end

[n, m , ~, batchSize] = size(labels);
inputs = inputs(row+1:n-row, col+1:m-col, :, :);
labels = labels(row+1:n-row, col+1:m-col, :, :);

snr = 0;
for i = 1 : batchSize
    A = inputs(:, :, :, i);
    B = labels(:, :, :, i);
    mse = norm(A - B, 'fro');
    y = norm(B, 'fro');
    if abs(y) <= 1e-30
        tmp = 0;
    else
        tmp = 20*log10(y/(mse + 1e-30));
    end
    snr = snr + tmp;
end
snr = snr / batchSize;

end