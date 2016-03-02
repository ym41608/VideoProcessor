% Inverse warping the mask to camera image
%
% Usage:
%   [Imask, x, y] = maskTransformation(I, T, M, nm_mat)
%
% Inputs:
%   I      = camera image
%   T      = mask image
%   M      = 3x3 homography transformation matrix
%   nm_mat = normalization matrix
%
% Output:
%   Imask   = warped mask image
%   x       = minmax of x coordinates
%   y       = minmax of y coordinates

function [Imask, x, y] = maskTransformation(I, T, M, nm_mat)
  
  % size
  [I_h, I_w, ~] = size(I);
  [T_h, T_w, ~] = size(T);
  
  % Homography
  H = M * nm_mat;
  
  % boundary  
  boundary = [1,1,T_h,T_h;1,T_w,1,T_w]; 
  corner = H*[boundary;1,1,1,1];
  corner(1,:) = corner(1,:)./corner(3,:);
  corner(2,:) = corner(2,:)./corner(3,:);
  X_max = min(ceil(max(corner(1,:))), I_w);
  Y_max = min(ceil(max(corner(2,:))), I_h);
  X_min = max(floor(min(corner(1,:))), 1);
  Y_min = max(floor(min(corner(2,:))), 1);
    
  [X, Y] = meshgrid(X_min:X_max, Y_min:Y_max);
  UV = H\[reshape(X,1,[]); reshape(Y,1,[]); ones(1,numel(X))];
  U = reshape(UV(1,:)./UV(3,:), [Y_max-Y_min+1, X_max-X_min+1]);
  V = reshape(UV(2,:)./UV(3,:), [Y_max-Y_min+1, X_max-X_min+1]);
  T_patch = interp2(T, U, V, 'bicubic');
  T_patch(isnan(T_patch)) = 0;
  
  x.min = X_min;
  x.max = X_max;
  y.min = Y_min;
  y.max = Y_max;
  
  Imask = zeros(I_h, I_w);
  Imask(Y_min:Y_max, X_min:X_max) = T_patch;
  
end
