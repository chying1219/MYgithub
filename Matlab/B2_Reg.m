function [ show ] = B2_Reg( test, train )

test2 = test;
train2 = train;


%�Ntrain and test�Ĥ@��(��ﵪ��)�h��
train=train(1:end,2:end);
test=test(1:end,2:end);
%

train_mu=mean(train);
train_Sigma=cov(train);
[V,D]=eig(train_Sigma);% ��X train_Sigma �� EigenVector = 256 * 15

N=15;

%�ѩ� EigenVector �̥k�䪺�ȬO�̤j�S���V�q�̤j���A��O�ѥk�ܥ����s�ƦC 
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

% �N�@train ���Ҧ���ƥ�256���׭��� N ��
[p,o]=size(train);
for i=1:p
    for j=1:o
        trainY(i,j)=[(train(i,j)-train_mu(1,j))]; %train ��� - ������ �é�J trainY
    end
end
trainreduceD=trainY * TransM_N; % �NtrainY * eigenvector �F�쭰�C��
%   

% test �P�W���歰��
[p,o]=size(test);
for i=1:p
    for j=1:o
        testY(i,j)=[(test(i,j)-train_mu(1,j))];
    end
end
testreduceD=testY * TransM_N;


%�N train ��Ƥ��� 0~9 �è����v�K�ר��
for digit=0:9
    mask = (train2(:,1) == digit); % �˴�train2�Ĥ@��O�_��digit�۲ŦX�ATrue is bool 1 or False is bool 0�A�ñNTrue data putting in mask matrix  
    digit_data = trainreduceD(mask,:); % �N�����᪺ train ��Ƹ�mask���۹����A�Nmask�ƭȬ�True(1)�����@��Ƹ�ƨ��X�Ӧs�Jdigit_data
    mu(digit+1, :) = mean(digit_data); % �����X����ƥ�����
    Sigma(:, :, digit+1) = cov(digit_data); % �����X�����Sigma
    prob(:, digit+1) = mvnpdf(testreduceD, mu(digit+1,:), Sigma(:,:,digit+1)); % �N�����᪺ test ��ƩM�����᪺ train ��Ƨ@���v�K�ר��,�|�o�쭰����test���Ҧ���ƩM������train����ƪ����v�K�׼ƭȦ@ 2007 ��
                                                                               %�u�C��v�N��0~9����ƱK�ר��
                                                                               % �ѩ�digit�����ɬO�q0�}�l�����Amatlab�W�w�O�q1�}�l�A�ҥHdigit+1
end

%transposed_prob = prob';
[M, I] = max(prob');% �ѩ�n���C������ƨs���O0~9���ӼƭȡA�ҥH�ݭn transposed_prob�Ӥ����o�C����ƪ��̤j���v�K�ר��
                    %�Abecause max�O�H��Ӥ��
show = (I-1)';
% correct = sum(test2(:,1)==(I-1)') % �W�@�B���o�����C���̤j���v�K�ר�ƪ� ���ޭ� �M test �Ĥ@�氵���A�Y�ۦP��True�A�[�`�ҥH�ۦP�����                                  
%                                   % �ѩ� 0 �����v�K�ר�ƭȬO�b�Ĥ@�C�A�ҥH������ 1
%                                   % test2 = 2007 * 256 �A I = 1*2007
%                                   % �Atest2�Ĥ@���I���A�ҥH��I transpse



end

