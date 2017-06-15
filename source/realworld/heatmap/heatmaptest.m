%Make Sure VRegions is a array
function heatmaptest(VRegions,method)
cntr =1;
f = figure('Visible','off', 'units','normalized','outerposition',[0 0.05 1 0.95]);
for i=1:size(VRegions,2)
    for j = 1:size(VRegions,2)
        if method == 'CNPMR'
           dataset = importdata(['./CNPMR/resultsV',num2str(VRegions(i)),'toV',num2str(VRegions(j)),'.mat']);
           
        elseif method == 'FAES'
           dataset = load(['./Faes/resultsV',num2str(VRegions(i)),'toV',num2str(VRegions(j)),'.mat']);
        else
            disp('No valid method selected')
        end
        avg = importdata('./averageV1.mat','averageV1');
        %make this the general case: avg = load('brainconnectivity/source/RealWorld/heatmap/averageV',num2str(VRegions(j)),'.mat');
        

        S = avg;
        Sstep = size(S,2) / 25;
        
        A = dataset(:,:,:,1) .* dataset(:,:,:,2);
        % normalize for heatmap
        maxcol = 255;
        absmaxA = max(A(:));


        for t=1:25
            for x=1:16
                for y=1:16
            A(x, y, t) = maxcol*A(x, y, t)/absmaxA;
                end
            end
        end 


        t = 10;
        pan = uipanel('Parent', f, 'Units', 'normal', 'Position', [0 0 1/3 1/2], 'BorderWidth', 0);
        sld = uicontrol('Style', 'slider',...
            'Min',1,'Max',25,'Value',t,...
            'Units', 'normal', 'Position', [1/3 15/16 2/3 1/16],...
            'Callback', @slidercallback, 'SliderStep', [1/25,1/5], 'Parent', pan); 

        f.Visible = 'on';
        % pause(0.00001);
        % frame_h = get(handle(gcf),'JavaFrame');
        % set(frame_h,'Maximized',1); 
        
        slidercallback(sld);
    end
end


function slidercallback(source,event)    
    t = round(source.Value);

    subplot(size(VRegions,2)+1,size(VRegions,2),1);
    plot(S');
    hold on;
    line([(t-1)*Sstep+4 (t-1)*Sstep+4],[min(S(:))-1 max(S(:))-1],'Color','white');
    line([(t-1)*Sstep (t-1)*Sstep],[min(S(:)) max(S(:))],'Color','r');
    hold off;
    subplot(size(VRegions,2)+1,size(VRegions,2),cntr+1);    
    cntr = cntr+1;
    colormap('jet');
    image(A(:,:,t));
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',[1:16]);
    set(gca,'YTick',[1:16]);
    colorbar;
    title(['C_{npmr} from V_1 to V_4, time/window ' num2str(t) ]);
    
    
end

end 