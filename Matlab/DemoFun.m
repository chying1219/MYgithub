%% Main Code ( function )
% Part1_Main_get4Points Function
%   1. function read " the photo that phone take ", we call it  " Image ".
%   2. read 10 crops (day and night's¡ô,¡õ,¡ö,¡÷,normol) from Matlab
%   3. Image suit 10crops to find the best crop, then we call it "Optimal".
%   4. keep Image and Optimal's imformation to find their transform, call "transform"
%   5. using transform, input Optimal's 4 points, we can get Image's 4 points
% 6. cut Image's 4 points to "ROI", then segmentation it parts (maybe it have 1~6 numbers)
% 7. with our Database, we analyze every part which number it is.
% 8. store all the numbers into CellArray like result = { num(1), num(2), num(3), num(4), num(5), num(6)};
% 9. return result to Android to show Image and it's result.



%% 1. read Image
Image = imread('Image/015.jpg');


dirJPG=dir(['Image/','*.jpg']);
    for i=1:length(dirJPG)
        dirJPGname{i} = [mydir,dirJPG(i).name];  
        Images{i} = imread(dirJPGname{i});  
        
        
    end


CropNumber = 6;
[ NumRange ] = A1_get4Points( Image, CropNumber); % step.2~5
% figure, imshow(NumRange);

[ digits, show ] = B1_SegmentAndRecognition( NumRange ); % step.6~9


str=[];
for i=1:length(digits)
str=[str,num2str(show(i,1))];
end
% figure, imshow(NumRange); title(str);
















