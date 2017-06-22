
function heatmaptest 

causality = load('CNPMRcausalityResultsV1toV1.mat');
causality11 = causality.data;
significance = load('CNPMRsignificanceResultsV1toV1.mat');
significance11 = significance.data;
causality = load('CNPMRcausalityResultsV1toV2.mat');
causality12 = causality.data;
significance = load('CNPMRsignificanceResultsV1toV2.mat');
significance12 = significance.data;
causality = load('output/trialshuffle/CNPMRcausalityResultsV1toV1.mat');
causality111 = causality.data;
significance = load('output/trialshuffle/CNPMRsignificanceResultsV1toV1.mat');
significance111 = significance.data;
f = figure('Visible','off', 'units','normalized','outerposition',[0 0.05 1 0.95]);

Sstep = 100;

A = significance11 .* (causality11 > 0);
A = squeeze(sum(A,4));
A = squeeze(mean(A,4));
B = significance12 .* (causality12 > 0);
B = squeeze(sum(B,4));
B = squeeze(mean(B,4));
C = significance111 .* (causality111 > 0);
C = squeeze(sum(C,4));
C = squeeze(mean(C,4));

% normalize for heatmap
maxcol = 255;
absmaxA = 1;

for t=1:size(A,3)
    for x=1:16
        for y=1:16
            A(x, y, t) = maxcol*A(x, y, t)/absmaxA;
            B(x, y, t) = maxcol*B(x, y, t)/absmaxA;
            C(x, y, t) = maxcol*C(x, y, t)/absmaxA;
        end
    end
end 


t = 10;

pan = uipanel('Parent', f, 'Units', 'normal', 'Position', [0 0 1/3 1/2], 'BorderWidth', 0);
sld = uicontrol('Style', 'slider',...
    'Min',1,'Max',13,'Value',t,...
    'Units', 'normal', 'Position', [1/3 15/16 2/3 1/16],...
    'Callback', @slidercallback, 'SliderStep', [1/13,1/5], 'Parent', pan); 

f.Visible = 'on';
% pause(0.00001);
% frame_h = get(handle(gcf),'JavaFrame');
% set(frame_h,'Maximized',1); 

slidercallback(sld);


function slidercallback(source,event)    
    t = round(source.Value);

    %subplot(2,3,1);
    %plot(S');
    %hold on;
    %line([(t-1)*Sstep+4 (t-1)*Sstep+4],[min(S(:))-1 max(S(:))-1],'Color','white');
    %line([(t-1)*Sstep (t-1)*Sstep],[min(S(:)) max(S(:))],'Color','r');
    %hold off;
    
    subplot(2,3,2);    
    colormap('jet');
    image(A(:,:,t));
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',[1:16]);
    set(gca,'YTick',[1:16]);
    colorbar;
    title(['C_{npmr} from V_1 to V_1, time/window ' num2str(t) ]);
    
    subplot(2,3,3);    
    colormap('jet');
    image(B(:,:,t));
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',[1:16]);
    set(gca,'YTick',[1:16]);
    colorbar;
    title(['C_{npmr} from V_1 to V_2, time/window ' num2str(t) ]);
    
    subplot(2,3,5);    
    colormap('jet');
    image(C(:,:,t));
    set(gca,'xaxisLocation','top');
    set(gca,'XTick',[1:16]);
    set(gca,'YTick',[1:16]);
    colorbar;
    title(['C_{npmr} from V_1 to V_1, time/window ' num2str(t) ]);
end

end 