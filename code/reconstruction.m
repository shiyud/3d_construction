clear all;
close all;
n_planes = 2;

im1 = rgb2gray(im2double(imread('../images/input/1_001.jpg')));
im2 = rgb2gray(im2double(imread('../images/input/1_002.jpg')));

surf1 = detectSURFFeatures(im1, 'MetricThreshold', 100);
surf2 = detectSURFFeatures(im2, 'MetricThreshold', 100);

[feat1, pts1] = extractFeatures(im1, surf1);
[feat2, pts2] = extractFeatures(im2, surf2);

% index_pairs = matchFeatures(feat1, feat2);

match1 = pts1(index_pairs(:,1), :);
match2 = pts2(index_pairs(:,2), :);

match1_loc = match1.Location;
match2_loc = match2.Location;

randidx = randperm(size(match1_loc,1), 4);

match1_h = [match1_loc'; ones(1,size(match1_loc,1))];
match2_h = [match2_loc'; ones(1,size(match2_loc,1))];

area_thresh = 1000;
det_thresh = 10;
dist_thresh = 20;

plane_pts = {};

plane1fin = [];
plane2fin = [];

while 1
    
    if size(plane_pts,2) == n_planes
        break
    end
    
    randidx = randperm(size(match1_loc,1), 4);
    subs = match1_loc(randidx,:);
    
    % check if areas formed by triangles are ok
    a1 = polyarea(subs([2 3 4],1), subs([2 3 4],2));
    a2 = polyarea(subs([1 3 4],1), subs([1 3 4],2));
    a3 = polyarea(subs([1 2 4],1), subs([1 2 4],2));
    a4 = polyarea(subs([1 2 3],1), subs([1 2 3],2));

    if any([a1 a2 a3 a4] < area_thresh)
        continue
    end

    subs1 = match1_loc(randidx,:);
    subs2 = match2_loc(randidx,:);

    H21 = computeH(subs1', subs2');

    tp1 = H21*match2_h;
    tp1 = [tp1(1,:) ./ tp1(3,:); tp1(2,:) ./ tp1(3,:)];

    dists = sqrt(sum((tp1 - match1_loc').^2));

    % number of pairs that satisfy the distance threshold
    compat = dists < 3;
    n_good = sum(compat);
    
	if (n_good < 30)
        continue
    end
    
    % now reestimate H iteratively
    err_thresh = 2;
    failed = 0;
    while 1
        if err_thresh <= 0.05
            break
        end
        refH = computeH(match1_loc(compat,:)', match2_loc(compat,:)');
        tp1 = refH*match2_h;
        tp1 = [tp1(1,:) ./ tp1(3,:); tp1(2,:) ./ tp1(3,:)];

        compat = (sqrt(sum((tp1 - match1_loc').^2)) < err_thresh);
        if sum(compat) < 8
            failed = 1;
            break
        end
        
        err_thresh = err_thresh * 0.7;
    end
    
    if failed == 1
        continue
    end
    
    new_im1_ref = applyH(im2, refH);
    new_im1 = applyH(im2, H21);
    %imshow(new_im1_ref);
    %imshow(abs(new_im1_ref-im1));
    
%     diff_im = abs(new_im1_ref-im1) < 3;
%     imshow(~diff_im)
    figure; 
    imshow(im1); hold on;% loop through all points, find matches consistent with H
    plane_pts_idx = (sqrt(sum((tp1 - match1_loc').^2)) < 1);
    
    %scatter(match1_loc(plane_pts_idx,1), match1_loc(plane_pts_idx,2));
    tx = double(match1_loc(plane_pts_idx,1));
    ty = double(match1_loc(plane_pts_idx,2));
    k = convhull(tx, ty);
    plot(tx(k), ty(k));
    
    plane1 = poly2mask(tx(k), ty(k), size(im1,1), size(im1,2));
%     plane1coord = ind2sub(size(im1), find(plane1>0));
    [plane1coordrow, plane1coordcol] = find(plane1>0);
    plane1coord = [plane1coordrow plane1coordcol ones(size(plane1coordcol))]';
    plane2coord = inv(RefH)*plane1coord;
    plane2coord = plane2coord(1:2, :)./repmat(plane2coord(3,:),[2,1]);
    
    plot(plane1coordcol, plane1coordrow)
    
    plane_pts = [plane_pts, [match1_loc(plane_pts_idx,:)]];
    match1_loc = match1_loc(~plane_pts_idx,:);
    match2_loc = match2_loc(~plane_pts_idx,:);
    match1_h = [match1_loc'; ones(1,size(match1_loc,1))];
    match2_h = [match2_loc'; ones(1,size(match2_loc,1))];
    figure
    imshow(im2);
    hold on;
    plot(plane2coord(2,:), plane2coord(1,:))
    
    plane1fin = [plane1fin plane1coord];
    plane2fin = [plane2fin plane2coord];
end

K = [1000 0 512;
     0 1000 384;
     0   0  1];
 
[F, inliers] = estimateFundamentalMatrix(match1_loc,match2_loc, 'Method', 'RANSAC', 'NumTrials', 2000, 'DistanceThreshold', 0.05);
E = K'*F*K;

M1 = K*[eye(3) zeros(3,1)];
error = [0 0 0 0];

M2s = camera2(E);

matched_points1 = match1_loc(logical(inliers),:);
matched_points2 = match2_loc(logical(inliers),:);
for i = 1:4
    [Pi(:,:,i), error(i)] = triangulate(M1, matched_points1, K*M2s(:,:,i), matched_points2);
end

check = sum(Pi(:,3,:)>0);

[~, n] = max(check);


M2 = M2s(:,:,n);
P = Pi(:,:,n);

% figure;
% hold
% pcshow(P, 'MarkerSize', 45)
[nP, ~] = triangulate(M1, plane1fin(1:2,:)', K*M2, plane2fin');

figure;
hold
pcshow(nP)



