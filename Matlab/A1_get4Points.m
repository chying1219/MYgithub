function [ NumRange ] = A1_get4Points( Image, CropIndex)

%% Part1_Main_get4Points Function
% 2. read 10 crops (day and night's↑,↓,←,→,normol) from Matlab
% 3. Image suit 10crops to find the best crop, then we call it "Optimal".
% 4. keep Image and Optimal's imformation to find their transform, call "transform"
% 5. using transform, input Optimal's 4 points, we can get Image's 4 points



%% 2. read Crops
% Crop 4 角點座標 - 1
[PositionTxt] = textread('FocusPos.txt');
CornerPosition = cell(1,CropIndex);
for i = 1:CropIndex
    FileName = ['Crop/FocusCrop (',int2str(i),').jpg'];
    Crop{i} = imread(FileName);  
    % Crop 4 角點座標 - 2 
    CropID{i} = PositionTxt(i*5-4,1);
    CornerPosition{i} = [PositionTxt(i*5-3:i*5,1), PositionTxt(i*5-3:i*5,2)];
end

% Find the SURF features - Image
ImgToGray=rgb2gray(Image); 
ImgPoints = detectSURFFeatures(ImgToGray);  
[ImgFeature, ImgVpts] = extractFeatures(ImgToGray, ImgPoints);  

% Find the SURF features - Crop, then match
for i = 1:CropIndex
	% Find the SURF features - Crop
    CropToGray{i}= rgb2gray(Crop{i});
    CropPoints{i} = detectSURFFeatures(CropToGray{i});  
    [CropFeature{i}, CropVpts{i}] = extractFeatures(CropToGray{i}, CropPoints{i});  

    %% 3. Suit
    % matched points - Crop & Image
    indexPairs{i} = matchFeatures(CropFeature{i}, ImgFeature, 'Prenormalized', true) ; 
    % Extract the features - Crop
    MatchCropPoints{i} = CropVpts{i}(indexPairs{i}(:, 1));
    MatchCropPointsPosition{i} = CropVpts{i}(indexPairs{i}(:, 1)).Location;
    % Extract the features - Img  
    MatchImgPointsPosition{i} = ImgVpts(indexPairs{i}(:, 2)).Location;  
    % 跟六張Crop比對
    [IndexPairsNum{i}, col{i}]= size (indexPairs{i});   % 特徵數
    [OptimalCropPoint OptimalCropIndex] = max(cell2mat(IndexPairsNum(:)));
    if ( OptimalCropIndex == i)
        OptimalCrop = Crop{i};
        OptCornerPos = CornerPosition{i};
        OptMatchCropPoints = MatchCropPointsPosition{i};
        OptMatchImgPoints = MatchImgPointsPosition{i};
    end
end

% 檢驗最佳的crop的四角點和配對特徵點是否正確
% figure;
% subplot(1,2,1);imshow(OptimalCrop); patch(OptCornerPos(:,1),OptCornerPos(:,2),[0 1 0],'FaceAlpha',0.5); title('4 Corner');
% subplot(1,2,2);imshow(OptimalCrop);hold on; scatter(OptMatchCropPoints(:,1), OptMatchCropPoints(:,2),'y*');  title(' All Pair Points ');

%% 4. transform
% Image和其最佳的Crop做線性轉換
% LT: ImgIn=*CropIn, Ax = b to find x, get "Transform" .
[MatchPointsSizes, col] = size(OptMatchCropPoints);
CropIn = [OptMatchCropPoints(:,1)'; OptMatchCropPoints(:,2)';ones(1,MatchPointsSizes)];
ImgIn = [OptMatchImgPoints(:,1)'; OptMatchImgPoints(:,2)';ones(1,MatchPointsSizes)];
%     figure; 
%         subplot(1,2,1),imshow(OptimalCrop);hold on; plot(CropIn(1,:),CropIn(2,:),'go','MarkerSize',10); title('Crop Points');
%         subplot(1,2,2),imshow(Image);hold on; plot(ImgIn(1,:),ImgIn(2,:),'go','MarkerSize',10); title('CutGreenRange Points');
    [CropInA, ImgInB]=A2_MatrixArrange(CropIn, ImgIn, MatchPointsSizes);
    [Transform]=A2_trans(CropInA,ImgInB);
    % catch bad points and delete
    ImgInspect = Transform*CropIn;
    % 顯示去掉壞份子後校正的特徵點
% figure; imshow(Image);hold on; plot(ImgInspect(1,:),ImgInspect(2,:),'yo','MarkerSize',10); title('ImgInspect in Image Points');
% [GoodIIIndex]=SumMean(ImgInspect,ImgIn);

% 校正: 傳入A,B兩矩陣，得出其相減後在加總的平均值，找出該列<平均值的行的索引值。
IISumDiff = sum(abs(ImgInspect-ImgIn));
IISDMean = mean(IISumDiff);
GoodIIIndex = find((IISumDiff<IISDMean) == 1); 

%Re LT:   ImgIn=Trans*CropIn,  find "TransformCorrect"  再次做線性轉換
ImgCorrectIn = (ImgIn(:,GoodIIIndex(1,:)));
    CropCorrectIn = (CropIn(:,GoodIIIndex(1,:)));
    [row, CorrectInSizes] = size(CropCorrectIn);
    [CropCorrectInA, ImgCorrectInB]=A2_MatrixArrange(CropCorrectIn,ImgCorrectIn,CorrectInSizes);
    [TransformCorrect]=A2_trans(CropCorrectInA,ImgCorrectInB);
    ImgInspectCorrect = TransformCorrect*CropCorrectIn;
%     % 顯示 用校正後的特徵點 作線性轉換的對比圖
%         figure;
%         subplot(1,2,1), imshow(Image);hold on;  plot(ImgCorrectIn(1,:), ImgCorrectIn(2,:), 'c*','MarkerSize',10);   title('ImgCorrectIn in Image Points');
%         subplot(1,2,2),imshow(Image);hold on; plot(ImgInspectCorrect(1,:),ImgInspectCorrect(2,:),'y+','MarkerSize',10); title('ImgInspectCorrect in Image Points');

    %% 3. Result 得到從Crop對應到Image的四角點
    % LT:    ImgOut=Trans*CropCornerOut,  find "ImgOut"     
    % CropCorner = [CropPoints(CornerPosition).Location];
    CropCorner = [OptCornerPos];
    CropCornerOut = [CropCorner'; ones(1,4)];
    ImgOut = TransformCorrect*CropCornerOut;
    % 顯示 Crop 和 Image 經過轉換得到的四角點
%         figure, subplot(1,2,1), imshow(OptimalCrop);hold on; plot(CropCorner(:,1), CropCorner(:,2), 'c*','MarkerSize',10 );  title('CropCornerOut in Crop Points');
%         subplot(1,2,2), imshow(Image);hold on;  plot(ImgOut(1,:), ImgOut(2,:), 'c*','MarkerSize',10);   title('ImgOut in Image Points');

        
    CornerX1 = min(ImgOut(1,:));
    CornerY1 = min(ImgOut(2,:));
    CornerX2 = max(ImgOut(1,:));
    CornerY2 = max(ImgOut(2,:));
    NumRange = imcrop(Image,[CornerX1 CornerY1 CornerX2-CornerX1 CornerY2-CornerY1]); 
    
end

