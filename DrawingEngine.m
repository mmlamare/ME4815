%% Drawing Engine
%  This Program takes an input image and generates trajectories for the ABB
%  IRB 1600 robot to draw. First, edges are detected with canny edge
%  detection. Second, a propritary bredth first seach algorithm is used to
%  make seach for lines. This process is itterated through the image a
%  pixel at a time. Pixels are toggled to zero to ensure lines are not
%  overlayed

clc
close all
clear variables

%  A personal photo of Moscow City from September 2016 is locally stored in
%  the file directory. The image is loaded in as a test file. It is a jpg
%  but its 2017 to hopefully that won"t matter.
I = imread('Photos/PTDC0073.jpg');

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
figure, imshow(can);
%% Path Making Finding
%  form a collection
collection = {};
eightConnect = [0 1; 1 1; 1 0; 1 -1; 0 -1; -1 -1; -1 0; -1 1];
hasNeighbors = false;
isDone = false;
frontier = {};
repeat = {};

% set the values that determine which paths and points to keep
minLength = 6;
storePointCount = 6;

%can = [0 0 0 0 0 0 0 0; 0 0 1 1 0 1 1 0; 0 0 0 0 1 0 1 0;1 1 1 1 0 0 1 1;1 0 1 0 1 0 1 1;1 1 0 0 0 1 0 1;1 0 1 1 0 1 1 1;0 0 1 1 0 0 0 0]
[row,col] = size(can);

%  Begin to form a chain of pixels
curve = {};
%  Initialize count of curves
curveCount = 0;
%  Initialize count of points
pointCount = 0;

while ~isDone
    
    %  Iterate through each cell
    %  Go Through each row
    for r_m = 1:row
        %  Go through each element
        for c_m = 1:col
            %  Get the current pixel
            r_s = r_m;
            c_s = c_m;
            pixel = can(r_s,c_s);
            %  If its an edge
            while pixel
                %  Initially assume it has no neighbors
                hasNeighbors = false;
                %  Check if it has any neighbors
                for m = 1:length(eightConnect)
                    %  If the next pixel is an edge
                    x = r_s + eightConnect(m, 1);
                    y = c_s + eightConnect(m, 2);
                    % check for validity of neighbors
                    if (x > 0) && (y > 0) && (x <= row) && (y <= col)
                        % If a neighbor is valid and an edge and store only
                        % every other point
                        if can(x, y)
                            % add to frontier
                            frontier{end+1} = [x,y];
                            % set flag to true
                            hasNeighbors = true;
                        end
                    end
                end
                % if it has neighbors
                if hasNeighbors
                    % store only every other point
                    if (mod(pointCount,storePointCount) == 0)
                        %  Add the current pixel as the first in the chain
                        curve{end+1}=[r_s c_s];
                    end
                    pointCount = pointCount +1;
                    %  If conected to more than one pixel, store info to avoid
                    %  loss of lines
                    if(length(frontier) > 1)
                        %has more than one connection so add to list and clear
                        %to avoid loops
                        repeat{end+1}=[r_s c_s];
                        can(r_s, c_s) = 0;
                    else
                        %  otherwise clear current pixel to avoid loops
                        can(r_s, c_s) = 0;
                    end
                    
                    %  add first found frontier (theortically heading away
                    %  from starting position)
                    [front_r,front_c] = ind2sub(size(frontier),1);
                    canPos = frontier{front_r,front_c};
                    r_s = canPos(1);
                    c_s = canPos(2);
                    
                    % clear frontier for next loop
                    frontier = {};
                    % set next search point
                    pixel = can(r_s,c_s);
                else
                    %  Add the current pixel as the first in the chain
                    curve{end+1}=[r_s c_s];
                    
                    %  clear current pixel to avoid loops
                    can(r_s, c_s) = 0;
                    
                    % set next search point (goes back to orig)
                    pixel = can(r_m,c_m);
                end
            end
            %  add the curve that was just generated provided its longer
            %  than the min length
            if length(curve) > minLength
                curveCount = curveCount + 1;
                collection{curveCount,1} = curve;
                
                %  reset curve
                curve = {};
                
                % repopulate repeated nodes if necessary
                if (size(repeat,1) > 0) || (size(repeat,2) > 0)
                    for z = 1:sub2ind(size(repeat),size(repeat,1),size(repeat,2))
                        [rp_irow,rp_icol] = ind2sub(size(repeat),z);
                        rp_val = repeat{rp_irow,rp_icol};
                        can(rp_val(1,1),rp_val(1,2)) = 1;
                    end
                    repeat = {};
                end
            else
                %  reset curve array
                curve = {};
                %  reset repeated array
                repeat = {};
            end
        end
    end
    % assume that picture is empty of edges
    isEmpty = true;
    %  Iterate through each cell
    %  Go Through each row
    for r_m = 1:row
        %  Go through each element
        for c_m = 1:col
            if can(r_m,c_m)
                % found an edge cell
                isEmpty = false;
            end
        end
    end
    if isEmpty
        isDone = true;
        disp("Sketch Composition Complete")
    end
