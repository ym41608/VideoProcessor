% Process 3D image, remove chessboard and smooth the boundary
%
% Usage:
%   Icut = Processor3D(I, ex_mat)
%
% Inputs:
%   I      = camera image
%   ex_mat = 3x3 extrinsic matrix
%
% Output:
%   Icut = processed image

function Icut = Processor3D(I, ex_mat)
  
  % intrinsic
  [Ih, Iw, ~] = size(I);
  focal_length = 3067.45 / 4;
  in_mat = [focal_length,0,Iw/2+0.5,0;0,focal_length,Ih/2+0.5,0;0,0,1,0;0,0,0,1];
  
  % l
  m = [3,4,5,6];
  tsl = 2457;
  csl = [6435,5005,4095,3465,3003];
  
  % create mask
  [mask2, pw2] = genMask(2710, csl, m);
  [mask1, pw1] = genMask(2480, csl, m);
  imwrite(mask1, '1.png');
  imwrite(mask2, '2.png');
  
  % mask on camera image
  M = in_mat * [ex_mat; 0, 0, 0, 1];
  r_3d = 0.108;
  depth = -0.5*r_3d*csl(end)/tsl;
  a = 1/tsl*csl(1)/csl(1);
  b = -a*(0.5+0.5*csl(end)*csl(1)/csl(1));
  nm_mat = eye(3);
  nm_mat(1:2, 1:3) = r_3d * [a,0,b; 0,-a,b+a*csl(1)];
  [mask2, x2, y2] = maskTransformation3D(I, mask2, pw2, M, nm_mat, depth);
  [mask1 x1, y1] = maskTransformation3D(I, mask1, pw1, M, nm_mat, depth);
  
  % determine the kernel size
  dist = min(sqrt((x2-x1).^2 + (y2-y1).^2)) / sqrt(2);

  % blur
  dist = max(round(dist), 1);
  h = fspecial('gaussian', dist, dist / 4);
  Bmask = imfilter(mask2, h, 'symmetric');
  Bmask(find(Bmask < 0)) = 0;
  Bmask(find(Bmask > 1)) = 1;
  Bmask = repmat(Bmask, [1 1 3]);

  % combine blur and non-blur
  Icut = ones(size(I));
  Icut = I .* Bmask + ones(size(I)) .* (-Bmask + 1);

  % fix the boundary
  Icut(find(Icut < 0)) = 0;
  Icut(find(Icut > 1)) = 1;
end

function [mask, pw] = genMask(curcsl, csl, m)

  mask = zeros(csl(1),csl(1));
  pw = curcsl; % plate width
  bw = floor(curcsl/(2*m(end)+1)/2); % block width
  center = ones(pw,pw);
  triangle = 1-triu(ones(bw));
  center(1:bw,end-bw+1:end) = triangle;
  bi = (csl(1)-pw)+1; % begin index
  mask(bi:end,1:pw) = center;

end