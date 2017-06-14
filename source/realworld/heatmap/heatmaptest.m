
function heatmaptest 
load('./CresultsV1toV4.mat', 'resultsV1toV4');
load('./CresultsV4toV1.mat', 'resultsV4toV1');
load('./CresultsV1toV2.mat', 'resultsV1toV2');
load('./CresultsV2toV1.mat', 'resultsV2toV1');
load('./averageV1.mat', 'averageToData');
f = figure('Visible','off', 'units','normalized','outerposition',[0 0.05 1 0.95]);

S = averageToData;
Sstep = size(S,2) / 25;

A = resultsV1toV4(:,:,:,1) .* resultsV1toV4(:,:,:,2);
B = resultsV4toV1(:,:,:,1) .* resultsV4toV1(:,:,:,2);
C = resultsV1toV2(:,:,:,1) .* resultsV1toV2(:,:,:,2);
D = resultsV2toV1(:,:,:,1) .* resultsV2toV1(:,:,:,2);

% normalize for heatmap
maxcol = 255;
absmaxA = max(A(:));
absmaxB = max(B(:));
absmaxC = max(C(:));
absmaxD = max(D(:));

for t=1:25
    for x=1:16
        for y=1:16
            A(x, y, t) = maxcol*A(x, y, t)/absmaxA;
            B(x, y, t) = maxcol*B(x, y, t)/absmaxB;
            C(x, y, t) = maxcol*C(x, y, t)/absmaxC;
            D(x, y, t) = maxcol*D(x, y, t)/absmaxD;
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


function slidercallback(source,event)    
    t = round(source.Value);

    subplot(2,3,1);
    plot(S');
    hold on;
    line([(t-1)*Sstep+4 (t-1)*Sstep+4],[min(S(:))-1 max(S(:))-1],'Color','white');
    line([(t-1)*Sstep (t-1)*Sstep],[min(S(:)) max(S(:))],'Color','r');
    hold off;
    
    subplot(2,3,2);    
    colormap('jet');
    image(A(:,:,t));
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',[1:16]);
    set(gca,'YTick',[1:16]);
    colorbar;
    title(['C_{npmr} from V_1 to V_4, time/window ' num2str(t) ]);
        
    subplot(2,3,3);    
    colormap('jet');
    image(C(:,:,t));
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',[1:16]);
    set(gca,'YTick',[1:16]);
    colorbar;
    title(['C_{npmr} from V_1 to V_2, time/window ' num2str(t) ]);
    
    subplot(2,3,5);    
    colormap('jet');
    image(B(:,:,t));
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',[1:16]);
    set(gca,'YTick',[1:16]);
    colorbar;
    title(['C_{npmr} from V_4 to V_1, time/window ' num2str(t) ]);
    
    subplot(2,3,6);    
    colormap('jet');
    image(D(:,:,t));
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',[1:16]);
    set(gca,'YTick',[1:16]);
    colorbar;
    title(['C_{npmr} from V_2 to V_1, time/window ' num2str(t) ]);
    
end

end 