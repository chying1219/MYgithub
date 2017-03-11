function [ show ] = B2_Reg( test, train )

test2 = test;
train2 = train;


%將train and test第一排(比對答案)去除
train=train(1:end,2:end);
test=test(1:end,2:end);
%

train_mu=mean(train);
train_Sigma=cov(train);
[V,D]=eig(train_Sigma);% 算出 train_Sigma 的 EigenVector = 256 * 15

N=15;

%由於 EigenVector 最右邊的值是最大特正向量最大的，於是由右至左重新排列 
[a,b]=size(V);
num=0;
for i=1:a
    for j=1:b
        TransM_N(i,j)=V(i,a-num);
        num=num+1;
    end
    num=0;
end
TransM_N=TransM_N(1:end,1:N); % Choose the first N eigenvectors
%

% 將　train 的所有資料由256維度降成 N 維
[p,o]=size(train);
for i=1:p
    for j=1:o
        trainY(i,j)=[(train(i,j)-train_mu(1,j))]; %train 資料 - 平均值 並放入 trainY
    end
end
trainreduceD=trainY * TransM_N; % 將trainY * eigenvector 達到降低維
%   

% test 同上執行降維
[p,o]=size(test);
for i=1:p
    for j=1:o
        testY(i,j)=[(test(i,j)-train_mu(1,j))];
    end
end
testreduceD=testY * TransM_N;


%將 train 資料分類 0~9 並取機率密度函數
for digit=0:9
    mask = (train2(:,1) == digit); % 檢測train2第一行是否跟digit相符合，True is bool 1 or False is bool 0，並將True data putting in mask matrix  
    digit_data = trainreduceD(mask,:); % 將降維後的 train 資料跟mask做相對應，將mask數值為True(1)的那一橫排資料取出來存入digit_data
    mu(digit+1, :) = mean(digit_data); % 分類出的資料平均值
    Sigma(:, :, digit+1) = cov(digit_data); % 分類出的資料Sigma
    prob(:, digit+1) = mvnpdf(testreduceD, mu(digit+1,:), Sigma(:,:,digit+1)); % 將降維後的 test 資料和分類後的 train 資料作機率密度函數,會得到降維後test的所有資料和分類後train的資料的機率密度數值共 2007 個
                                                                               %「每行」代表0~9的資料密度函數
                                                                               % 由於digit分類時是從0開始分類，matlab規定是從1開始，所以digit+1
end

%transposed_prob = prob';
[M, I] = max(prob');% 由於要比對每次的資料究竟是0~9哪個數值，所以需要 transposed_prob來比對取得每筆資料的最大機率密度函數
                    %，because max是以行來比對
show = (I-1)';
% correct = sum(test2(:,1)==(I-1)') % 上一步取得的的每筆最大機率密度函數的 索引值 和 test 第一行做比對，若相同為True，加總所以相同的資料                                  
%                                   % 由於 0 的機率密度函數值是在第一列，所以必須減 1
%                                   % test2 = 2007 * 256 ， I = 1*2007
%                                   % ，test2第一行跟I比對，所以把I transpse



end

