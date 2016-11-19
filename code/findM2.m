% Q2.5 - Todo:
%       1. Load point correspondences
%       2. Obtain the correct M2
%       4. Save the correct M2, p1, p2, R and P to q2_5.mat

clear
load('q2_3.mat');
load('../data/intrinsics.mat');
load('../data/some_corresp');
p1 = pts1;
p2 = pts2;
M1 = K1*[eye(3) zeros(3,1)];

error = [0 0 0 0];

for i = 1:4
[Pi(:,:,i), error(i)] = triangulate( M1, p1, K2*M2s(:,:,i), p2);
end

check = all(Pi(:,3,:)>0);
n = find(check==1);

M2 = M2s(:,:,n);
P = Pi(:,:,n);

save('q2_5.mat','M2','p1','p2','P');
