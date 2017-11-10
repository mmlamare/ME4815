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
collection = [];
eightConnect = [-1 -1; -1 0; -1 1; 0 -1; 1 -1; 1 0; 1 1; 0 1];
hasNeighbors = false;
frontiers = [];

can = [1 0 0; 0 1 0; 0 0 1];
[row,col] = size(can);

%  Iterate through each cell
%  Go Through each row
for r = 1:row
    %  Go through each element
    for c = 1:col
        %  Get the current pixel
        pixel = can(row, col);
        %  If its an edge
        if pixel
            %  Begin to form a chain of pixels
            curve = [];
            %  Innittially assume it has no neighbors
            hasNeighbors = false;
            %  Check if it has any neighbors
            for m = 1:length(eightConnect)
                %disp("checking for neighbors");
                %  If the next pixel is an edge
                x = row + eightConnect(m, 1);
                y = col + eightConnect(m, 2);
                if (x > 0) && (y > 0) && (x <= row) && (y <= col)
                    disp("is valid neighbor");
                    % If a neighbor is an edge
                    if can(x, y)
                        hasNeighbors = true;
                    end
                end
            end
            %  if its not just noise, add it, and begin chaining
            if hasNeighbors
                %  Add the current pixel as the first in the chain
                curve.append([row col]);
                can([r c]) = 0;
            end
            while hasNeighbors
                for m = 1:length(eightConnect)
                    %  If the next pixel is an edge
                    if can([r c] + m) == true
                        %instead add to frontiers
                        frontiers.append([r c] + m);
                        %we now know it has a neighbor
                        hasNeighbors = true;
                    end
                end 
                %add most optimal frontier, the one in the middle
                middleNode = frontiers(length(frontiers) / 2);
                %clear the pixel on the image
                can([middleNode(0) middleNode(1)]) = 0;
                %clear the frontiers
                frontiers = [];
                curve.append(middleNode);
                %set next search point
                pixel = middleNode;
            end
            %add the curve that was just generated provided its not empty
            if size(curve) > 0
                collection.append(curve);
                disp('hit');
            end
        else
            disp('miss')
        end
    end
end

disp(can);