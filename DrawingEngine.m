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
%figure, imshow(I);

%  the image must be converted to greyscale
gray = rgb2gray(I);
%figure, imshow(gray);

%  Run Canny Edge detection to find the outlines
edge_method = 'Canny';
%threshold = 0.05;
can = edge(gray, edge_method);
%figure, imshow(can);

%% Path Making Finding
%  form a collection
collection = {};
eightConnect = [-1 -1; -1 0; -1 1; 0 -1; 1 -1; 1 0; 1 1; 0 1];
hasNeighbors = false;
frontier = {};

can = [1 0 0; 0 1 0; 0 0 1;0 1 0]
[row,col] = size(can);

%  Begin to form a chain of pixels
curve = {};
%  Initialize count of curves
curveCount = 0;

%  Iterate through each cell
%  Go Through each row
for r_m = 1:row
    %  Go through each element
    for c_m = 1:col
        %  Get the current pixel
        r_s = r_m
        c_s = c_m
        pixel = can(r_s,c_s)
        %  If its an edge
        while pixel
            %  Initially assume it has no neighbors
            hasNeighbors = false;
            %  Check if it has any neighbors
            for m = 1:length(eightConnect)
                %disp("checking for neighbors");
                %  If the next pixel is an edge
                x = r_s + eightConnect(m, 1);
                y = c_s + eightConnect(m, 2);
                if (x > 0) && (y > 0) && (x <= row) && (y <= col)
                    %disp("is valid neighbor");
                    % If a neighbor is an edge
                    if can(x, y)
                        frontier{end+1} = [x,y];
                        hasNeighbors = true;
                    end
                end
            end
            if hasNeighbors
                %  Add the current pixel as the first in the chain
                curve{end+1}=[r_s c_s];
                %  clear current pixel to avoid loops
                can(r_s, c_s) = 0;
                
                %  add most optimal frontier, the one in the middle
                middleNode = round(length(frontier)/2);
                [front_r,front_c] = ind2sub(size(frontier),middleNode);
                canPos = frontier{front_r,front_c};
                r_s = canPos(1);
                c_s = canPos(2);
                r_s
                c_s
                %set next search point
                pixel = can(r_s,c_s);
            end
        end
        %  add the curve that was just generated provided its not empty
        if size(curve) > 0
            curveCount = curveCount + 1;
            collection{curveCount,1} = curve;
            disp(curve);
            %  reset curve
            curve = {};
        end
    end
end
