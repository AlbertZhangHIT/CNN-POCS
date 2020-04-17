function y = CalSNR(x0, x)
y = 0;
if ndims(x0) == 2
    mse = norm(x0 - x, 'fro');
    y = norm(x0, 'fro');

    y = 20*log10(y/(mse + 1e-30));
end
if ndims(x0) == 3
    for i = 1 : size(x0, 3)
        mse = norm(x0(:,:,i) - x(:,:,i), 'fro');
        t = norm(x0(:,:,i), 'fro');
        y = y + 20*log10(t/(mse + 1e-30));
    end
end
y = y / size(x0, 3);
end