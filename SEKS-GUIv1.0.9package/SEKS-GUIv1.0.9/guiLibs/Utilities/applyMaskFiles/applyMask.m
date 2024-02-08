%
% Load desired coordinates to create a mask on a map. 
%

mapDataPath = pwd;
addpath(mapDataPath,'-end');

% Load the data from the coordinates files here
%

caDD = load('californiaBorders.txt');         % Loading actual coordinates file, prepared by user
figCorners = [-125 -114 32 42];               % Provide your map corners (typically, the output grid edges)

% Plot the mask components here
%
hold on;                                      % IMPORTANT: Plot on top of existing map
plot(caDD(:,1),caDD(:,2),'-k','LineWidth',1); % Longitude is on 1st column, latitude is on 2nd
fill(caDD(:,1),caDD(:,2),'white');            % Fill masking space outside with white
hold off;

xlabel('Longitude (DD)');
ylabel('Latitude (DD)');

axis([figCorners(1) figCorners(2) figCorners(3) figCorners(4)]); 
