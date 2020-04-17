function I = displayMultiImages(D, imgSize, numRows, numCols)

showImFlag = 1;

borderSize = 1;
Dsize = size(D);
if length(Dsize) == 3
    if prod(Dsize(1:2)) ~= prod(imgSize)
        error('Size does not match');
    else
        D = reshape(D, [prod(imgSize), Dsize(3)]);
    end
end
if size(D, 1) ~= prod(imgSize)
    error('Size does not match');
end
if length(imgSize) == 3
    channels = 3;
else
    channels = 1;
end

numImages = size(D, 2);
if ~exist('numRows', 'var') && ~exist('numCols', 'var')
    numRows = ceil(sqrt(numImages));
    numCols = floor(numImages/numRows);
end
    

sizeForEachImage = [imgSize(1)+borderSize, imgSize(2)+borderSize];
I = zeros(sizeForEachImage(1)*numRows+borderSize, sizeForEachImage(2)*numCols+borderSize, channels);

%%% fill this image in white 
I(:, :, 1) = 1;
I(:, :, 1) = 1;
I(:, :, 1) = 1;

counter = 1;
for i = 1 : numRows
    for j = 1 : numCols
        I(borderSize+(i-1)*sizeForEachImage(1)+1:i*sizeForEachImage(1), borderSize+(j-1)*sizeForEachImage(2)+1:j*sizeForEachImage(2), :) ...
            = reshape(D(:, counter), imgSize);
        counter = counter + 1;
        if counter > numImages
            break;
        end
    end
end

if (showImFlag)
    I = I-min(min(min(I)));
    I = I./max(max(max(I)));
    imshow(I, []); set(gcf, 'color', 'white');
end