function visualizeCausalities(timeSeries, causalities, significances, stepSize, fromChannels, toChannels,time) 

% init figure
f = figure('Visible','off', 'units','normalized','outerposition',[0 0.05 1 0.95]);

% find entries having causality
heatmapData = significances .* (causalities > 0);

% average results over trials
heatmapData = squeeze(mean(heatmapData,1));

% find dimensions
numberOfWindows = size(heatmapData,3);
numberOfDrivers = size(heatmapData,1);
numberOfDrivens = size(heatmapData,2);

% average time series over trials for visualization
timeSeries = squeeze(mean(timeSeries,1));

t = 1;

pan = uipanel('Parent', f, 'Units', 'normal', 'Position', [0 0 1/2 1/2], 'BorderWidth', 0);
sld = uicontrol('Style', 'slider',...
    'Min',1,'Max',numberOfWindows,'Value',t,...
    'Units', 'normal', 'Position', [1/3 15/16 2/3 1/16],...
    'Callback', @slidercallback, 'SliderStep', [1/(numberOfWindows-1),1/(numberOfWindows-1)], 'Parent', pan); 

f.Visible = 'on';

slidercallback(sld);


function slidercallback(source,event)    
    t = round(source.Value);
    
    % plot channels over time
    subplot(2,2,1);
    plot(time,timeSeries');
    title('Channels over time, averaged over the trials')
    xlabel('Time')
    ylabel('LFP')
    
    % plot window indicators
    hold on;
    line(time(round([(t-1) * stepSize+1, (t-1) * stepSize+1])),[min(timeSeries(:))-1 max(timeSeries(:))-1],'Color','r');
    line(time(round([(t-1) * stepSize+1, (t-1) * stepSize+1]+stepSize)),[min(timeSeries(:))-1 max(timeSeries(:))-1],'Color','r');
    hold off;
    
    % plot 
    subplot(2,2,[2 4]);   
    imagesc(heatmapData(:,:,t),[0 1]);
    colormap jet;
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',1:numberOfDrivens);
    set(gca,'YTick',1:numberOfDrivers);
    set(gca,'YTickLabel',fromChannels);
    set(gca,'XTickLabel',toChannels);
    ylabel('From')
    xlabel('To')
    bar = colorbar;
    ylabel(bar, 'Portion of significant trials')
end

end 