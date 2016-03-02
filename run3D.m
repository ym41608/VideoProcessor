clear all; close all; clc;
addpath('function');

%% camera image
%I = im2double(imread('imgs/so_or_5_f_53.png'));
%
%% pose
%ex_mat = [-0.684783 0.728406 0.022283 0.728242 0.685127 -0.016267 -0.027116 0.005088 -0.999619 -0.012876 -0.021997 0.335070];
%ex_mat = reshape(ex_mat, 3, 4);
%
%% cut
%Icut = Processor3D(I, ex_mat);
%
%% output
%imshow(Icut);
%imwrite(Icut, 'result3D.png');

% conditions
c = ['tr'; 'zo'; 'or'; 'ir'; 'fl'; 'ml'; 'fm'];

% views
v = ['b'; 'f'; 'l'; 'r'];

% speed
s = 1:5;

% marker
m = ['bi'; 'ch'; 'ho'; 'ir'; 'je'; 'so'];

for ci = 1:7
  if ci < 5
    si = 1:5;
  else
    si = 1;
  end
  for sii = si
    for mi = 1:6
      for vi = 1:4
        str = [];
        if ci < 5
          str = [m(mi, :) '_' c(ci, :) '_' int2str(s(sii)) '_' v(vi, :)];
        else
          str = [m(mi, :) '_' c(ci, :) '_' v(vi, :)];
        end
        fprintf([str '\n']);
        video_obj = VideoReader(['video/3D/' str '.mp4']);
        nf = importdata(['nframes/3D/' str '.txt']);
        poses = importdata(['poses/3D/' str '.txt']);
        writer_obj = VideoWriter(['outputs/3D/' str], 'MPEG-4');
        writer_obj.FrameRate = video_obj.FrameRate;
        open(writer_obj);
        for i = 1:nf
          I = im2double(read(video_obj, i));
          ex_mat = reshape(poses(i, :), 3, 4);
          switch v(vi, :)
            case 'l'
              ex_mat(1:3,1:3) = ex_mat(1:3,1:3) / getRotMatFromEulerAngle(0, 0, -90);
            case 'b'
              ex_mat(1:3,1:3) = ex_mat(1:3,1:3) / getRotMatFromEulerAngle(0, 0, 180);
            case 'r'
              ex_mat(1:3,1:3) = ex_mat(1:3,1:3) / getRotMatFromEulerAngle(0, 0, 90);
           end
          Icut = Processor3D(I, ex_mat);
          writeVideo(writer_obj, Icut);
        end
        close(writer_obj);
      end
    end
  end
end


