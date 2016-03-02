clear all; close all; clc;
addpath('function');

%% camera image
%I = im2double(imread('imgs/img.png'));
%
%% pose
%ex_mat = [0.997912 -0.013663 0.063133 -0.016440 -0.998910 0.043690 0.062467 -0.044636 -0.997048 -0.047995 -0.005108 0.461589];
%ex_mat = reshape(ex_mat, 3, 4);
%
%% cut
%Icut = imgCut(I, ex_mat);
%
%% output
%min(Icut(:))
%max(Icut(:))
%imshow(Icut);
%imwrite(Icut, 'result.png');

% load video
fileName = 'be_zo_5';
video_obj = VideoReader(['2D/video/' fileName '.mp4']);
nf = importdata(['nframes/' fileName '.txt']);
poses = importdata(['poses/' fileName '.txt']);

% video writer
writer_obj = VideoWriter(['outputs/' fileName '.mp4']);
writer_obj.FrameRate = video_obj.FrameRate;
open(writer_obj);
for i = 1:nf
  fprintf('%d / %d\n', i, nf);
  I = im2double(read(video_obj, i));
  ex_mat = reshape(poses(i, :), 3, 4);
  Icut = Processor(I, ex_mat);
  writeVideo(writer_obj, Icut);
end


