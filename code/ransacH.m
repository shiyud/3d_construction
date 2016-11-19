function [bestH] = ransacH(matches, locs1, locs2, nIter, tol)

p1 = (locs1(matches(:,1),[1,2]))';
p2 = (locs2(matches(:,2),[1,2]))';

total_num = size(matches,1);

valid_num = 0;

while(valid_num/total_num<0.3)
sample_num = randperm(total_num, 4);

sample1 = (locs1(matches(sample_num,1),[1,2]))';
sample2 = (locs2(matches(sample_num,2),[1,2]))';

H = computeH(sample1, sample2);

p1_compare = H*[p2; ones(1,total_num)];
divider = repmat(p1_compare(3,:),3,1);

p1_compare = p1_compare./divider;

p1_compare = p1_compare([1,2],:);

distance = sum((p1-p1_compare).^2);

inlier_index = find(distance<tol);

valid_num = length(inlier_index);

end

for i=1:nIter
    
pin1 = p1(:,inlier_index);
pin2 = p2(:,inlier_index);

H = computeH(pin1,pin2);

p1_compare = H*[p2; ones(1,total_num)];
divider = repmat(p1_compare(3,:),3,1);

p1_compare = p1_compare./divider;

p1_compare = p1_compare([1,2],:);

distance = sum((p1-p1_compare).^2);

inlier_index = find(distance<tol);

end

bestH = H;

end