function [ digits, show ] = B1_SegmentAndRecognition( NumRange )

%% 數字分段切割
img = rgb2gray(NumRange); % Convert to gray image
level = multithresh((img)); % Use the Otsu algorithm for finding the threshold of binarization
weight= 1.35; % Initialize weighting factor of the threshold
num = 0;
while (num <= 2 || num >= 7) % Check if the number of segmented digits is proper
    BW = imquantize(img, weight*level); % Quantize and label the gray input image using the weighted threshold
    BW = (BW==2); % Convert the label image to a binary image
    digits = B2_SegmentDigits(BW); % Do the digit segmentation
    weight = weight - 0.02; % Gradually reduce the weight if the threhold cannot properly segment the digits
    num = length(digits); % Update the current number of segmented digits
end
% figure, imshow(BW); % Show the binarized image
% figure % Start to show all segmented digits in a figure
% for n = 1:num
%     subplot(1, num, n), imshow(digits{n}), axis([1 30 1 70]);
% end

%% 數字辨識
% 數據結構調整
for n = 1:num
    ReDigits{n} = imresize(digits{n},[16 16]);
    ReDigitsToUint8{n} = uint8(round(ReDigits{n}*255)); 
    NumData256{n} = reshape(ReDigitsToUint8{n},1,256);
    NumID(n,1) = [0];
end
NumData=reshape(NumData256,num,1);
NumArray = cell2mat(NumData);

% 存成文字檔
ImgTxt = [double(NumID),double(NumArray)];
train = load('TrainingDataDB.txt');
[ show ] = B2_Reg( ImgTxt, train );
% for n = 1:num
%     subplot(1, num, n), imshow(digits{n}), axis([1 30 1 70]); title(show(n));
% end

end

