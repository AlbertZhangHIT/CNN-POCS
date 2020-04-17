function boxedImage = boxOnImage(I, p, boxSize, lineSize, color)
% add box on images
% INPUT:
%   I:          - original image
%   p:      - coordinate of left-top point of box
%   boxSize:    - size of box
%   lineSize:   - line size of box edge
%   color:      - specified color of box edge

if exist('color', 'var')
    rgb = color;
else
    rgb = [255, 255, 255];
end
if exist('lineSize', 'var')
    linesize = lineSize;
else
    linesize = 1;
end

[h, w, c] = size(I);
ystart = p(1);
xstart = p(2);
m = boxSize(1);
n = boxSize(2);
if ystart > h || xstart > w || ystart+m > h || xstart+n > w
    error('Box exceeds the boundary of image');
end

boxedImage = I;

for i = 1 : c
    for l = 1 : linesize
        d = l - 1;
        boxedImage(ystart-d, xstart-d:xstart+n+d, i) = rgb(i);
        boxedImage(ystart+m+d, xstart-d:xstart+n+d, i) = rgb(i);
        boxedImage(ystart-d:ystart+m+d, xstart-d, i) = rgb(i);
        boxedImage(ystart-d:ystart+m+d, xstart+n+d, i) = rgb(i);
    end
end

end

