%% �ǤJA,B��x�}�A�qAX=B������X�AX�Y��Trans�A���s�ƦC��X��Transform�C

function [Transform]=A2_trans(A,B)

Trans = pinv(A)*B;
Transform = [Trans(1,1) Trans(2,1) Trans(3,1); Trans(4,1) Trans(5,1) Trans(6,1); 0 0 1];

end 