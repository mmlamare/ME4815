%% Drawing Engine
%  This Program takes an input image and generates trajectories for the ABB
%  IRB 1600 robot to draw. First, edges are detected with canny edge
%  detection. Second, a propritary bredth first seach algorithm is used to
%  make seach for lines. This process is itterated through the image a
%  pixel at a time. Pixels are toggled to zero to ensure lines are not
%  overlayed

clc
close all

%  A personal photo of Moscow City from September 2016 is locally stored in
%  the file directory. The image is loaded in as a test file. It is a jpg
%  but its 2017 to hopefully that won't matter.
I = imread('PTDC0073.jpg');

%  The 12 Megapixel native size from the camera is just too big for MATLAB.
%  It actually does the resizing automatically and throws a warning, but
%  this shuts it up.
I = imresize(I, 0.33);

%  Displays info about the image and the image itself
%whos J
figure, imshow(I);

%  the image must be converted to greyscale
gray = rgb2gray(I);
figure, imshow(gray);

%  Run Canny Edge detection to find the outlines
edge_method = 'Canny';
%threshold = 0.05;
I = edge(gray, edge_method);
figure, imshow(I);

%% Line Finding
%  form a collection
collection = [];

%  Iterate through each cell
for r = 1:len(I)
    for c = 1:len(r)
        pixel = I(r,c);
        if pixel == 1
            curve = [];
            curve.append([r,c]);
            
        end
    end
end