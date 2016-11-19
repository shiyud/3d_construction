function [ P, error ] = triangulate( M1, p1, M2, p2 )
% triangulate:
%       M1 - 3x4 Camera Matrix 1
%       p1 - Nx2 set of points
%       M2 - 3x4 Camera Matrix 2
%       p2 - Nx2 set of points

% Q2.4 - Todo:
%       Implement a triangulation algorithm to compute the 3d locations
%       See Szeliski Chapter 7 for ideas
%

p1 = [p1 ones(length(p1),1)];
p2 = [p2 ones(length(p2),1)];

A = [];
error = 0;

for i = 1:size(p1,1)
    D = [p1(i,1)*M1(3,:) - M1(1,:);
         p1(i,2)*M1(3,:) - M1(2,:);
         p2(i,1)*M2(3,:) - M2(1,:);
         p2(i,2)*M2(3,:) - M2(2,:)];
    [~,~,v] = svd(D);
    X = v(:,end);
    X = X./X(4);
    P(i,:)= X(1:3);  
    
    nP1 = (M1*X)';
    nP1 = nP1./nP1(3);
    %nP1 = nP1(1:2);
    
    nP2 = (M2*X)';
    nP2 = nP2./nP2(3);
    %nP2 = nP2(1:2);
    
    error = error + pdist2(p1(i,:),nP1,'euclidean')^2 + pdist2(p2(i,:), nP2,'euclidean')^2;
   
end
      

 
end

