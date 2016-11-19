function [ H2to1 ] = computeH( p1, p2 )
%COMPUTEH Summary of this function goes here
%   computes H such that p1 ~= H*p2

N = size(p2,2);
%p1 = H*p2

%use p2 in homogeneous coords
p2_h = [p2', ones(N, 1)];

%build A
A = zeros(2*N, 9);

A(1:2:end, :) = [p2_h, zeros(N,3), bsxfun(@times, -p2_h, p1(1,:)')];
A(2:2:end, :) = [zeros(N,3), p2_h, bsxfun(@times, -p2_h, p1(2,:)')];


%solve Ah = 0
[~, ~, V] = svd(A);

h = V(:, size(V,2));
H2to1 = reshape(h, [3 3])';


end