end
% plot collection to see simulated sketch
if (size(collection,1) > 0) || (size(collection,2) > 0)
    figure;
    hold on;
    for z = 1:sub2ind(size(collection),size(collection,1),size(collection,2))
        % clear structure to hold path
        clctn_path = {};
        point = [];
        % pull path from collection
        [clctn_irow,clctn_icol] = ind2sub(size(collection),z);
        % store path from collection
        clctn_path = collection{clctn_irow,clctn_icol};
        % need to modify the format of the data so that Matlab can plot it
        for y = 1:sub2ind(size(clctn_path),size(clctn_path,1),size(clctn_path,2))
            % pull point from path
            [clctn_p_row,clctn_p_col] = ind2sub(size(clctn_path),y);
            temp = clctn_path{clctn_p_row,clctn_p_col};
            % store point in n x  matrix
            point(y,1) = temp(1,1);
            point(y,2) = temp(1,2);
        end
        % plot simulated sketch
        plot(point(:,1),point(:,2));
    end
    hold off;
    disp("Simulated Plot Complete");
end

%% Generate Rapid Code

% An offset needs to be made to account for the gipper on the EOAT
MarkerHeight = 190;

% Set a constant for the height to draw on
% The board is 1/8 inch thick, 3.175 mm
HEIGHT = 3.18 + MarkerHeight;
ClearenceHeight = 10 + MarkerHeight;

% Set a scale for pixels per inch
% Needs to be mapped
PPI =    1035/533.4;
xOffset = 5;
yOffset = 5;

% Create a File ID
% "a" character is used to ensure it appends
% "w" ensure existing contents are discarded
fID = fopen("RapidCommand.txt", 'a');
fBeginID = fopen("RapidCommand.txt", 'w');

% Begin text file generation with necessary meta data
% Print Module
fprintf(fBeginID, "MODULE Module1\r\n");
fprintf(fID, "\r\n");

% Print Targets
% For each curve,
% move linear to just above the first point
% move down to first point
% For each other point in the curve
% move linear to that
% when at last point in curve lift up linear
targCount = 1;
ThinCount = 1;
ThinThresh = 10;

for prow = 1:length(collection)
    tPath = collection{prow};
    % create the offset starting point
    Chords = tPath{1};
    xCoord = Chords(1);
    yCoord = Chords(2);
    % Map the coordinates
    xCoord = pixelToPosition(xCoord, PPI, xOffset);
    yCoord = pixelToPosition(yCoord, PPI, yOffset);
    zCoord = ClearenceHeight;
    ID = int2str(targCount) + "0";
    fprintf(fID, makeTargetCode(ID, xCoord, yCoord, zCoord));
    targCount = targCount + 1;
    % Make the targets for the rest of the path
    for targ = 1:length(tPath)
        Chords = tPath{targ};
        xCoord = Chords(1);
        yCoord = Chords(2);
        % Map the coordinates
        xCoord = pixelToPosition(xCoord, PPI, xOffset);
        yCoord = pixelToPosition(yCoord, PPI, yOffset);
        zCoord = HEIGHT;
        ID = int2str(targCount) + "0";
        fprintf(fID, makeTargetCode(ID, xCoord, yCoord, zCoord));
        targCount = targCount + 1;
    end
    % create the offset ending point
    Chords = tPath{end};
    xCoord = Chords(1);
    yCoord = Chords(2);
    LastX = xCoord;
    LastY = yCoord;
    % Map the coordinates
    xCoord = pixelToPosition(xCoord, PPI, xOffset);
    yCoord = pixelToPosition(yCoord, PPI, yOffset);
    zCoord = ClearenceHeight;
    ID = int2str(targCount) + "0";
    fprintf(fID, makeTargetCode(ID, xCoord, yCoord, zCoord));
    targCount = targCount + 1;
end

% Print Main
fprintf(fID, "\r\n");
fprintf(fID, "PROC main()\r\n");
% itterate through the list of paths
for prow = 1:length(collection)
    fprintf(fID, "    Path_" + int2str(prow) + "0;\r\n");
end
fprintf(fID, "ENDPROC\r\n");

% Print Paths
% itterate through each path
% within each path, itterate through each target
% figure amount of local curve and map to z value
% print moveL command
fprintf(fID, "\r\n");
pTargCount = 1;
for prow = 1:length(collection)
    tPath = collection{prow};
    fprintf(fID, "PROC Path_" + int2str(prow) + "0()\r\n");
    % insert starting offset Point
    TargetID = int2str(pTargCount) + "0";
    vel = "v200";
    z = "fine";
    tool = "tool0";
    workobj = "Workobject_1";
    fprintf(fID, makeMoveL(TargetID, vel, z, tool, workobj));
    pTargCount = pTargCount + 1;
    % insert the path points
    for pTarg = 1:length(tPath)
        TargetID = int2str(pTargCount) + "0";
        vel = "v200";
        z = "z1";
        tool = "tool0";
        workobj = "Workobject_1";
        fprintf(fID, makeMoveL(TargetID, vel, z, tool, workobj));
        pTargCount = pTargCount + 1;
    end
    % insert ending offset Point
    TargetID = int2str(pTargCount) + "0";
    vel = "v200";
    z = "fine";
    tool = "tool0";
    workobj = "Workobject_1";
    fprintf(fID, makeMoveL(TargetID, vel, z, tool, workobj));
    pTargCount = pTargCount + 1;
    fprintf(fID, "ENDPROC\r\n");
    fprintf(fID, "\r\n");
end

% Print ENDMODULE
fprintf(fID, "ENDMODULE\r\n");

% Close the file now that we are done
fclose(fID);

disp("RAPID Code Generation Complete");