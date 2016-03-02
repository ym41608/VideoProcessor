% Inverse warping the mask to camera image
%
% Usage:
%   [Imask, x, y] = maskTransformation3D(I, T, pw, M, nm_mat, depth)
%
% Inputs:
%   I      = camera image
%   T      = mask image
%   pw     = width of plate in the template
%   M      = 3x3 homography transformation matrix
%   nm_mat = normalization matrix
%   depth  = depth
%
% Output:
%   Imask   = warped mask image
%   x       = x coordinates of corner
%   y       = y coordinates of corner

function [Imask, x, y] = maskTransformation3D(I, T, pw, M, nm_mat, depth)
  
  [Th, Tw, ~] = size(T);
  p = [1, pw, pw; Th - pw + 1, Th - pw + 1, Th; 1, 1, 1];
  
  % Z-plane
  Mz = [M(1:3,1:2), M(1:3,3)*depth + M(1:3,4)];
  [maskz, ~, ~] = maskTransformation(I, T, Mz, nm_mat);
  [xz, yz] = calConer(p, Mz, nm_mat);
  
  % X-plane
  Mx = [M(1:3,2:3), M(1:3,1)*depth + M(1:3,4)];
  [maskx, ~, ~] = maskTransformation(I, T, Mx, nm_mat);
  [xx, yx] = calConer(p, Mz, nm_mat);
  
  % Y-plane
  My = [M(1:3,[3,1]), M(1:3,2)*depth + M(1:3,4)];
  [masky, ~, ~] = maskTransformation(I, T, My, nm_mat);
  [xy, yy] = calConer(p, Mz, nm_mat);
  
  Imask = double(maskx | masky | maskz);
  x = [xz, xx, xy];
  y = [yz, yx, yy];
end

function [x y] = calConer(p, M, nm_mat)
  pp = M*nm_mat*p;
  x = pp(1, :)./pp(3, :);
  y = pp(2, :)./pp(3, :);
end
