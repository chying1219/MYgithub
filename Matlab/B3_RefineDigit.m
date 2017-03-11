function [out_img] = B3_RefineDigit(img)
% RefineDigit: this function is to cut out the bright yellow dot which connected 
%              to the last digit. I simply scan each column from top to 
%              bottom to find the y-position of the first white pixel. The
%              positions of all columns are stored in the "mark" vector.
%              Then, compute the difference between neighboring values in
%              the mark vector and find the rightmost one (i.e., cut) that 
%              exceeds 0.35*height of this digit. If any one is found, then
%              it means that the image part at the right side of the cut point
%              actually contains the bright yellow dot. So, we can crop it off 
%              the digit image. If no cut is found, meaning that no bright 
%              yellow dot is contained in the digit image, thus no cut is
%              needed.
    [row col] = size(img);
    mark = zeros(1, col);
    for c = col:-1:1
        mark(c) = find(img(:,c), 1, 'first');
    end
    d = diff(mark);
    cut = find(d>=0.35*row, 1, 'last');
    if (~isempty(cut))
        out_img = img(:,1:cut-1);
    else
        out_img = img;
    end
end