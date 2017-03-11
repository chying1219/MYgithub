clear;
clc;
close all;

%% 1. read Image

first = 81;
last = 100; % length(dirJPG)
    
    for i = first:last
    % close all;
    FileName = ['Image/FocusImg (',int2str(i),').jpg'];
    Images{i} = imread(FileName);  
    
    answer = runMainCode( Images{i},i );
    end

    
    
    disp('end');















