clear all; close all; clc;
addpath('function');

%% camera image
%I = im2double(imread('imgs/be_ir_1_120.png'));
%
%% pose
%ex_mat = [0.905511 0.424310 0.003268 0.424255 -0.905478 0.010818 0.007549 -0.008409 -0.999936 -0.003151 0.016662 0.380164];
%ex_mat = reshape(ex_mat, 3, 4);
%
%% cut
%Icut = Processor(I, ex_mat);
%
%% output
%imshow(Icut);
%imwrite(Icut, 'result.png');

% conditions
c = ['tr'; 'zo'; 'or'; 'ir'; 'fl'; 'ml'; 'fm'];

% speed
s = 1:5;

% marker
m = ['wi'; 'du'; 'ci'; 'be'; 'fi'; 'ma'];

for ci = 1:7
  if ci < 5
    si = 1:5;
  else
    si = 1;
  end
  for sii = si
    for mi = 2:6
      str = [];
      if ci < 5
        str = [m(mi, :) '_' c(ci, :) '_' int2str(s(sii))];
      else
        str = [m(mi, :) '_' c(ci, :)];
      end
      fprintf([str '\n']);
      video_obj = VideoReader(['video/2D/' str '.mp4']);
      nf = importdata(['nframes/2D/' str '.txt']);
      poses = importdata(['poses/2D/' str '.txt']);
      writer_obj = VideoWriter(['outputs/2D/' str], 'MPEG-4');
      writer_obj.FrameRate = video_obj.FrameRate;
      open(writer_obj);
      for i = 1:nf
        I = im2double(read(video_obj, i));
        ex_mat = reshape(poses(i, :), 3, 4);
        Icut = Processor(I, ex_mat);
        writeVideo(writer_obj, Icut);
      end
      close(writer_obj);
    end
  end
end


