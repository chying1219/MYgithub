%% �ǤJA,B��x�}��size�A��x�}���s�ƦC
% 
%        B                 T                 A                                    InB          trans          InA
%  | u1~un |     | a b c  |     | x1~xn |                       |  A'  0    |    |    a  |      |  B(1,:)'  |
%  | v1~vn |  = | d e f  | *  | y1~yn |     ���s�ƦC   |              | * |   �� |  = |             |
%  | 1.......1 |      |  0 0 1 |     |  1......1 |                       |    0    A' |    |    f  |      |   B(2,:)' |
%  

function [InA, InB]=A2_MatrixArrange(A,B,size)

InA = [A' zeros(size,3); zeros(size,3) A'];
InB = [B(1,:)'; B(2,:)'];

end