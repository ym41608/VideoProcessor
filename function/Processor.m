% Process 2D image, remove chessboard and smooth the boundary
%
% Usage:
%   Icut = Processor(I, ex_mat)
%
% Inputs:
%   I      = camera image
%   ex_mat = 3x3 extrinsic matrix
%
% Output:
%   Icut = processed image

function Icut = Processor(I, ex_mat)
  
  % intrinsic
  [Ih, Iw, ~] = size(I);
  focal_length = 3067.45 / 4;
  in_mat = [focal_length,0,Iw/2+0.5,0;0,focal_length,Ih/2+0.5,0;0,0,1,0;0,0,0,1];
  
  % l
  tsl = 3300;
  csl = [12350,8550,6270,4598,3630];
  
  % create mask
  pw = csl(end); % mask width
  bw = 165;%csl(end)/30; % half of block width
  mask = ones(pw,pw);
  triangle = 1-triu(ones(bw));
  mask(1:bw,pw-bw+1:pw) = triangle;
  mask(1:bw,1:bw) = fliplr(triangle);
  mask(pw-bw+1:pw,1:bw) = triangle.';
  mask(pw-bw+1:pw,pw-bw+1:pw) = fliplr(triangle.');
  [Th, Tw, ~] = size(mask);

  % mask on camera image
  M = in_mat(1:3, 1:3) * ex_mat(1:3, [1 2 4]);
  nm_mat = eye(3);
  nm_mat(1:2, :) = 0.5 * (3445/12350) * [1/Tw, 0, -1/(2*Tw) - 0.5; 0, -1/Th, 1/(2*Th) + 0.5];
  [mask2, x2, y2] = maskTransformation(I, mask, M, nm_mat);
  nm_mat(1:2, :) = 0.5 * (3310/12350) * [1/Tw, 0, -1/(2*Tw) - 0.5; 0, -1/Th, 1/(2*Th) + 0.5];
  [~, x1, y1] = maskTransformation(I, mask, M, nm_mat);
  
  % determine the kernel size
  dist = min(min(abs(y1.min - y2.min), abs(y1.max - y2.max)), min(abs(x1.min - x2.min), abs(x1.max - x2.max)));

  % blur
  dist = max(dist, 1);
  h = fspecial('gaussian', dist * 2, dist / 2);
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