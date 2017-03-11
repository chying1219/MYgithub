function [ digits ] = B2_SegmentDigits( BW )
%SegmentDigits: This function segments the digits from the binarized image.
%               
%   Detailed explanation goes here
    [L,num] = bwlabel(BW); % Do connected component (CCP) labelling
    rc = cell(num,1); % Store the (x,y) coordinates of the pixels in each CCP
    % The following prepare variables for storing the left, right, top, bottom of each CCP
    left = zeros(num,1); 
    right = zeros(num,1);
    top = zeros(num,1);
    bottom = zeros(num,1);
    comp_sz = zeros(num, 1); % Store the size (number of pixels) in each CCP
    for n = 1: num % Find the four boundaries for each CCP
        [r, c] = find(L==n);
        rc{n} = [r,c];
        top(n) = min(rc{n}(:,1));
        left(n) = min(rc{n}(:,2));
        right(n) = max(rc{n}(:,2));
        bottom(n) = max(rc{n}(:,1));
    end
    % Merge the CCPs which overlap along horizontal axis (such as the upper
    % half and low half of a digit 1)
    [new_rc, left, right, top, bottom] = B3_Merge(left, right, top, bottom, rc);
    num = length(new_rc); % Find the number of CCPs after merging
    comp_sz = zeros(num, 1); % Reset the size of the CCPs after merging
    for n = 1:length(new_rc)
        %     w = right(n)-left(n)+1;
        %     h = bottom(n)-top(n)+1;
        %     aspect_ratio(n) = w/h;
        comp_sz(n) = length(new_rc{n}); % Recompute the size of each CCP
    end
    w = right - left + 1; % Compute the widths of the CCPs
    h = bottom - top + 1; % Compute the heights of the CCPs
    aspect_ratio = w./h; % Compute the aspect ratio of the CCPs
    % flag = (comp_sz<0.4*mean(comp_sz)&h<0.6*mean(h))|aspect_ratio>0.8; 
    flag = (comp_sz<0.55*mean(comp_sz)&h<0.6*mean(h))|aspect_ratio>0.7; % Find the CPPs that are (1) small and short in height or (2) have abnormal aspect ratios.
    new_rc(flag,:) = []; % Remove the CCPS that reveal the above abnormalities
    comp_sz(flag) = []; % Remove the corresponding size entries of the abnormal CCPs from the comp_sz vector
    top(flag) = []; % Remove the corresponding top entries of the abnormal CCPs from the top vector
    left(flag) = []; % Remove the corresponding left entries of the abnormal CCPs from the left vector
    right(flag) = []; % Remove the corresponding right entries of the abnormal CCPs from the right vector
    bottom(flag) = []; % Remove the corresponding bottom entries of the abnormal CCPs from the bottom vector
    new_bottom = bottom;
    new_right = right;
    rc = new_rc;
    num = length(rc);
    for n = 1:num % Recompute the four boundaries of the normal CCPs
        top(n) = min(rc{n}(:,1));
        left(n) = min(rc{n}(:,2));
        right(n) = max(rc{n}(:,2));
        bottom(n) = max(rc{n}(:,1));
        rc{n}(:,1) = rc{n}(:,1) - top(n) + 1; % offset the pixel coordinates with the top entry
        rc{n}(:,2) = rc{n}(:,2) - left(n) + 1; % offset the pixel coordinates with the left entry
        new_bottom(n) = max(rc{n}(:,1)); % find the new bottom of the CCP
        new_right(n) = max(rc{n}(:,2)); % find the new right of the CCP
        comp_sz(n) = length(rc{n}); % find the new size of the CCP
    end
    % The following start to construct the image for each CCP using the pixel coordinates 
    digits = cell(num, 1);
    for n = 1:num
        %     if (comp_sz(n) < 0.3*avg_comp_sz)
        %         continue;
        %     end
        digits{n} = zeros(new_bottom(n), new_right(n));
        for p = 1: comp_sz(n)
            digits{n}(rc{n}(p,1), rc{n}(p,2)) = 1;
        end
        %if (right(n)==max(right)||1)
        digits{n} = B3_RefineDigit(digits{n}); % Remove the bright yellow dot or decimal point from the digit image
        %end
    end
end

