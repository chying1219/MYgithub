function [ new_rc, new_left, new_right, new_top, new_bottom ] = B3_Merge( left, right, top, bottom, rc )
%Merge: this function is to merge the small connected components which are
%       overlapped horizontally. For example, sometimes the upper half and 
%       lower half of the digit 1 are separated into two different connected 
%       components. Since these two halves usually overlap along the horizontal
%       axis, we thus set the rule to merge those connected components with
%       horizontal overlaps into one digit.
    height = bottom - top + 1;
    width = right - left + 1;
    aspect_ratio = width ./ height;
    avg_height = mean(height);
    tmp_rc = rc;
    flag = aspect_ratio>=2.5|height<0.3*avg_height;
    tmp_rc(flag,:) = [];
    height(flag,:) = [];
    left(flag,:) = [];
    right(flag,:) = [];
    top(flag,:) = [];
    bottom(flag,:) = [];
    valid = ones(length(rc),1);
    stop = 0;
    new_rc = tmp_rc;
    while stop == 0
        stop = 1;
        for n = 1: length(tmp_rc)
            if (valid(n)==0)
                continue;
            end
            %sz = length(rc{n});
            for m = n+1: length(tmp_rc)
                if (valid(m)==0)
                    continue;
                end
                if (min(right(n),right(m))-max(left(n),left(m))>=2) % horizontal overlap >= 2
                    new_rc{n} = [new_rc{n};tmp_rc{m}];
                    left(n) = min(left(n), left(m));
                    right(n) = max(right(n), right(m));
                    top(n) = min(top(n), top(m));
                    bottom(n) = max(bottom(n), bottom(m));
                    valid(m) = 0;
                    stop = 0;
                end
            end
        end
    end
    new_rc(valid==0,:) = [];
    left(valid==0) = [];
    right(valid==0) = [];
    top(valid==0) = [];
    bottom(valid==0) = [];
    new_left = left;
    new_right = right;
    new_top = top;
    new_bottom = bottom;
end

