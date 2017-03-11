%% 傳入A,B兩矩陣，從AX=B公式找X，X即為Trans，重新排列輸出成Transform。

function [Transform]=A2_trans(A,B)

Trans = pinv(A)*B;
Transform = [Trans(1,1) Trans(2,1) Trans(3,1); Trans(4,1) Trans(5,1) Trans(6,1); 0 0 1];

end 