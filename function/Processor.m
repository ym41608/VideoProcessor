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
  bw = csl(end)/30; % half of block width
  mask = ones(pw,pw);
  triangle = 1-triu(ones(bw));
  mask(1:bw,pw-bw+1:pw) = triangle;
  mask(1:bw,1:bw) = fliplr(triangle);
  mask(pw-bw+1:pw,1:bw) = triangle.';
  mask(pw-bw+1:pw,pw-bw+1:pw) = fliplr(triangle.');

  % mask on camera image
  [mask2, x2, y2] = maskTransformation(I, mask, in_mat, ex_mat, 3450);
  [~, x1, y1] = maskTransformation(I, mask, in_mat, ex_mat, 3310);
  
  % determine the kernel size
  dist = min(min(abs(y1.min - y2.min), abs(y1.max - y2.max)), min(abs(x1.min - x2.min), abs(x1.max - x2.max)));

  % blur
  h = fspecial('gaussian', dist * 2, dist / 2);
  Bmask = imfilter(mask2, h, 'symmetric');
  Bmask = repmat(Bmask, [1 1 3]);
  
  % combine blur and non-blur
  Icut = ones(size(I));
  Icut = I .* Bmask + ones(size(I)) .* (-Bmask + 1);

  % fix the boudary
  Icut(Icut < 0) = 0;
  Icut(Icut > 1) = 1;
end