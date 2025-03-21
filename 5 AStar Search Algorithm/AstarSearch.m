clc;  
clear;  
close all;  

% Initialize the map and extract the occupancy matrix  
map1 = mapMaze(10, 5, 'MapSize', [50 50], 'MapResolution', 1);  
occupancyMapSample = occupancyMatrix(map1); % Get the occupancy matrix  

% Start and end points  
startPoint = [10, 10];  
endPoint = [40, 40];  

% Get the size of the maze  
[rows, cols] = size(occupancyMapSample);  

% Initialize visited matrix and parent dictionary  
visited = false(rows, cols); % Keeps track of visited cells  
parents = cell(rows, cols); % Stores parent information for backtracking  

% Open and closed sets  
openSet = [startPoint, 0]; % Each entry is [x, y, g_score]  
gScore = containers.Map(); % Cost from start to the node  
gScore(sprintf('%d,%d', startPoint(1), startPoint(2))) = 0;  

% Create a figure for visualization  
figure;  
show(map1); % Show the maze  
hold on;  
title('A* Maze Traversal');  
xlabel('X');  
ylabel('Y');  

% Visualization parameters  
scatter(startPoint(2), rows - startPoint(1) + 1, 'g', 'filled'); % Start point  
scatter(endPoint(2), rows - endPoint(1) + 1, 'r', 'filled'); % End point  
pause(0.1);  

% Create a Video Writer object  
videoWriter = VideoWriter('C:\Users\Amin\Desktop\AStar_Maze_Traversal.avi'); % Full path for the output video  
open(videoWriter); % Open the video writer for writing  

% A* Search loop  
found = false; % Flag to indicate if the end point was found  
while ~isempty(openSet)  
    % Calculate f_scores for all nodes in the open set  
    fScores = zeros(size(openSet, 1), 1);  
    for i = 1:size(openSet, 1)  
        node = openSet(i, 1:2);  
        fScores(i) = gScore(sprintf('%d,%d', node(1), node(2))) + heuristic(node, endPoint);  
    end  
    
    % Get the index of the node with the lowest f_score  
    [~, idx] = min(fScores);  
    
    % Take the node with the lowest f_score  
    current = openSet(idx, 1:2); % Extract the cell  
    openSet(idx, :) = []; % Remove the cell from the open set  

    % Check if we reached the end point  
    if isequal(current, endPoint)  
        found = true;  
        break;  
    end  
    
    % Visualize the exploration process  
    scatter(current(2), rows - current(1) + 1, 'b', 'filled'); % Current cell  
    pause(0.01);  
    frame = getframe(gcf); % Capture the figure as a frame  
    writeVideo(videoWriter, frame); % Write the frame to the video  
    
    % Get neighbors  
    neighbors = getNeighbors(current, rows, cols, occupancyMapSample);  
    
    for i = 1:size(neighbors, 1)  
        neighbor = neighbors(i, :);  
        tentativeGScore = gScore(sprintf('%d,%d', current(1), current(2))) + 1; % Assuming uniform cost  
        
        % If this path to neighbor is better, update the path  
        if ~isKey(gScore, sprintf('%d,%d', neighbor(1), neighbor(2))) || tentativeGScore < gScore(sprintf('%d,%d', neighbor(1), neighbor(2)))  
            parents{neighbor(1), neighbor(2)} = current; % Store parent  
            gScore(sprintf('%d,%d', neighbor(1), neighbor(2))) = tentativeGScore; % Update g_score  
            
            % Add neighbor to open set if not already there  
            if all(~ismember(openSet(:, 1:2), neighbor, 'rows'))  
                openSet = [openSet; neighbor, tentativeGScore];  
                
                % Visualize neighbors being added to the queue  
                scatter(neighbor(2), rows - neighbor(1) + 1, 'y', 'filled'); % Neighbor cell  
                pause(0.01);  
                frame = getframe(gcf); % Capture the figure as a frame  
                writeVideo(videoWriter, frame); % Write the frame to the video  
            end  
        end  
    end  
end  

% Backtrack to find the path if the end point was found  
if found  
    path = [];  
    current = endPoint;  
    while ~isempty(current)  
        path = [current; path]; % Add current cell to the path  
        current = parents{current(1), current(2)}; % Move to the parent cell  
    end  
    
    % Visualize the final path  
    for i = 1:size(path, 1)  
        scatter(path(i, 2), rows - path(i, 1) + 1, 'r', 'filled'); % Path cell  
        pause(0.01);  
        frame = getframe(gcf); % Capture the figure as a frame  
        writeVideo(videoWriter, frame); % Write the frame to the video  
    end  
    
    disp('Optimal Path from start to end:');  
    disp(path);  
else  
    disp('End point not reachable!');  
end  

hold off;  

% Close the video writer  
close(videoWriter);  

% Function to get valid neighbors  
function neighbors = getNeighbors(current, rows, cols, map)  
    directions = [0 1; 1 0; 0 -1; -1 0; 1 1; 1 -1; -1 1; -1 -1]; % Right, Down, Left, Up, Diagonals  
    neighbors = [];  
    for i = 1:size(directions, 1)  
        neighbor = current + directions(i, :);  
        % Check bounds and if the cell is free  
        if neighbor(1) > 0 && neighbor(1) <= rows && ...  
           neighbor(2) > 0 && neighbor(2) <= cols && ...  
           map(neighbor(1), neighbor(2)) == 0 % Free cell  
            neighbors = [neighbors; neighbor];  
        end  
    end  
end  

% Heuristic function: Manhattan distance  
function h = heuristic(point, goal)  
    h = abs(point(1) - goal(1)) + abs(point(2) - goal(2)); % Manhattan distance  
end  